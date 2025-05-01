import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    leaderboardFetch();
  }

  final List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;
  void leaderboardFetch() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('profile')
        .select()
        .eq('role', 'User')
        .order('poin', ascending: false);

    if (!mounted) return; // Tambahkan ini supaya tidak freeze

    setState(() {
      leaderboardData.clear();
      for (var data in data) {
        leaderboardData.add({'name': data["username"], "score": data["poin"]});
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Visibility(
            visible: isLoading == true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Visibility(
            visible: isLoading == false,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                // Menentukan warna berdasarkan posisi
                Color backgroundColor = Colors.white;
                String medal = '';

                if (index == 0) {
                  backgroundColor = Colors.amber; // Emas
                  medal = '🥇';
                } else if (index == 1) {
                  backgroundColor = Colors.grey; // Perak
                  medal = '🥈';
                } else if (index == 2) {
                  backgroundColor = Color(0xFFcd7f32); // Perunggu
                  medal = '🥉';
                }

                return Card(
                  color: backgroundColor,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Text(medal, style: TextStyle(fontSize: 24)),
                    title: Text(leaderboardData[index]['name']),
                    trailing: Text('${leaderboardData[index]['score']}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
