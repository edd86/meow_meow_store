import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env.dart';

class SupabaseClientProvider {
  static SupabaseClient? _instance;

  static SupabaseClient get instance {
    _instance ??= SupabaseClient(
      Env.supabaseUrl,
      Env.supabaseAnonKey,
    );
    return _instance!;
  }

  static GoTrueClient get auth => instance.auth;
}
