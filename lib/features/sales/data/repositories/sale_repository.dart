import 'package:meow_meow_store/core/network/supabase_client.dart';
import 'package:meow_meow_store/features/sales/data/models/sale_model.dart';

class SaleRepository {
  final _client = SupabaseClientProvider.instance;

  Future<List<Sale>> getSales({String? status}) async {
    var query = _client.from('sales').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => Sale.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Sale> getSale(String id) async {
    final response = await _client
        .from('sales')
        .select('*, sale_items(*)')
        .eq('id', id)
        .single();

    return Sale.fromJson(response);
  }

  Future<Sale> createSale({
    String? customerId,
    String? userId,
    required List<SaleItem> items,
  }) async {
    final totalAmount = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    final saleResponse = await _client
        .from('sales')
        .insert({
          'customer_id': customerId,
          'user_id': userId,
          'total_amount': totalAmount,
          'status': 'pending',
        })
        .select()
        .single();

    final sale = Sale.fromJson(saleResponse);

    final saleItems = items.map((item) {
      return {
        'sale_id': sale.id,
        'product_id': item.productId,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
      };
    }).toList();

    await _client.from('sale_items').insert(saleItems);

    return sale;
  }

  Future<Sale> completeSale(String saleId) async {
    final response = await _client
        .from('sales')
        .update({'status': 'completed'})
        .eq('id', saleId)
        .select()
        .single();

    return Sale.fromJson(response);
  }

  Future<Sale> cancelSale(String saleId) async {
    final response = await _client
        .from('sales')
        .update({'status': 'cancelled'})
        .eq('id', saleId)
        .select()
        .single();

    return Sale.fromJson(response);
  }

  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final response = await _client
        .from('sale_items')
        .select()
        .eq('sale_id', saleId);

    return (response as List)
        .map((json) => SaleItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
