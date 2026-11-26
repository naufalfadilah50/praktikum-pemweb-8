import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/users';
  static const int nimUserId = 1499 + 200; // 1699

  // GET: Mengambil seluruh data User
  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data User (${response.statusCode})');
    }
  }

  // GET by ID: Mengambil satu data User berdasarkan ID
  Future<User> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('User dengan ID $id tidak ditemukan (${response.statusCode})');
    }
  }

  // POST: Menambahkan User baru berdasarkan ID dari NIM (1699)
  Future<User> createUser({
    required String name,
    required String email,
    required String city,
    int? customId,
  }) async {
    final payload = {
      'id': customId ?? nimUserId,
      'name': name,
      'email': email,
      'city': city,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      return User(
        id: customId ?? nimUserId,
        name: result['name']?.toString() ?? name,
        email: result['email']?.toString() ?? email,
        city: result['city']?.toString() ?? city,
      );
    } else {
      throw Exception('Gagal menambah User (${response.statusCode})');
    }
  }

  // PUT: Memperbarui nama dan email User
  Future<User> updateUser({
    required int id,
    required String name,
    required String email,
    String city = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'id': id,
        'name': name,
        'email': email,
        'city': city,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      return User(
        id: id,
        name: result['name']?.toString() ?? name,
        email: result['email']?.toString() ?? email,
        city: result['city']?.toString() ?? city,
      );
    } else {
      throw Exception('Gagal memperbarui User (${response.statusCode})');
    }
  }

  // PATCH: Memperbarui nama User dengan menambahkan teks " - Flutter Developer"
  Future<User> patchUserName({
    required int id,
    required String currentName,
  }) async {
    final updatedName = currentName.endsWith(' - Flutter Developer')
        ? currentName
        : '$currentName - Flutter Developer';

    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': updatedName}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      return User(
        id: id,
        name: result['name']?.toString() ?? updatedName,
        email: result['email']?.toString() ?? '',
        city: result['city']?.toString() ?? '',
      );
    } else {
      throw Exception('Gagal PATCH nama User (${response.statusCode})');
    }
  }

  // DELETE: Menghapus User berdasarkan ID
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus User (${response.statusCode})');
    }
  }
}