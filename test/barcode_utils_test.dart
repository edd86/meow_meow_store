import 'package:flutter_test/flutter_test.dart';
import 'package:meow_meow_store/core/utils/barcode_utils.dart';

void main() {
  test('generate and decode preserve product data', () {
    final encoded = BarcodeUtils.generateFromProduct('123', 'Cat');
    final decoded = BarcodeUtils.decode(encoded);

    expect(decoded, {'id': '123', 'name': 'Cat'});
  });
}
