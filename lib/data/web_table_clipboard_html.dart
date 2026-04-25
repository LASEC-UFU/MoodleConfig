// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as dom;

Future<bool> copyHtmlTableForWebImpl({
  required String html,
  required String plainText,
}) async {
  final container = dom.DivElement()
    ..contentEditable = 'true'
    ..style.position = 'fixed'
    ..style.left = '-10000px'
    ..style.top = '0'
    ..setInnerHtml(html, treeSanitizer: dom.NodeTreeSanitizer.trusted);

  dom.document.body?.append(container);

  final selection = dom.window.getSelection();
  final range = dom.document.createRange();
  range.selectNodeContents(container);
  selection?.removeAllRanges();
  selection?.addRange(range);

  final copied = dom.document.execCommand('copy');

  selection?.removeAllRanges();
  container.remove();

  if (copied) return true;

  await dom.window.navigator.clipboard?.writeText(plainText);
  return true;
}
