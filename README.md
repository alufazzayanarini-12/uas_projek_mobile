Rencana Kerja Pengembangan Aplikasi Tabungan Pribadi (Flutter)
Dokumen ini berisi panduan strategis dan teknis untuk membangun aplikasi tabungan pribadi yang aman, efisien, dan sesuai dengan standar aplikasi finansial.
1. Visi Produk
Menciptakan asisten finansial yang membantu pengguna mengelola dana simpanan, melacak pengeluaran, dan mencapai target finansial (seperti dana darurat, tabungan liburan, atau pembelian aset) melalui antarmuka yang intuitif.
2. Daftar Fitur Utama (Standard Features)
A. Manajemen Transaksi
●	Pencatatan Pemasukan & Pengeluaran: Input manual dengan kategori yang dapat disesuaikan.
●	Transfer antar Kantong: Fitur untuk memindahkan saldo dari satu kategori tabungan ke kategori lain.
●	Riwayat Transaksi: Daftar log aktivitas keuangan dengan filter berdasarkan tanggal atau kategori.
B. Manajemen Target (Saving Goals)
●	Target Tabungan: Pengguna bisa menentukan nama target (misal: "Beli Laptop"), nominal yang dibutuhkan, dan tenggat waktu.
●	Progress Tracker: Visualisasi dalam bentuk persentase atau progress bar untuk menunjukkan seberapa dekat pengguna dengan targetnya.
●	Auto-Saving Calculation: Rekomendasi jumlah yang harus ditabung setiap bulan/minggu untuk mencapai target tepat waktu.
C. Analisis & Laporan
●	Visualisasi Chart: Grafik lingkaran (pie chart) untuk komposisi pengeluaran dan grafik garis untuk pertumbuhan total tabungan.
●	Ringkasan Bulanan: Laporan total saldo bersih di akhir bulan.
D. Keamanan & Personalisasi
●	Autentikasi: Login menggunakan Email/Google atau Biometrik (Fingerprint/FaceID).
●	Dark Mode: Dukungan tema gelap untuk kenyamanan pengguna.
●	Backup Data: Sinkronisasi data ke cloud agar data tidak hilang saat berganti perangkat.
3. Rencana Kerja (Development Roadmap)
Fase	Durasi	Aktivitas Utama
Fase 1: Analisis & UI/UX	1 Minggu	Desain wireframe, pemilihan palet warna, dan pendefinisian skema database.
Fase 2: Setup & Arsitektur	1 Minggu	Inisialisasi proyek Flutter, setup arsitektur (Clean Architecture/MVVM), dan integrasi state management (Bloc/Provider/Riverpod).
Fase 3: Pengembangan Inti	3 Minggu	Implementasi fitur CRUD transaksi, manajemen saldo, dan logika perhitungan target tabungan.
Fase 4: Visualisasi & UI	1 Minggu	Implementasi library grafik (seperti fl_chart) dan pemolesan UI agar responsif.
Fase 5: Pengujian (QA)	1 Minggu	Unit testing, integration testing, dan perbaikan bug (Bug Fixing).
Fase 6: Deployment	1 Minggu	Persiapan rilis di Play Store (Android) dan App Store (iOS).
4. Rekomendasi Stack Teknologi (Flutter)
●	State Management: Riverpod atau Bloc (Direkomendasikan untuk aplikasi finansial karena skalabilitasnya).
●	Database Lokal: SQLite (melalui package sqflite) untuk performa tinggi atau Hive untuk database NoSQL yang cepat.
●	Backend/Cloud: Firebase Auth (Autentikasi) dan Firestore (Penyimpanan Data Cloud).
●	UI Components: Google Fonts (Lato/Inter) dan Lucide Icons untuk tampilan modern.
5. Standar Keamanan Data
1.	Enkripsi Lokal: Menggunakan kunci enkripsi untuk data sensitif yang disimpan di perangkat.
2.	Session Management: Otomatis logout atau meminta PIN setelah aplikasi tidak aktif dalam jangka waktu tertentu.
3.	Validasi Input: Memastikan tidak ada nilai negatif atau format data yang salah saat input nominal uang.
