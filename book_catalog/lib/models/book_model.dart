// models/book_model.dart
// Model data buku yang mendukung dua sumber API:
// 1. Open Library (buku internasional)
// 2. Google Books API (buku Indonesia - langRestrict=id)

class BookModel {
  final String key;
  final String title;
  final List<String> authorNames;
  final int? firstPublishYear;
  final String? coverId;
  final List<String> subjects;
  final String? isbn;
  final String? description;
  final String? publisher;
  final double? averageRating;

  /// Sumber data buku: 'openlibrary' atau 'google_books'
  final String source;

  /// URL cover langsung (diisi oleh Google Books, kosong untuk Open Library)
  final String? coverUrlDirect;

  BookModel({
    required this.key,
    required this.title,
    required this.authorNames,
    this.firstPublishYear,
    this.coverId,
    this.subjects = const [],
    this.isbn,
    this.description,
    this.publisher,
    this.averageRating,
    this.source = 'openlibrary',
    this.coverUrlDirect,
  });

  /// URL cover buku — otomatis pilih antara Google Books atau Open Library
  String get coverUrl {
    if (coverUrlDirect != null && coverUrlDirect!.isNotEmpty) {
      // Upgrade HTTP ke HTTPS untuk gambar Google Books
      return coverUrlDirect!.replaceFirst('http://', 'https://');
    }
    if (coverId != null && coverId!.isNotEmpty) {
      return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }
    return '';
  }

  /// Apakah buku ini dari koleksi Indonesia
  bool get isIndonesian => source == 'google_books';

  // ─── Factory: Open Library ─────────────────────────────────────────────────

  /// Mengonversi JSON dari Open Library API
  factory BookModel.fromOpenLibraryJson(Map<String, dynamic> json) {
    return BookModel(
      key: json['key'] ?? '',
      title: json['title'] ?? 'Judul Tidak Diketahui',
      authorNames: List<String>.from(json['author_name'] ?? []),
      firstPublishYear: json['first_publish_year'],
      coverId: json['cover_i']?.toString(),
      subjects: List<String>.from(json['subject'] ?? []),
      isbn: (json['isbn'] as List?)?.isNotEmpty == true
          ? (json['isbn'] as List).first
          : null,
      source: 'openlibrary',
    );
  }

  // ─── Factory: Google Books ─────────────────────────────────────────────────

  /// Mengonversi JSON dari Google Books API
  /// Struktur: { id, volumeInfo: { title, authors, publishedDate, imageLinks... } }
  factory BookModel.fromGoogleBooksJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks =
        volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    final industryIds =
        volumeInfo['industryIdentifiers'] as List? ?? [];

    // Ambil tahun dari publishedDate (format: "2008-11-01" atau "2008")
    int? publishYear;
    final pubDate = volumeInfo['publishedDate'] as String?;
    if (pubDate != null && pubDate.length >= 4) {
      publishYear = int.tryParse(pubDate.substring(0, 4));
    }

    // Ambil ISBN
    String? isbn;
    for (final id in industryIds) {
      if (id['type'] == 'ISBN_13') {
        isbn = id['identifier'];
        break;
      }
    }

    // Pilih cover thumbnail yang paling baik
    final thumbnail = imageLinks['thumbnail'] as String? ??
        imageLinks['smallThumbnail'] as String?;

    return BookModel(
      key: 'gb_${json['id']}', // prefix 'gb_' agar tidak tabrakan dengan Open Library
      title: volumeInfo['title'] ?? 'Judul Tidak Diketahui',
      authorNames: List<String>.from(volumeInfo['authors'] ?? []),
      firstPublishYear: publishYear,
      subjects: List<String>.from(volumeInfo['categories'] ?? []),
      isbn: isbn,
      description: volumeInfo['description'] as String?,
      publisher: volumeInfo['publisher'] as String?,
      averageRating: (volumeInfo['averageRating'] as num?)?.toDouble(),
      source: 'google_books',
      coverUrlDirect: thumbnail,
    );
  }

  // ─── Serialization (untuk Hive cache) ─────────────────────────────────────

  /// Menyimpan ke Hive cache — format universal (bisa untuk kedua sumber)
  Map<String, dynamic> toJson() {
    return {
      '_source': source,
      'key': key,
      'title': title,
      'author_name': authorNames,
      'first_publish_year': firstPublishYear,
      'cover_i': coverId != null ? int.tryParse(coverId!) : null,
      'subject': subjects,
      'isbn': isbn != null ? [isbn] : [],
      'description': description,
      'publisher': publisher,
      'average_rating': averageRating,
      'cover_url_direct': coverUrlDirect,
    };
  }

  /// Membaca dari Hive cache — otomatis deteksi sumber
  factory BookModel.fromJson(Map<String, dynamic> json) {
    final src = json['_source'] ?? 'openlibrary';
    return BookModel(
      key: json['key'] ?? '',
      title: json['title'] ?? 'Judul Tidak Diketahui',
      authorNames: List<String>.from(json['author_name'] ?? []),
      firstPublishYear: json['first_publish_year'],
      coverId: json['cover_i']?.toString(),
      subjects: List<String>.from(json['subject'] ?? []),
      isbn: (json['isbn'] as List?)?.isNotEmpty == true
          ? (json['isbn'] as List).first
          : null,
      description: json['description'],
      publisher: json['publisher'],
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      source: src,
      coverUrlDirect: json['cover_url_direct'],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String get primaryAuthor =>
      authorNames.isNotEmpty ? authorNames.first : 'Penulis Tidak Diketahui';

  String get subjectPreview => subjects.take(3).join(', ');
}
