// pages/search_page.dart
// Halaman pencarian buku berdasarkan kata kunci.
// Menggunakan SearchBloc untuk menangani state pencarian secara asinkron.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../widgets/book_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_view.dart';
import 'book_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().length >= 3) {
      context.read<SearchBloc>().add(SearchBooks(query));
    } else if (query.isEmpty) {
      context.read<SearchBloc>().add(ClearSearch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search Bar ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cari Buku',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis...',
                  hintStyle: const TextStyle(color: Color(0xFF9D9DB5)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7B7BCC)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Color(0xFF9D9DB5)),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchBloc>().add(ClearSearch());
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E1E2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF7B7BCC), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Hasil Pencarian ──────────────────────────────────────────────
        Expanded(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                return const EmptyView(
                  icon: Icons.search_rounded,
                  title: 'Cari Buku',
                  subtitle: 'Ketik minimal 3 huruf untuk mulai mencari',
                );
              } else if (state is SearchLoading) {
                return const ShimmerBookList(itemCount: 4);
              } else if (state is SearchLoaded) {
                return BlocBuilder<FavoriteBloc, FavoriteState>(
                  builder: (context, favState) {
                    final favoriteKeys = favState is FavoriteLoaded
                        ? favState.favoriteKeys
                        : <String>{};
                    return ListView.builder(
                      itemCount: state.results.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (_, i) {
                        final book = state.results[i];
                        return BookCard(
                          book: book,
                          isFavorite: favoriteKeys.contains(book.key),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BookDetailPage(book: book)),
                          ),
                          onFavorite: () => context
                              .read<FavoriteBloc>()
                              .add(ToggleFavorite(book)),
                        );
                      },
                    );
                  },
                );
              } else if (state is SearchEmpty) {
                return EmptyView(
                  icon: Icons.search_off_rounded,
                  title: 'Tidak Ditemukan',
                  subtitle:
                      'Tidak ada buku dengan kata kunci "${state.query}"',
                );
              } else if (state is SearchError) {
                return ErrorView(message: state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
