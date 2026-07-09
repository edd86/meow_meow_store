import 'package:meow_meow_store/features/purchases/data/models/purchase_model.dart';

abstract class AbstractPurchaseRepository {
  Future<List<Purchase>> getPurchases({String? status});
  Future<Purchase> getPurchase(String id);
  Future<Purchase> createPurchase({
    String? supplierName,
    required List<PurchaseItem> items,
  });
  Future<Purchase> completePurchase(String purchaseId);
  Future<Purchase> cancelPurchase(String purchaseId);
}
