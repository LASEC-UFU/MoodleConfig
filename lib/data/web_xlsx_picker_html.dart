// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'web_xlsx_picker_types.dart';

Future<PickedXlsxFile?> pickXlsxFileForWebImpl() {
  final completer = Completer<PickedXlsxFile?>();
  final input = html.FileUploadInputElement()
    ..accept =
        '.xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  input.onChange.first.then((_) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final file = files.first;
    final reader = html.FileReader();

    reader.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Erro ao ler "${file.name}" no navegador.'),
        );
      }
    });

    reader.onLoadEnd.first.then((_) {
      if (completer.isCompleted) return;
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(
          PickedXlsxFile(name: file.name, bytes: result.asUint8List()),
        );
        return;
      }
      if (result is Uint8List) {
        completer.complete(PickedXlsxFile(name: file.name, bytes: result));
        return;
      }
      completer.completeError(
        Exception('Formato de leitura inesperado para "${file.name}".'),
      );
    });

    reader.readAsArrayBuffer(file);
  });

  input.click();
  return completer.future;
}
