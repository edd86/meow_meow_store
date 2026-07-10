import 'package:meow_meow_store/features/cash_register/data/models/cash_register_model.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_register_session_model.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_transaction_model.dart';

abstract class AbstractCashRegisterRepository {
  Future<CashRegister?> getDefaultCashRegister();
  Future<CashRegisterSession?> getOpenSession();
  Future<CashRegisterSession> openSession({
    required String cashRegisterId,
    required double openingAmount,
  });
  Future<CashRegisterSession> closeSession({
    required String sessionId,
    required double closingAmount,
  });
  Future<List<CashTransaction>> getTransactions({
    String? sessionId,
    String? type,
  });
  Future<CashTransaction> createTransaction({
    required String sessionId,
    required String type,
    required double amount,
    required String description,
    String? saleId,
    String? purchaseId,
  });
}
