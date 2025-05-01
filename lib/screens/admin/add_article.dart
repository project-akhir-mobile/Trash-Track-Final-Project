import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategory;
  String? _email;

  Future getUsername() async {
    final supabase = Supabase.instance.client;
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      _email = session.user.email;
      final data = await supabase.from('profile').select().eq('email', _email!).single();
      if (!mounted) return;
      if (data.isNotEmpty) {
        return data['username'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data tidak ditemukan")));
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Session atau user tidak ditemukan")));
      return null;
    }
  }

  void addReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      final supabase = Supabase.instance.client;
      final username = await getUsername();

      if (username == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendapatkan username"), action: SnackBarAction(label: 'Tutup', onPressed: () {})),
        );
        return;
      }

      final List<Map<String, dynamic>> data = await supabase.from('articles').insert({
        'title': _titleController.text,
        'content': _contentController.text,
        'author': username,
        'category': _selectedCategory,
      }).select();

      if (!mounted) return;

      if (data.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil Menambah Artikel"), action: SnackBarAction(label: 'Tutup', onPressed: () {})),
        );
        _titleController.clear();
        _contentController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Menambah Artikel"), action: SnackBarAction(label: 'Tutup', onPressed: () {})),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Artikel"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Konten',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Konten tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Kategori'),
                items: [
                  DropdownMenuItem(value: 'Edukasi Sampah', child: Text('Edukasi Sampah')),
                  DropdownMenuItem(value: 'Daur Ulang', child: Text('Daur Ulang')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori harus dipilih';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF8BC34A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: addReport,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'Tambah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
