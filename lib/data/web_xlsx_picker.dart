import 'web_xlsx_picker_stub.dart'
    if (dart.library.html) 'web_xlsx_picker_html.dart';
import 'web_xlsx_picker_types.dart';

export 'web_xlsx_picker_types.dart';

Future<PickedXlsxFile?> pickXlsxFileForWeb() => pickXlsxFileForWebImpl();
