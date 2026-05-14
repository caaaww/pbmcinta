import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const _storage = FlutterSecureStorage();

  // ─── Token helpers ───────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<void> saveUser(User user) async {
    await _storage.write(key: 'user_name', value: user.name);
    await _storage.write(key: 'user_username', value: user.username);
    await _storage.write(key: 'user_class', value: user.className);
  }

  static Future<Map<String, String?>> getSavedUser() async {
    return {
      'name': await _storage.read(key: 'user_name'),
      'username': await _storage.read(key: 'user_username'),
      'class': await _storage.read(key: 'user_class'),
    };
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ─── Auth headers ─────────────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── Login ────────────────────────────────────────────────────────
  static Future<User> login(String nim, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': nim, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final user = User.fromJson(data);
      await saveToken(user.token);
      await saveUser(user);
      return user;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  // ─── Get Products ─────────────────────────────────────────────────
  static Future<List<Product>> getProducts() async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.get(url, headers: await _authHeaders());

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final List list = data['data']['products'] ?? [];
      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil produk');
    }
  }

  // ─── Add Product (draft) ──────────────────────────────────────────
  static Future<Product> addProduct({
    required String name,
    required int price,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    final data = jsonDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] == true) {
      return Product.fromJson(data['data']['product'] ?? data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal menambah produk');
    }
  }

  // ─── Delete Product ───────────────────────────────────────────────
  static Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.delete(url, headers: await _authHeaders());

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal menghapus produk');
    }
  }

  // ─── Submit Tugas ─────────────────────────────────────────────────
  static Future<void> submitTugas({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/products/submit');
    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 && response.statusCode != 201 ||
        data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal submit tugas');
    }
  }
}
