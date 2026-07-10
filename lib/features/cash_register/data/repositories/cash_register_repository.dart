import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_register_model.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_register_session_model.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_transaction_model.dart';
import 'abstract_cash_register_repository.dart';

class CashRegisterRepository implements AbstractCashRegisterRepository {
  final SupabaseClient _client;

  CashRegisterRepository(this._client);

  @override
  Future<CashRegister?> getDefaultCashRegister() async {
    try {
      final response = await _client
          .from('cash_registers')
          .select()
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return CashRegister.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<CashRegisterSession?> getOpenSession() async {
    try {
      final response = await _client
          .from('cash_register_sessions')
          .select()
          .eq('status', 'open')
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return CashRegisterSession.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<CashRegisterSession> openSession({
    required String cashRegisterId,
    required double openingAmount,
  }) async {
    try {
      final response = await _client
          .from('cash_register_sessions')
          .insert({
            'cash_register_id': cashRegisterId,
            'opening_amount': openingAmount,
            'status': 'open',
          })
          .select()
          .single();

      return CashRegisterSession.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<CashRegisterSession> closeSession({
    required String sessionId,
    required double closingAmount,
  }) async {
    try {
      final response = await _client
          .from('cash_register_sessions')
          .update({
            'closing_amount': closingAmount,
            'status': 'closed',
            'closed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', sessionId)
          .select()
          .single();

      return CashRegisterSession.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<List<CashTransaction>> getTransactions({
    String? sessionId,
    String? type,
  }) async {
    try {
      var query = _client.from('cash_transactions').select();

      if (sessionId != null) {
        query = query.eq('session_id', sessionId);
      }
      if (type != null) {
        query = query.eq('transaction_type', type);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => CashTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<CashTransaction> createTransaction({
    required String sessionId,
    required String type,
    required double amount,
    required String description,
    String? saleId,
    String? purchaseId,
  }) async {
    try {
      final response = await _client
          .from('cash_transactions')
          .insert({
            'session_id': sessionId,
            'transaction_type': type,
            'amount': amount,
            'description': description,
            'sale_id': saleId,
            'purchase_id': purchaseId,
          })
          .select()
          .single();

      return CashTransaction.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }
}
