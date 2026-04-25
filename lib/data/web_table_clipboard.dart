import 'web_table_clipboard_stub.dart'
    if (dart.library.html) 'web_table_clipboard_html.dart';

Future<bool> copyHtmlTableForWeb({
  required String html,
  required String plainText,
}) {
  return copyHtmlTableForWebImpl(html: html, plainText: plainText);
}
