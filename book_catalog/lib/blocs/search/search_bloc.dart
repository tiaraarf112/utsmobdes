// blocs/search/search_bloc.dart
// BLoC untuk fitur pencarian buku dari kedua sumber (Open Library + Google Books).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchBooks extends SearchEvent {
  final String query;
  SearchBooks(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<BookModel> results;
  final String query;

  SearchLoaded({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}

class SearchEmpty extends SearchState {
  final String query;
  SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final BookService _bookService;

  SearchBloc({required BookService bookService})
      : _bookService = bookService,
        super(SearchInitial()) {
    on<SearchBooks>(_onSearchBooks);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchBooks(
      SearchBooks event, Emitter<SearchState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      // Cari dari keduanya secara bersamaan (paralel) lalu gabungkan
      final results = await Future.wait([
        _bookService.searchBooks(
            query: event.query, source: BookSource.openLibrary),
        _bookService.searchBooks(
            query: event.query, source: BookSource.googleBooks),
      ]);

      // Gabungkan: Open Library dulu, lalu Google Books Indonesia
      final combined = [...results[0], ...results[1]];

      if (combined.isEmpty) {
        emit(SearchEmpty(query: event.query));
      } else {
        emit(SearchLoaded(results: combined, query: event.query));
      }
    } catch (e) {
      emit(SearchError(message: 'Pencarian gagal. Coba lagi nanti.'));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
