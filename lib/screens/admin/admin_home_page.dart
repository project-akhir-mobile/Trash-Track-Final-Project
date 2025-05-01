import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trash_track/screens/admin/add_article.dart';
import 'package:trash_track/screens/admin/list_article_page.dart';
import 'package:trash_track/screens/admin/verification_report_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  void _logout() async {
    final supabase = Supabase.instance.client;
    if (!mounted) return;
    await supabase.auth.signOut();
    Navigator.pushReplacementNamed(
      context,
      '/login',
    );
  }

  int _currentIndex = 0;

  final List<Widget> _pages = [
    VerificationReportPage(),
    ListArticlePage(),
  ];

  String? _email;
  late Future _username;

  Future _fetchUsername() async {
    final supabase = Supabase.instance.client;
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      _email = session.user.email;
      final data =
          await supabase.from('profile').select().eq('email', _email!).single();
      if (!mounted) return;
      if (data.isNotEmpty) {
        return data['username'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data tidak ditemukan")),
        );
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Session atau user tidak ditemukan")),
      );
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _username = _fetchUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,

      // Background dan konten utama
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/bg_2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(color: Colors.black.withValues(alpha:  0.2)),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top:
                        kToolbarHeight +
                        36, // beri padding sesuai tinggi AppBar + sedikit jarak
                    bottom: kBottomNavigationBarHeight,
                  ),
                  child: _pages[_currentIndex],
                ),
              ),
            ],
          ),
        ],
      ),

      // AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha:  0.65),
                Colors.lightGreen.withValues(alpha:  0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: const [
                Icon(CupertinoIcons.leaf_arrow_circlepath, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Sampah Digital",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    CupertinoIcons.person_circle,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withValues(alpha:  0.65),
              Colors.lightGreen.withValues(alpha:  0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.done_all),
              label: 'Verifikasi Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: 'Tambah Artikel',
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
        ),
      ),

      // End Drawer
      endDrawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:  0.3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 50, color: Colors.white),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: _username,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Gagal memuat username',
                        style: TextStyle(color: Colors.white),
                      );
                    } else {
                      return Column(
                        children: [
                          Text(
                            snapshot.data ?? 'Username',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _email ?? 'user@example.com',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddArticlePage()),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
