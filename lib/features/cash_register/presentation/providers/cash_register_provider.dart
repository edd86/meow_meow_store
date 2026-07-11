import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/cash_register_session_model.dart';
import '../../data/models/cash_transaction_model.dart';
import '../../data/repositories/abstract_cash_register_repository.dart';

class CashRegisterNotifier
    extends StateNotifier<AsyncValue<CashRegisterSession?>> {
  final AbstractCashRegisterRepository _repo;

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

  Future<void> addTransaction({
    required String type,
    required double amount,
    required String description,
  }) async {
    final currentSession = state.value;
    if (currentSession == null) {
      throw Exception('No hay sesion abierta');
    }

    await _repo.createTransaction(
      sessionId: currentSession.id,
      type: type,
      amount: amount,
      description: description,
    );
  }
}

final cashRegisterProvider =
    StateNotifierProvider<
      CashRegisterNotifier,
      AsyncValue<CashRegisterSession?>
    >((ref) {
      final repo = ref.watch(cashRegisterRepositoryProvider);
      return CashRegisterNotifier(repo);
    });

final sessionTransactionsProvider = FutureProvider<List<CashTransaction>>((
  ref,
) async {
  final session = ref.watch(cashRegisterProvider);
  if (session.value == null) return [];

  final repo = ref.watch(cashRegisterRepositoryProvider);

  try {
    return repo.getTransactions(sessionId: session.value!.id);
  } catch (e) {
    throw ServerException.fromSupabase(e);
  }
});
