// blocs/book/book_bloc.dart
// BLoC untuk mengelola state daftar buku dari dua sumber:
// Open Library (internasional) dan Google Books (Indonesia).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class BookEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBooks extends BookEvent {
  final String query;
  final BookSource source;

  LoadBooks({
    this.query = 'programming',
    this.source = BookSource.openLibrary,
  });

  @override
  List<Object?> get props => [query, source];
}

class RefreshBooks extends BookEvent {
  final String query;
  final BookSource source;

  RefreshBooks({
    this.query = 'programming',
    this.source = BookSource.openLibrary,
  });

  @override
  List<Object?> get props => [query, source];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class BookState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

/// State saat data sedang dimuat dari API (UI akan tampilkan shimmer)
class BookLoading extends BookState {}

/// State saat data berhasil dimuat
class BookLoaded extends BookState {
  final List<BookModel> books;
  final bool fromCache;

  BookLoaded({required this.books, this.fromCache = false});

  @override
  List<Object?> get props => [books, fromCache];
}

/// State saat terjadi error
class BookError extends BookState {
  final String message;
  BookError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookService _bookService;

  BookBloc({required BookService bookService})
      : _bookService = bookService,
        super(BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<RefreshBooks>(_onRefreshBooks);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<BookState> emit) async {
    emit(BookLoading());

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult.contains(ConnectivityResult.none);

      final books = await _bookService.searchBooks(
        query: event.query,
        source: event.source,
      );

      // Kita bisa punya success state meskipun buku kosong (empty state)
      if (books.isEmpty) {
        if (isOffline) {
          emit(BookError(message: 'Gagal memuat buku. Anda offline dan belum ada cache.'));
        } else {
          emit(BookLoaded(books: const [], fromCache: false));
        }
      } else {
        emit(BookLoaded(books: books, fromCache: isOffline));
      }
    } catch (e) {
      emit(BookError(
          message: 'Terjadi kesalahan sistem. Silakan coba lagi.'));
    }
  }

  Future<void> _onRefreshBooks(
      RefreshBooks event, Emitter<BookState> emit) async {
    try {
      final books = await _bookService.searchBooks(
        query: event.query,
        source: event.source,
      );
      if (books.isNotEmpty) {
        emit(BookLoaded(books: books));
      }
    } catch (_) {
      // Biarkan state lama, tidak error
    }
  }
}
