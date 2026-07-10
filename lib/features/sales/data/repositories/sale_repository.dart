import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/features/sales/data/models/sale_model.dart';
import 'abstract_sale_repository.dart';

class SaleRepository implements AbstractSaleRepository {
  final SupabaseClient _client;

  SaleRepository(this._client);

  @override
  Future<List<Sale>> getSales({String? status}) async {
    try {
      var query = _client.from('sales').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Sale.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Sale> getSale(String id) async {
    try {
      final response = await _client
          .from('sales')
          .select('*, sale_items(*)')
          .eq('id', id)
          .single();

      return Sale.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Sale> createSale({
    String? customerId,
    required List<SaleItem> items,
  }) async {
    try {
      final totalAmount = items.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

      final saleResponse = await _client
          .from('sales')
          .insert({
            'customer_id': customerId,
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
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Sale> completeSale(String saleId) async {
    try {
      final response = await _client
          .from('sales')
          .update({'status': 'completed'})
          .eq('id', saleId)
          .select()
          .single();

      return Sale.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Sale> cancelSale(String saleId) async {
    try {
      final response = await _client
          .from('sales')
          .update({'status': 'cancelled'})
          .eq('id', saleId)
          .select()
          .single();

      return Sale.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<List<SaleItem>> getSaleItems(String saleId) async {
    try {
      final response = await _client
          .from('sale_items')
          .select()
          .eq('sale_id', saleId);

      return (response as List)
          .map((json) => SaleItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }
}
