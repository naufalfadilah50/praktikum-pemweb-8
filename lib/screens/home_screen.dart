import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/admin.dart';
import '../services/user_service.dart';
import '../services/admin_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  final AdminService _adminService = AdminService();

  List<User> _users = [];
  List<Admin> _admins = [];
  bool _loadingUsers = true;
  bool _loadingAdmins = true;

  final TextEditingController _searchIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    await Future.wait([_loadUsers(), _loadAdmins()]);
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final data = await _userService.getUsers();
      setState(() => _users = data);
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      setState(() => _loadingUsers = false);
    }
  }

  Future<void> _loadAdmins() async {
    setState(() => _loadingAdmins = true);
    try {
      final data = await _adminService.getAdmins();
      setState(() => _admins = data);
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      setState(() => _loadingAdmins = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _searchById() async {
    final id = int.tryParse(_searchIdController.text.trim());
    if (id == null) {
      _showSnack('Masukkan ID berupa angka yang valid.');
      return;
    }

    if (_tabController.index == 0) {
      try {
        final user = await _userService.getUserById(id);
        if (!mounted) return;
        _showUserDetailDialog(user);
      } catch (e) {
        _showSnack(e.toString());
      }
    } else {
      try {
        final admin = await _adminService.getAdmin(id);
        if (!mounted) return;
        _showAdminDetailDialog(admin);
      } catch (e) {
        _showSnack(e.toString());
      }
    }
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController(text: 'Naufal Fadhilah');
    final emailCtrl =
    TextEditingController(text: 'naufal.20240801200@esaunggul.ac.id');
    final cityCtrl = TextEditingController(text: 'Bekasi');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah User (ID: ${UserService.nimUserId})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(labelText: 'City'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final created = await _userService.createUser(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  city: cityCtrl.text.trim(),
                );
                setState(() => _users.insert(0, created));
                _showSnack('User ID ${created.id} berhasil ditambahkan (POST).');
              } catch (e) {
                _showSnack(e.toString());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditUserPutDialog(User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('PUT User #${user.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Baru'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final updated = await _userService.updateUser(
                  id: user.id,
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  city: user.city,
                );
                setState(() {
                  final idx = _users.indexWhere((u) => u.id == user.id);
                  if (idx != -1) _users[idx] = updated;
                });
                _showSnack('User #${user.id} diperbarui via PUT.');
              } catch (e) {
                _showSnack(e.toString());
              }
            },
            child: const Text('Update PUT'),
          ),
        ],
      ),
    );
  }

  Future<void> _patchUser(User user) async {
    try {
      final patched = await _userService.patchUserName(
        id: user.id,
        currentName: user.name,
      );
      setState(() {
        final idx = _users.indexWhere((u) => u.id == user.id);
        if (idx != -1) {
          _users[idx] = User(
            id: user.id,
            name: patched.name,
            email: user.email,
            city: user.city,
          );
        }
      });
      _showSnack('PATCH berhasil: ${patched.name}');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _deleteUser(User user) async {
    try {
      await _userService.deleteUser(user.id);
      setState(() => _users.removeWhere((u) => u.id == user.id));
      _showSnack('User #${user.id} dihapus via DELETE.');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _deleteAdmin(Admin admin) async {
    try {
      await _adminService.deleteAdmin(admin.id);
      setState(() => _admins.removeWhere((a) => a.id == admin.id));
      _showSnack('Admin ID ${admin.id} berhasil dihapus.');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  void _showUserDetailDialog(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail User #${user.id}'),
        content: Text(
          'Nama: ${user.name}\nEmail: ${user.email}\nCity: ${user.city}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAdminDetailDialog(Admin admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail Admin #${admin.id}'),
        content: Text(
          'Nama: ${admin.name}\nEmail: ${admin.email}\nDepartment: ${admin.department}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User & Admin Manager (NIM 200)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Users'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admins'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        tooltip: 'Tambah User (ID 1699)',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cari Detail berdasarkan ID (mis. 1699 atau 992)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _searchById,
                  icon: const Icon(Icons.search),
                  label: const Text('Detail'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(),
                _buildAdminList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_loadingUsers) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('${user.name} (ID: ${user.id})'),
              subtitle: Text('${user.email} • ${user.city}'),
              onTap: () => _showUserDetailDialog(user),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'PUT Nama & Email',
                    onPressed: () => _showEditUserPutDialog(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_fix_high),
                    tooltip: 'PATCH - Flutter Developer',
                    onPressed: () => _patchUser(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'DELETE User',
                    onPressed: () => _deleteUser(user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminList() {
    if (_loadingAdmins) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _loadAdmins,
      child: ListView.builder(
        itemCount: _admins.length,
        itemBuilder: (context, index) {
          final admin = _admins[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('${admin.name} (ID: ${admin.id})'),
              subtitle: Text('${admin.email} • Dept: ${admin.department}'),
              onTap: () => _showAdminDetailDialog(admin),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Hapus Admin berdasarkan ID',
                onPressed: () => _deleteAdmin(admin),
              ),
            ),
          );
        },
      ),
    );
  }
}