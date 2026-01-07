import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/neon_widgets.dart';
import '../../components/how_to_use_card.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _users = [
    {'id': 1, 'name': 'Juan Pérez', 'email': 'juan@empoderate.com', 'role': 'Admin', 'status': 'Active'},
    {'id': 2, 'name': 'Maria Lopez', 'email': 'maria@gmail.com', 'role': 'User', 'status': 'Active'},
    {'id': 3, 'name': 'Carlos Ruiz', 'email': 'carlos@tech.com', 'role': 'Pro', 'status': 'Inactive'},
  ];

  String _searchQuery = '';

  void _addUser() {
    showDialog(
      context: context,
      builder: (ctx) => _UserDialog(
        isEdit: false,
        onSave: (data) {
          setState(() {
            _users.add({
              'id': _users.length + 1,
              ...data,
              'status': 'Active'
            });
          });
        },
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => _UserDialog(
        isEdit: true,
        initialData: user,
        onSave: (data) {
          setState(() {
            final index = _users.indexWhere((u) => u['id'] == user['id']);
            if (index != -1) {
              _users[index] = {..._users[index], ...data};
            }
          });
        },
      ),
    );
  }

  void _deleteUser(int id) {
    setState(() {
      _users.removeWhere((u) => u['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
             u['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF001220),
      appBar: AppBar(
        title: Text('Gestión de Usuarios', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // How to Use Card
            const HowToUseCard(
              title: '¿Cómo gestionar usuarios?',
              icon: Icons.people_outline,
              accentColor: Color(0xFF00E5FF),
              steps: [
                'Usa la barra de búsqueda para encontrar usuarios por nombre o email.',
                'Toca el botón + para invitar un nuevo usuario.',
                'Usa el menú de 3 puntos en cada usuario para editar o eliminar.',
                'Los roles disponibles son: Admin, User y Pro.',
              ],
            ),
            
            // Search Bar
            NeonInput(
              label: 'Buscar usuario',
              hint: 'Nombre o email...',
              suffixIcon: const Icon(Icons.search, color: Colors.white54),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 20),

            // User List
            Expanded(
              child: filteredUsers.isEmpty 
              ? Center(child: Text('No se encontraron usuarios', style: GoogleFonts.outfit(color: Colors.white54)))
              : ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(user['role']),
                          child: Text(user['name'][0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(user['name'], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(user['email'], style: GoogleFonts.outfit(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(user['role'], style: const TextStyle(fontSize: 10)),
                              backgroundColor: _getRoleColor(user['role']).withOpacity(0.2),
                              labelStyle: TextStyle(color: _getRoleColor(user['role'])),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white54),
                              onSelected: (val) {
                                if (val == 'edit') _editUser(user);
                                if (val == 'delete') _deleteUser(user['id']);
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin': return const Color(0xFFD4AF37); // Gold
      case 'Pro': return const Color(0xFFE040FB); // Purple
      default: return const Color(0xFF00E5FF); // Cyan
    }
  }
}

// Simple Dialog for Add/Edit
class _UserDialog extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const _UserDialog({Key? key, required this.isEdit, this.initialData, required this.onSave}) : super(key: key);

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  String _selectedRole = 'User';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialData?['name'] ?? '');
    _emailCtrl = TextEditingController(text: widget.initialData?['email'] ?? '');
    if (widget.initialData != null) _selectedRole = widget.initialData!['role'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF001220),
      title: Text(widget.isEdit ? 'Editar Usuario' : 'Nuevo Usuario', style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeonInput(label: 'Nombre', controller: _nameCtrl),
          if (!widget.isEdit) NeonInput(label: 'Email', controller: _emailCtrl),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            dropdownColor: const Color(0xFF001220),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Rol',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF))),
            ),
            items: ['Admin', 'User', 'Pro'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (val) => setState(() => _selectedRole = val!),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
        NeonButton(
          text: 'Guardar', 
          color: const Color(0xFF00E5FF),
          onTap: () {
            if (_nameCtrl.text.isEmpty) return;
            widget.onSave({
              'name': _nameCtrl.text,
              'email': _emailCtrl.text,
              'role': _selectedRole,
            });
            Navigator.pop(context);
          }
        ),
      ],
    );
  }
}
