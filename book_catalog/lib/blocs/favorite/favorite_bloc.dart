// blocs/favorite/favorite_bloc.dart
// BLoC untuk mengelola buku favorit yang disimpan secara lokal menggunakan Hive.
// Data favorit bisa diakses kembali meskipun tanpa koneksi internet.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class FavoriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {}

class ToggleFavorite extends FavoriteEvent {
  final BookModel book;
  ToggleFavorite(this.book);

  @override
  List<Object?> get props => [book.key];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class FavoriteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<BookModel> favorites;
  final Set<String> favoriteKeys; // untuk cek isFavorite secara O(1)

  FavoriteLoaded({required this.favorites})
      : favoriteKeys = favorites.map((b) => b.key).toSet();

  bool isFavorite(String key) => favoriteKeys.contains(key);

  @override
  List<Object?> get props => [favorites];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final BookService _bookService;

  FavoriteBloc({required BookService bookService})
      : _bookService = bookService,
        super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  void _onLoadFavorites(LoadFavorites event, Emitter<FavoriteState> emit) {
    final favorites = _bookService.getFavorites();
    emit(FavoriteLoaded(favorites: favorites));
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<FavoriteState> emit) async {
    await _bookService.toggleFavorite(event.book);
    // Reload favorites setelah perubahan
    final favorites = _bookService.getFavorites();
    emit(FavoriteLoaded(favorites: favorites));
  }
}
