import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<List<Map<String, dynamic>>> _futureReports;
  String? userId;

  Future<List<Map<String, dynamic>>> fetchReports() async {
    final supabase = Supabase.instance.client;
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      userId = session.user.id;
    }
    final data = await supabase
        .from('reports')
        .select()
        .eq('userId', userId!)
        .order('created_at', ascending: false);

    if (data.isEmpty) {
      return [];
    } else {
      return List<Map<String, dynamic>>.from(data);
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
                        ],
                      ),
                      subtitle: Text("Status: $status"),
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
