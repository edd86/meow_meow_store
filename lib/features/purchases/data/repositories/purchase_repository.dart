import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/features/purchases/data/models/purchase_model.dart';
import 'abstract_purchase_repository.dart';

class PurchaseRepository implements AbstractPurchaseRepository {
  final SupabaseClient _client;

  PurchaseRepository(this._client);

  @override
  Future<List<Purchase>> getPurchases({String? status}) async {
    try {
      var query = _client.from('purchases').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Purchase.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Purchase> getPurchase(String id) async {
    try {
      final response = await _client
          .from('purchases')
          .select('*, purchase_items(*)')
          .eq('id', id)
          .single();

      return Purchase.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Purchase> createPurchase({
    String? supplierName,
    required List<PurchaseItem> items,
  }) async {
    try {
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
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Purchase> completePurchase(String purchaseId) async {
    try {
      final response = await _client
          .from('purchases')
          .update({'status': 'completed'})
          .eq('id', purchaseId)
          .select()
          .single();

      return Purchase.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Purchase> cancelPurchase(String purchaseId) async {
    try {
      final response = await _client
          .from('purchases')
          .update({'status': 'cancelled'})
          .eq('id', purchaseId)
          .select()
          .single();

      return Purchase.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }
}
