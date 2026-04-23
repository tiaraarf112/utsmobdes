// services/book_service.dart
// Service bertugas mengambil data buku dari dua sumber:
// 1. Open Library API  → buku internasional (programming, science, history, fiction, philosophy)
// 2. Google Books API  → buku Indonesia (langRestrict=id)
//
// Strategi:
// - Online  → ambil dari API → simpan ke Hive cache
// - Offline → ambil dari Hive cache (fallback)
// - Error   → ambil dari Hive cache (fallback)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/book_model.dart';

/// Nama box Hive untuk cache
const String kBooksBoxName = 'books_cache';
const String kFavoritesBoxName = 'favorites';

/// Enum sumber data
enum BookSource { openLibrary, googleBooks }

class BookService {
  static const String _openLibraryBase = 'https://openlibrary.org';
  static const String _googleBooksBase =
      'https://www.googleapis.com/books/v1/volumes';

  // Kategori Indonesia yang akan dicari ke Google Books
  static const Map<String, String> _indonesianQueries = {
    'novel': 'novel indonesia',
    'sejarah': 'sejarah indonesia',
    'budaya': 'budaya indonesia',
    'teknologi': 'teknologi indonesia',
    'bisnis': 'bisnis entrepreneur indonesia',
  };

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Mengambil buku berdasarkan query dan sumber.
  /// [query]  - kata kunci pencarian
  /// [source] - pilih sumber API (Open Library atau Google Books)
  Future<List<BookModel>> searchBooks({
    String query = 'programming',
    BookSource source = BookSource.openLibrary,
    int limit = 40,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    final cacheKey = '${source.name}_$query';

    if (!isOnline) {
      return _getBooksFromCache(cacheKey);
    }

    try {
      List<BookModel> books;
      if (source == BookSource.googleBooks) {
        books = await _fetchFromGoogleBooks(query, limit);
      } else {
        books = await _fetchFromOpenLibrary(query, limit);
      }

      if (books.isNotEmpty) {
        await _saveBooksToCache(books, cacheKey);
      }
      return books;
    } catch (e) {
      // Fallback ke cache jika terjadi error apapun
      return _getBooksFromCache(cacheKey);
    }
  }

  // ─── Open Library ──────────────────────────────────────────────────────────

  /// Mengambil buku dari Open Library API (buku internasional)
  Future<List<BookModel>> _fetchFromOpenLibrary(
      String query, int limit) async {
    final uri = Uri.parse(
        '$_openLibraryBase/search.json?q=${Uri.encodeComponent(query)}'
        '&limit=$limit&fields=key,title,author_name,first_publish_year,cover_i,subject,isbn');

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List docs = data['docs'] ?? [];
      return docs
          .map((j) => BookModel.fromOpenLibraryJson(j))
          .where((b) => _isValidYear(b.firstPublishYear))
          .toList();
    }
    return [];
  }

  // ─── Google Books ──────────────────────────────────────────────────────────

  /// Mengambil buku Indonesia dari Google Books API (langRestrict=id)
  /// Tidak memerlukan API Key untuk kuota dasar (2000 req/hari tanpa key)
  Future<List<BookModel>> _fetchFromGoogleBooks(
      String query, int limit) async {
    // Jika query adalah kode kategori Indonesia, terjemahkan ke query yang tepat
    final actualQuery =
        _indonesianQueries[query] ?? '$query indonesia';

    final uri = Uri.parse(
        '$_googleBooksBase?q=${Uri.encodeComponent(actualQuery)}'
        '&langRestrict=id&maxResults=$limit&orderBy=relevance');

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'] ?? [];
      return items
          .map((j) => BookModel.fromGoogleBooksJson(j))
          .where((b) => b.title.isNotEmpty && _isValidYear(b.firstPublishYear))
          .toList();
    }
    return [];
  }

  bool _isValidYear(int? year) {
    if (year == null) return true; // Jangan buang buku jika API tidak menyediakan tahun rilisnya
    return year >= 1990 && year <= 2026;
  }

  // ─── Favorites ─────────────────────────────────────────────────────────────

  /// Menambahkan atau menghapus buku dari daftar favorit (lokal - Hive)
  Future<void> toggleFavorite(BookModel book) async {
    final box = Hive.box(kFavoritesBoxName);
    if (box.containsKey(book.key)) {
      await box.delete(book.key);
    } else {
      await box.put(book.key, book.toJson());
    }
  }

  /// Mengecek apakah buku ada di daftar favorit
  bool isFavorite(String bookKey) {
    final box = Hive.box(kFavoritesBoxName);
    return box.containsKey(bookKey);
  }

  /// Mengambil semua buku favorit dari penyimpanan lokal
  List<BookModel> getFavorites() {
    final box = Hive.box(kFavoritesBoxName);
    return box.values
        .map((e) => BookModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ─── Cache ─────────────────────────────────────────────────────────────────

  Future<void> _saveBooksToCache(
      List<BookModel> books, String cacheKey) async {
    final box = Hive.box(kBooksBoxName);
    final cacheData = {
      'timestamp': DateTime.now().toIso8601String(),
      'books': books.map((b) => b.toJson()).toList(),
    };
    await box.put(cacheKey, cacheData);
  }

  List<BookModel> _getBooksFromCache(String cacheKey) {
    final box = Hive.box(kBooksBoxName);
    final cacheData = box.get(cacheKey);
    if (cacheData == null) return [];
    final List books = cacheData['books'] ?? [];
    return books
        .map((e) => BookModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
