# 📱Trash Track
Aplikasi Pelaporan dan Manajemen Sampah Digital

# 🧾 Deskripsi Aplikasi
Aplikasi Pelaporan dan Manajemen Sampah Digital adalah sebuah solusi berbasis mobile yang bertujuan untuk meningkatkan partisipasi masyarakat dalam menjaga kebersihan lingkungan. Aplikasi ini memungkinkan pengguna untuk melaporkan sampah yang menumpuk, melihat jadwal pengambilan sampah, memantau lokasi bank sampah, serta mengakses artikel edukatif seputar pengelolaan dan daur ulang sampah. Admin dapat memverifikasi laporan sampah, sementara leaderboard mendorong keterlibatan aktif pengguna dalam pengelolaan sampah secara kolektif.

# 📋 Fitur Aplikasi
🗑️ Lapor Sampah Menumpuk\
Pengguna dapat mengirimkan laporan lokasi sampah yang menumpuk disertai foto dan deskripsi.

📅 Jadwal Pengambilan Sampah\
Menampilkan jadwal pengambilan sampah berdasarkan lokasi pengguna agar warga tahu kapan sampah akan diambil.

✅ Verifikasi Sampah oleh Admin\
Laporan yang masuk akan diverifikasi oleh admin untuk menghindari spam atau laporan palsu.

🗺️ Lokasi Bank Sampah\
Menampilkan daftar dan peta lokasi bank sampah terdekat menggunakan OpenStreetMap.

🏆 Leaderboard\
Menampilkan peringkat pengguna berdasarkan kontribusi mereka dalam pelaporan dan pengelolaan sampah.

📚 Artikel Edukasi\
Berisi artikel seputar pengelolaan sampah, daur ulang, dan tips ramah lingkungan.

🔐 Autentikasi Pengguna\
Fitur login dan registrasi pengguna menggunakan Supabase Authentication.

# 🛠️ Teknologi yang Digunakan
⚙️ Flutter – Framework untuk membangun aplikasi mobile Android & iOS\
🛢️ Supabase – Backend open-source dengan autentikasi, database PostgreSQL, dan API\
🗺️ OpenStreetMap (via OpenFreemap plugin) – Menampilkan lokasi Bank Sampah pada peta interaktif

# 📂 Struktur Kode
```bash
lib/
├── main.dart 
├── screens/
│   ├── admin/       
│   │   ├── add_article.dart
│   │   ├── admin_home_page.dart
│   │   ├── detail_verification_page.dart
│   │   ├── list_article_page.dart
│   │   └── verification_report_page.dart
│   └── user/          
│       ├── add_report_page.dart
│       ├── bank_trash_location.dart
│       ├── detail_article_page.dart
│       ├── home_page.dart
│       ├── leaderboard_page.dart
│       ├── list_article_page.dart
│       ├── report_page.dart
│       ├── trash_pickup_schedule.dart
│   ├── login_page.dart     
│   └── register_page.dart    
```
