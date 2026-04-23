// pages/favorites_page.dart
// Halaman daftar buku favorit yang disimpan secara lokal menggunakan Hive.
// Data favorit dapat diakses tanpa koneksi internet.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../widgets/book_card.dart';
import '../widgets/error_view.dart';
import 'book_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buku Favorit ❤️',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tersimpan lokal – bisa diakses tanpa internet',
                style: TextStyle(color: Color(0xFF9D9DB5), fontSize: 13),
              ),
            ],
          ),
        ),

        Expanded(
          child: BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              if (state is FavoriteLoaded) {
                if (state.favorites.isEmpty) {
                  return const EmptyView(
                    icon: Icons.favorite_border_rounded,
                    title: 'Belum Ada Favorit',
                    subtitle:
                        'Tap ikon ❤️ pada buku untuk menyimpannya di sini',
                  );
                }

                return ListView.builder(
                  itemCount: state.favorites.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (_, i) {
                    final book = state.favorites[i];
                    return BookCard(
                      book: book,
                      isFavorite: true,
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
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
