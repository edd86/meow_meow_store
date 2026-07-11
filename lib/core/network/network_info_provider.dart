import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final networkInfoProvider = StreamProvider<InternetStatus>((ref) {
  return InternetConnection().onStatusChange;
});

final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(networkInfoProvider);
  return status.valueOrNull == InternetStatus.disconnected;
});
