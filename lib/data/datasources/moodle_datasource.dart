import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:config_moodle/domain/entities/moodle_entities.dart';

class MoodleDatasource {
  Future<Map<String, dynamic>> _callWs(
    String baseUrl,
    String token,
    String function, {
    Map<String, String> params = const {},
    bool usePost = false,
  }) async {
    final baseParams = {
      'wstoken': token,
      'wsfunction': function,
      'moodlewsrestformat': 'json',
    };

    late final http.Response response;
    if (usePost) {
      final uri = Uri.parse('$baseUrl/webservice/rest/server.php');
      response = await http.post(uri, body: {...baseParams, ...params});
    } else {
      final uri = Uri.parse(
        '$baseUrl/webservice/rest/server.php',
      ).replace(queryParameters: {...baseParams, ...params});
      response = await http.get(uri);
    }
    if (response.statusCode != 200) {
      throw MoodleException('HTTP ${response.statusCode}');
    }
    final body = json.decode(response.body);
    if (body is Map && body.containsKey('exception')) {
      throw MoodleException(body['message'] ?? body['exception']);
    }
    return {'data': body};
  }

  /// Serviços externos tentados na ordem: primeiro um serviço personalizado
  /// com permissões de escrita, depois o serviço mobile padrão.
  static const _services = [
    'config_moodle_service', // Serviço externo criado pelo admin com funções de edição
    'moodle_mobile_app', // Serviço padrão (somente leitura em muitos Moodles)
  ];

  Future<MoodleCredential> login(
    String baseUrl,
    String username,
    String password,
  ) async {
    String? token;
    String? lastError;

    for (final service in _services) {
      final uri = Uri.parse('$baseUrl/login/token.php');
      final response = await http.post(
        uri,
        body: {'username': username, 'password': password, 'service': service},
      );

      if (response.statusCode != 200) continue;

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body.containsKey('error')) {
        lastError = body['error'] as String;
        continue;
      }

      token = body['token'] as String;
      break;
    }

    if (token == null) {
      throw MoodleException(lastError ?? 'Falha na conexão com o Moodle');
    }

    // Get user info
    final info = await _callWs(baseUrl, token, 'core_webservice_get_site_info');
    final data = info['data'] as Map<String, dynamic>;

    return MoodleCredential(
      moodleUrl: baseUrl,
      username: username,
      token: token,
      userId: data['userid'] as int,
      fullname: data['fullname'] as String? ?? username,
      savedAt: DateTime.now(),
    );
  }

  Future<List<MoodleCourse>> getCourses(
    String token,
    String baseUrl,
    int userId,
  ) async {
    final result = await _callWs(
      baseUrl,
      token,
      'core_enrol_get_users_courses',
      params: {'userid': userId.toString()},
    );
    final list = result['data'] as List;
    return list
        .map((c) => MoodleCourse.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<List<MoodleSection>> getCourseContents(
    String token,
    String baseUrl,
    int courseId,
  ) async {
    final result = await _callWs(
      baseUrl,
      token,
      'core_course_get_contents',
      params: {'courseid': courseId.toString()},
    );
    final list = result['data'] as List;
    return list
        .map((s) => MoodleSection.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateSectionName(
    String token,
    String baseUrl,
    int sectionId,
    String newName,
  ) async {
    await _callWs(
      baseUrl,
      token,
      'core_update_inplace_editable',
      usePost: true,
      params: {
        'component': 'core_course',
        'itemtype': 'sectionname',
        'itemid': sectionId.toString(),
        'value': newName,
      },
    );
  }

  Future<void> updateModuleVisibility(
    String token,
    String baseUrl,
    int moduleId,
    bool visible,
  ) async {
    await _callWs(
      baseUrl,
      token,
      'core_course_edit_module',
      usePost: true,
      params: {'id': moduleId.toString(), 'action': visible ? 'show' : 'hide'},
    );
  }

  Future<void> updateModuleName(
    String token,
    String baseUrl,
    int moduleId,
    String newName,
  ) async {
    await _callWs(
      baseUrl,
      token,
      'core_update_inplace_editable',
      usePost: true,
      params: {
        'component': 'core_course',
        'itemtype': 'activityname',
        'itemid': moduleId.toString(),
        'value': newName,
      },
    );
  }

  Future<void> updateLabelContent(
    String token,
    String baseUrl,
    int moduleId,
    String htmlContent,
  ) async {
    await _callWs(
      baseUrl,
      token,
      'core_update_inplace_editable',
      usePost: true,
      params: {
        'component': 'mod_label',
        'itemtype': 'content',
        'itemid': moduleId.toString(),
        'value': htmlContent,
      },
    );
  }
}

class MoodleException implements Exception {
  final String message;
  MoodleException(this.message);
  @override
  String toString() => 'MoodleException: $message';
}
