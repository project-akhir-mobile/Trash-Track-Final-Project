import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trash_track/screens/admin/detail_verification_page.dart';

class VerificationReportPage extends StatefulWidget {
  const VerificationReportPage({super.key});

  @override
  State<VerificationReportPage> createState() => _VerificationReportPageState();
}

class _VerificationReportPageState extends State<VerificationReportPage> {
  late Future<List<Map<String, dynamic>>> _futureReports;
  String? userId;

  Future<List<Map<String, dynamic>>> fetchReports() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('reports')
        .select()
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      return [];
    } else {
      return List<Map<String, dynamic>>.from(response);
    }
  }

  Future<void> approveReport(String reportId) async {
    final supabase = Supabase.instance.client;

    // Ambil laporan berdasarkan ID untuk dapatkan userId
    final reportResponse =
        await supabase
            .from('reports')
            .select('userId')
            .eq('id', reportId)
            .single();

    final userId = reportResponse['userId'];

    if (userId == null) return;

    final profileResponse =
        await supabase
            .from('profile')
            .select('poin')
            .eq('id', userId)
            .single();

    final currentpoin = profileResponse['poin'] ?? 0;

    final newpoin = currentpoin + 100;

    // Update poin di tabel profile
    await supabase
        .from('profile')
        .update({'poin': newpoin})
        .eq('id', userId);

    // Update status laporan jadi Disetujui
    await supabase
        .from('reports')
        .update({'status': 'Disetujui'})
        .eq('id', reportId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan disetujui & poin ditambahkan')),
      );

      // Refresh data
      setState(() {
        _futureReports = fetchReports();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _futureReports = fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Laporan User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureReports,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final reports = snapshot.data ?? [];

              if (reports.isEmpty) {
                return Column(
                  children: [
                    SizedBox(height: 25),
                    Center(
                      child: Container(
                        color: Colors.white,
                        height: 35.0,
                        width: 350.0,
                        child: Center(
                          child: Text(
                            'Belum ada laporan yang anda buat.',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: reports.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final status = report['status'];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            report['description'].toString().length > 40
                                ? '${report['description'].toString().substring(0, 40)}...'
                                : report['description'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text("Status: $status"),
                          if (status !=
                              'Disetujui') // hanya tampil jika belum acc
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: Icon(Icons.check, color: Colors.green),
                                label: Text(
                                  'ACC',
                                  style: TextStyle(color: Colors.green),
                                ),
                                onPressed:
                                    () =>
                                        approveReport(report['id'].toString()),
                              ),
                            ),
                        ],
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DetailVerificationPage(report: report),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            _futureReports = fetchReports();
                          });
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
