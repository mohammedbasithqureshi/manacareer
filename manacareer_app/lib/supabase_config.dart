import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://jitzovnvwitbnammtocb.supabase.co';
const supabaseAnonKey = 'sb_publishable_cHkO5DttYz__frADZYovcQ_CYGAtD6t';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;