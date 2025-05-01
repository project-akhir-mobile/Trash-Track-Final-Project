import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_article_page.dart';

class ListArticlePage extends StatefulWidget {
  const ListArticlePage({super.key});

  @override
  State<ListArticlePage> createState() => _ListArticlePageState();
}

class _ListArticlePageState extends State<ListArticlePage> {
  late Future<List<Map<String, dynamic>>> _futureArticles;

  Future<List<Map<String, dynamic>>> fetchArticles() async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('articles')
        .select()
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
    _futureArticles = fetchArticles();
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
              'Artikel Edukasi Sampah',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureArticles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final articles = snapshot.data ?? [];

              if (articles.isEmpty) {
                return Center(child: Text('Belum ada artikel.'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: articles.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      title: Text(article['title'] ?? 'Tanpa Judul'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            article['content'].toString().length > 100
                                ? '${article['content'].toString().substring(0, 100)}...'
                                : article['content'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Kategori: ${article['category'] ?? 'Tidak ada'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            'Penulis: ${article['author'] ?? 'Tidak diketahui'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    DetailArticlePage(article: article),
                          ),
                        );
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
