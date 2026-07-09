import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/features/cash_register/data/models/cash_register_session_model.dart';
import 'package:meow_meow_store/features/cash_register/data/models/cash_transaction_model.dart';
import 'package:meow_meow_store/features/cash_register/data/repositories/cash_register_repository.dart';

class CashRegisterNotifier extends StateNotifier<AsyncValue<CashRegisterSession?>> {
  final CashRegisterRepository _repo;

  CashRegisterNotifier(this._repo) : super(const AsyncValue.loading()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    state = const AsyncValue.loading();
    try {
      final session = await _repo.getOpenSession();
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> openSession(double openingAmount) async {
    state = const AsyncValue.loading();
    try {
      final register = await _repo.getDefaultCashRegister();
      if (register == null) throw Exception('No cash register found');

      final session = await _repo.openSession(
        cashRegisterId: register.id,
        openingAmount: openingAmount,
      );
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> closeSession(double closingAmount) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    state = const AsyncValue.loading();
    try {
      await _repo.closeSession(
        sessionId: currentSession.id,
        closingAmount: closingAmount,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final cashRegisterProvider =
    StateNotifierProvider<CashRegisterNotifier, AsyncValue<CashRegisterSession?>>(
  (ref) {
    return CashRegisterNotifier(CashRegisterRepository());
  },
);

final sessionTransactionsProvider = FutureProvider<List<CashTransaction>>((ref) async {
  final session = ref.watch(cashRegisterProvider);
  if (session.value == null) return [];

  final repo = CashRegisterRepository();
  return repo.getTransactions(sessionId: session.value!.id);
});
