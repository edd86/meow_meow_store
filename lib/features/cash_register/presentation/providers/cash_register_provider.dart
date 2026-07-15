import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/cash_register_session_model.dart';
import '../../data/models/cash_transaction_model.dart';

class CashRegisterNotifier extends AsyncNotifier<CashRegisterSession?> {
  @override
  Future<CashRegisterSession?> build() async {
    final repo = ref.read(cashRegisterRepositoryProvider);
    try {
      return repo.getOpenSession();
    } catch (_) {
      return null;
    }
  }

  Future<void> openSession(double openingAmount) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(cashRegisterRepositoryProvider);
      final register = await repo.getDefaultCashRegister();
      if (register == null) throw Exception('No cash register found');

      final session = await repo.openSession(
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
      final repo = ref.read(cashRegisterRepositoryProvider);
      await repo.closeSession(
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

    final repo = ref.read(cashRegisterRepositoryProvider);
    await repo.createTransaction(
      sessionId: currentSession.id,
      type: type,
      amount: amount,
      description: description,
    );
  }
}

final cashRegisterProvider =
    AsyncNotifierProvider<CashRegisterNotifier, CashRegisterSession?>(
  CashRegisterNotifier.new,
);

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
