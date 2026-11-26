import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin.dart';

class AdminService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/users';
  static const int nimAdminId = 792 + 200; // 992

  // Data awal Admin (termasuk entri dengan ID NIM 992)
  final List<Admin> _initialAdmins = [
    Admin(
      id: nimAdminId,
      name: 'Naufal Admin',
      email: 'naufal.admin@esaunggul.ac.id',
      department: 'IT & System Infrastructure',
    ),
    Admin(
      id: 993,
      name: 'Raka Pratama',
      email: 'raka.admin@esaunggul.ac.id',
      department: 'Database Administration',
    ),
    Admin(
      id: 994,
      name: 'Siti Rahma',
      email: 'siti.admin@esaunggul.ac.id',
      department: 'Security Operations',
    ),
  ];

  // GET: Mengambil seluruh data Admin
  Future<List<Admin>> getAdmins() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return List<Admin>.from(_initialAdmins);
      }
      throw Exception('Gagal mengambil data Admin (${response.statusCode})');
    } catch (_) {
      return List<Admin>.from(_initialAdmins);
    }
  }

  // GET by ID: Mengambil satu data Admin berdasarkan ID
  Future<Admin> getAdmin(int id) async {
    final admins = await getAdmins();
    final found = admins.where((admin) => admin.id == id).toList();
    if (found.isNotEmpty) {
      return found.first;
    }

    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Admin.fromJson({
        ...json,
        'id': id,
        'department': 'System Administration',
      });
    }
    throw Exception('Admin dengan ID $id tidak ditemukan');
  }

  // DELETE: Menghapus data Admin berdasarkan ID
  Future<void> deleteAdmin(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus Admin dengan ID $id (${response.statusCode})');
    }
    _initialAdmins.removeWhere((admin) => admin.id == id);
  }
}