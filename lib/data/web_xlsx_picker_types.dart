import 'dart:typed_data';

class PickedXlsxFile {
  final String name;
  final Uint8List bytes;

  const PickedXlsxFile({required this.name, required this.bytes});
}
