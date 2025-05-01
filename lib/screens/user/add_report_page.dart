import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final TextEditingController _descController = TextEditingController();
  XFile? _imageFile;
  LatLng? _currentPosition;
  LatLng? _selectedLocation;
  bool _isUploading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _selectedLocation = _currentPosition;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future getUserId() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      _userId = session.user.id;
      if (!mounted) return;
      return _userId;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Session tidak ditemukan")));
      return null;
    }
  }

  Future<void> _uploadReport() async {
    final userIdReport = await getUserId();
    if (_imageFile == null ||
        _selectedLocation == null ||
        _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi deskripsi, gambar, dan lokasi")),
      );
      return;
    }

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'Report_Images/$fileName.jpg';
      final bytes = await _imageFile!.readAsBytes();

      if (!_isUploading) {
        setState(() => _isUploading = true);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      final response = await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(path, bytes);

      await Supabase.instance.client.from('reports').insert({
        'description': _descController.text,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'image_url': path,
        'created_at': DateTime.now().toIso8601String(),
        'userId': userIdReport,
        'status': 'Menunggu',
      });

      if (mounted) Navigator.pop(context);
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Laporan berhasil dikirim")));
    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload gagal: $e")));
    }
  }

  void _onMapTap(TapPosition _, LatLng latlng) {
    setState(() {
      _selectedLocation = latlng;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Laporan'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.white.withValues(alpha:  0.7),
        child: Column(
          children: [
            // Manual AppBar
            // Tombol Kirim Laporan
            // Isi Konten
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Deskripsi", style: TextStyle(fontSize: 16)),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Tulis deskripsi laporan...",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Pilih Lokasi", style: TextStyle(fontSize: 16)),
                    SizedBox(
                      height: 300,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _selectedLocation ?? _currentPosition!,
                          initialZoom: 16,
                          onTap: _onMapTap,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          if (_selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Upload Foto", style: TextStyle(fontSize: 16)),
                    _imageFile != null
                        ? const Text(
                          "Gambar berhasil dipilih ✅",
                          style: TextStyle(color: Colors.green),
                        )
                        : const Text("Belum ada gambar"),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pilih Foto',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: _uploadReport,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Kirim Laporan',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
