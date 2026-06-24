import 'dart:convert';
import 'package:http/http.dart' as http;
import 'opportunity.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001';

  static Future<List<Opportunity>> getOpportunities({String? type, String? district}) async {
    final params = <String, String>{};
    if (type != null && type != 'all') params['type'] = type;
    if (district != null && district != 'All districts') params['district'] = district;
    final uri = Uri.parse('$baseUrl/opportunities').replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Opportunity.fromJson(e)).toList();
    }
    throw Exception('Failed to load opportunities');
  }

  static Future<Map<String, dynamic>?> getProfile(String firebaseUid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile/$firebaseUid'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == false) return null;
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> saveProfile(Map<String, dynamic> profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}