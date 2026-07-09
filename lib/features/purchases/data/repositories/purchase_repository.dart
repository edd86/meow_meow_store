import 'package:meow_meow_store/core/network/supabase_client.dart';
import 'package:meow_meow_store/features/purchases/data/models/purchase_model.dart';

class PurchaseRepository {
  final _client = SupabaseClientProvider.instance;

  Future<List<Purchase>> getPurchases({String? status}) async {
    var query = _client.from('purchases').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => Purchase.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Purchase> getPurchase(String id) async {
    final response = await _client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('id', id)
        .single();

    return Purchase.fromJson(response);
  }

  Future<Purchase> createPurchase({
    String? supplierName,
    required List<PurchaseItem> items,
  }) async {
    final totalAmount = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    final purchaseResponse = await _client
        .from('purchases')
        .insert({
          'supplier_name': supplierName,
          'total_amount': totalAmount,
          'status': 'pending',
        })
        .select()
        .single();

    final purchase = Purchase.fromJson(purchaseResponse);

    final purchaseItems = items.map((item) {
      return {
        'purchase_id': purchase.id,
        'product_id': item.productId,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
      };
    }).toList();

    await _client.from('purchase_items').insert(purchaseItems);

    return purchase;
  }

  Future<Purchase> completePurchase(String purchaseId) async {
    final response = await _client
        .from('purchases')
        .update({'status': 'completed'})
        .eq('id', purchaseId)
        .select()
        .single();

    return Purchase.fromJson(response);
  }

  Future<Purchase> cancelPurchase(String purchaseId) async {
    final response = await _client
        .from('purchases')
        .update({'status': 'cancelled'})
        .eq('id', purchaseId)
        .select()
        .single();

    return Purchase.fromJson(response);
  }
}
