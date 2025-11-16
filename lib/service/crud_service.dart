import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcc_flutter/utils/prefs.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract class CrudService<T> {
  final String baseUrl;
  final FromJson<T> fromJson;

  CrudService({required this.baseUrl, required this.fromJson});

  // =======================
  // GET genérico retornando um item
  // =======================
  Future<T> getItem(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _defaultHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      return fromJson(jsonMap);
    } else {
      throw Exception('Erro ao buscar item (status ${response.statusCode})');
    }
  }

  // GET genérico retornando lista
  Future<List<T>> getList(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _defaultHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar lista (status ${response.statusCode})');
    }
  }

  // =======================
  // POST genérico retornando T
  // =======================
  Future<T> postItem(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse(endpoint.isEmpty ? baseUrl : '$baseUrl/$endpoint');
    final headers = await _defaultHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      return fromJson(jsonMap);
    } else {
      throw Exception('Erro ao criar item (status ${response.statusCode})');
    }
  }

  // POST genérico retornando lista de T (opcional)
  Future<List<T>> postList(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _defaultHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => fromJson(json)).toList();
    } else {
      throw Exception('Erro ao criar lista (status ${response.statusCode})');
    }
  }

  // =======================
  // PUT genérico retornando T
  // =======================
  Future<T> putItem(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _defaultHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      return fromJson(jsonMap);
    } else {
      throw Exception('Erro ao atualizar item (status ${response.statusCode})');
    }
  }

  // =======================
  // DELETE genérico retornando void
  // =======================
  Future<void> deleteItem(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await _defaultHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao deletar item (status ${response.statusCode})');
    }
  }

  // =======================
  // Headers com JWT
  // =======================
  Future<Map<String, String>> _defaultHeaders() async {
    final token = await Prefs.getString("token");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}
