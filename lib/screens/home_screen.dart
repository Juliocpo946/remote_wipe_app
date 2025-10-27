import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import '../services/data_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await DataManager.instance.getUsers();
    final docs = await DataManager.instance.getDocuments();
    setState(() {
      _users = users;
      _documents = docs;
    });
  }

  Future<void> _saveUser() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Por favor, completa todos los campos de usuario.');
      return;
    }
    await DataManager.instance.saveUser(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    await _loadData();
    _showSnackBar('Usuario guardado correctamente.');
  }

  Future<void> _saveDocument() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      _showSnackBar('Por favor, completa todos los campos de documento.');
      return;
    }
    await DataManager.instance.saveDocument(
      _titleController.text,
      _contentController.text,
    );
    _titleController.clear();
    _contentController.clear();
    await _loadData();
    _showSnackBar('Documento guardado correctamente.');
  }

  Future<void> _wipeData() async {
    await DataManager.instance.wipeAllData();
    await _loadData();
    _showSnackBar('Todos los datos han sido borrados.');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = FirebaseService.instance.token ?? 'Cargando...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Wipe App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTokenSection(token),
            const SizedBox(height: 24),
            _buildUserSection(),
            const SizedBox(height: 24),
            _buildDocumentSection(),
            const SizedBox(height: 24),
            _buildWipeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenSection(String token) {
    return _buildSectionCard(
      title: 'FCM Token',
      child: Row(
        children: [
          Expanded(
            child: Text(
              token,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              _showSnackBar('Token copiado al portapapeles.');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    return _buildSectionCard(
      title: 'Usuarios (Base de Datos)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_nameController, 'Nombre', icon: Icons.person),
          const SizedBox(height: 8),
          _buildTextField(_emailController, 'Email', icon: Icons.email),
          const SizedBox(height: 8),
          _buildTextField(_passwordController, 'Contraseña', obscure: true, icon: Icons.lock),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveUser,
            style: _buttonStyle(),
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Guardar Usuario'),
          ),
          const SizedBox(height: 8),
          ..._users.map((user) => ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white70),
            title: Text(user['name'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(user['email'], style: const TextStyle(color: Colors.white70)),
            dense: true,
          )),
          if (_users.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No hay usuarios guardados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection() {
    return _buildSectionCard(
      title: 'Documentos (Base de Datos)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_titleController, 'Título', icon: Icons.title),
          const SizedBox(height: 8),
          _buildTextField(_contentController, 'Contenido', maxLines: 3, icon: Icons.article),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveDocument,
            style: _buttonStyle(),
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Guardar Documento'),
          ),
          const SizedBox(height: 8),
          ..._documents.map((doc) => ListTile(
            leading: const Icon(Icons.description, color: Colors.white70),
            title: Text(doc['title'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              doc['content'],
              style: const TextStyle(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            dense: true,
          )),
          if (_documents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No hay documentos guardados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWipeButton() {
    return ElevatedButton.icon(
      onPressed: _wipeData,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: const Icon(Icons.warning_amber_rounded, size: 18),
      label: const Text(
        'BORRAR TODOS LOS DATOS',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle({Color color = const Color(0xFF004D40)}) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false, int maxLines = 1, IconData? icon}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70, size: 20) : null,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}