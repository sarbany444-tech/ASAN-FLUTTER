import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

/// Creates a browser blob URL for in-memory video bytes (Chrome/web only).
String createWebBlobUrl(Uint8List bytes, String mimeType) {
  final blob = Blob(
    [bytes.toJS].toJS,
    BlobPropertyBag(type: mimeType),
  );
  return URL.createObjectURL(blob);
}

void revokeWebBlobUrl(String url) {
  if (url.startsWith('blob:')) {
    URL.revokeObjectURL(url);
  }
}
