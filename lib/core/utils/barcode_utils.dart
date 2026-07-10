import 'dart:convert';

abstract final class BarcodeUtils {
  static String generateFromProduct(String id, String name) {
    final json = jsonEncode({'id': id, 'name': name});
    return base64Url.encode(utf8.encode(json));
  }

  static Map<String, dynamic> decode(String barcode) {
    final decoded = utf8.decode(base64Url.decode(barcode));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}

  static Map<String, dynamic> decode(String value) {
    final decodedBytes = base64Url.decode(value);
    final decodedJson = utf8.decode(decodedBytes);
    return jsonDecode(decodedJson) as Map<String, dynamic>;
  }
}
