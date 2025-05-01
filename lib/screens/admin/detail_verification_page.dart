import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailVerificationPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const DetailVerificationPage({super.key, required this.report});

Future<void> approveReport(BuildContext context, String reportId) async {
  final supabase = Supabase.instance.client;

  // Ambil userId dari laporan
  final reportResponse = await supabase
      .from('reports')
      .select('userId')
      .eq('id', reportId)
      .single();

  final userId = reportResponse['userId'];

  if (userId == null) return;

  // Ambil poin saat ini dari profil
  final profileResponse = await supabase
      .from('profile')
      .select('points')
      .eq('id', userId)
      .single();

  final currentPoints = profileResponse['points'] ?? 0;
  final newPoints = currentPoints + 10;

  // Update poin di tabel profile
  await supabase
      .from('profile')
      .update({'points': newPoints})
      .eq('id', userId);

  // Update status laporan
  await supabase
      .from('reports')
      .update({'status': 'Disetujui'})
      .eq('id', reportId);

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Laporan berhasil disetujui & poin ditambahkan')));

    Navigator.pop(context, true);
  }
}


  @override
  Widget build(BuildContext context) {
    final description = report['description'] ?? '';
    final createdAt = report['created_at'] ?? '';
    final status = report['status'] ?? 'Belum Diketahui';
    final lat = double.tryParse(report['latitude'].toString()) ?? 0;
    final lng = double.tryParse(report['longitude'].toString()) ?? 0;
    final imagePath = report['image_url']?.toString();
    final imageUrl =
        (imagePath != null && imagePath.isNotEmpty)
            ? 'https://truudpslqifmtpphzmqe.supabase.co/storage/v1/object/public/images/$imagePath'
            : null;

    return Scaffold(
      appBar: AppBar(title: Text("Detail Laporan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(description),
            SizedBox(height: 12),
            Text("Waktu Laporan:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(createdAt.toString()),
            SizedBox(height: 12),
            Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(status),
            SizedBox(height: 20),
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              Text("Gambar:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text("Gagal memuat gambar.");
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
            Text("Lokasi:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 15.0),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (status != 'Disetujui')
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
                      onTap: () => approveReport(context, report['id'].toString()),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'Setujui Laporan',
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
    );
  }
}
