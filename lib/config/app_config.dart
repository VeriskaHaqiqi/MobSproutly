class AppConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  // static const String baseUrl = 'http://192.168.1.8:8000/api'; // Untuk di mobile sesuaikan ip yang didapat dari menjalankan ipconfig dan di backendnya jalanin php artisan serve --host=0.0.0.0 --port=8000
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
