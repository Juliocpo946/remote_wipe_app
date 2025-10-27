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
  final _prefKeyController = TextEditingController();
  final _prefValueController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _documents = [];
  String? _prefValue;

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
  }

  Future<void> _saveDocument() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      return;
    }
    await DataManager.instance.saveDocument(
      _titleController.text,
      _contentController.text,
    );
    _titleController.clear();
    _contentController.clear();
    await _loadData();
  }

  Future<void> _savePreference() async {
    if (_prefKeyController.text.isEmpty || _prefValueController.text.isEmpty) {
      return;
    }
    await DataManager.instance.saveToPreferences(
      _prefKeyController.text,
      _prefValueController.text,
    );
    _prefKeyController.clear();
    _prefValueController.clear();
  }

  Future<void> _loadPreference() async {
    if (_prefKeyController.text.isEmpty) {
      return;
    }
    final value = await DataManager.instance.getFromPreferences(_prefKeyController.text);
    setState(() {
      _prefValue = value;
    });
  }

  Future<void> _wipeData() async {
    await DataManager.instance.wipeAllData();
    await _loadData();
    setState(() {
      _prefValue = null;
    });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTokenSection(token),
            const SizedBox(height: 24),
            _buildUserSection(),
            const SizedBox(height: 24),
            _buildDocumentSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildWipeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenSection(String token) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FCM Token',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  token,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usuarios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildTextField(_nameController, 'Nombre'),
          const SizedBox(height: 8),
          _buildTextField(_emailController, 'Email'),
          const SizedBox(height: 8),
          _buildTextField(_passwordController, 'Contraseña', obscure: true),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
            ),
            child: const Text('Guardar Usuario'),
          ),
          const SizedBox(height: 16),
          ..._users.map((user) => ListTile(
            title: Text(user['name'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(user['email'], style: const TextStyle(color: Colors.white70)),
            dense: true,
          )),
        ],
      ),
    );
  }

  Widget _buildDocumentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documentos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildTextField(_titleController, 'Título'),
          const SizedBox(height: 8),
          _buildTextField(_contentController, 'Contenido', maxLines: 3),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveDocument,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
            ),
            child: const Text('Guardar Documento'),
          ),
          const SizedBox(height: 16),
          ..._documents.map((doc) => ListTile(
            title: Text(doc['title'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(doc['content'], style: const TextStyle(color: Colors.white70)),
            dense: true,
          )),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferencias',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildTextField(_prefKeyController, 'Clave'),
          const SizedBox(height: 8),
          _buildTextField(_prefValueController, 'Valor'),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: _savePreference,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loadPreference,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                ),
                child: const Text('Cargar'),
              ),
            ],
          ),
          if (_prefValue != null) ...[
            const SizedBox(height: 16),
            Text(
              'Valor: $_prefValue',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWipeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _wipeData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'LIMPIAR DATOS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
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
    _prefKeyController.dispose();
    _prefValueController.dispose();
    super.dispose();
  }
}