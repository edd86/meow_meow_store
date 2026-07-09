import 'package:meow_meow_store/features/sales/data/models/sale_model.dart';

abstract class AbstractSaleRepository {
  Future<List<Sale>> getSales({String? status});
  Future<Sale> getSale(String id);
  Future<Sale> createSale({
    String? customerId,
    String? userId,
    required List<SaleItem> items,
  });
  Future<Sale> completeSale(String saleId);
  Future<Sale> cancelSale(String saleId);
  Future<List<SaleItem>> getSaleItems(String saleId);
}
