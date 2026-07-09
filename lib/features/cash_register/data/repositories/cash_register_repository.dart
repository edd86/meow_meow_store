import 'package:meow_meow_store/core/network/supabase_client.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_register_model.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_register_session_model.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_transaction_model.dart';

class CashRegisterRepository {
  final _client = SupabaseClientProvider.instance;

  Future<CashRegister?> getDefaultCashRegister() async {
    final response = await _client
        .from('cash_registers')
        .select()
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return CashRegister.fromJson(response);
  }

  Future<CashRegisterSession?> getOpenSession() async {
    final response = await _client
        .from('cash_register_sessions')
        .select()
        .eq('status', 'open')
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return CashRegisterSession.fromJson(response);
  }

  Future<CashRegisterSession> openSession({
    required String cashRegisterId,
    required double openingAmount,
    String? userId,
  }) async {
    final response = await _client
        .from('cash_register_sessions')
        .insert({
          'cash_register_id': cashRegisterId,
          'opening_amount': openingAmount,
          'status': 'open',
          'opened_by': userId,
        })
        .select()
        .single();

    return CashRegisterSession.fromJson(response);
  }

  Future<CashRegisterSession> closeSession({
    required String sessionId,
    required double closingAmount,
    String? userId,
  }) async {
    final response = await _client
        .from('cash_register_sessions')
        .update({
          'closing_amount': closingAmount,
          'status': 'closed',
          'closed_by': userId,
          'closed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', sessionId)
        .select()
        .single();

    return CashRegisterSession.fromJson(response);
  }

  Future<List<CashTransaction>> getTransactions({
    String? sessionId,
    String? type,
  }) async {
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
  }

  Future<CashTransaction> createTransaction({
    required String sessionId,
    required String type,
    required double amount,
    required String description,
    String? saleId,
    String? purchaseId,
  }) async {
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
  }
}
