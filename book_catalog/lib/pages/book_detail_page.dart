// pages/book_detail_page.dart
// Halaman detail buku yang menampilkan informasi lengkap sebuah buku.
// Menggunakan async (data book sudah diteruskan dari halaman sebelumnya)
// dan FutureBuilder pattern untuk mengelola animasi loading.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/book_model.dart';
import '../blocs/favorite/favorite_bloc.dart';

class BookDetailPage extends StatelessWidget {
  final BookModel book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: CustomScrollView(
        slivers: [
          // ── App Bar dengan gambar cover ────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
              ),
            ),
            actions: [
              // Tombol favorit di app bar
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  final isFav = state is FavoriteLoaded
                      ? state.isFavorite(book.key)
                      : false;
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
                            ? const Color(0xFFFF6B8A)
                            : Colors.white,
                      ),
                      onPressed: () {
                        context
                            .read<FavoriteBloc>()
                            .add(ToggleFavorite(book));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFav
                                ? '❤️ Dihapus dari favorit'
                                : '❤️ Ditambahkan ke favorit'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF2D2D44),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background blur cover
                  if (book.coverUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      fit: BoxFit.cover,
                      color: Colors.black54,
                      colorBlendMode: BlendMode.darken,
                    ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0F0F1E)],
                        stops: [0.5, 1],
                      ),
                    ),
                  ),
                  // Cover buku di tengah
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.coverUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: book.coverUrl,
                                width: 140,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 140,
                                height: 200,
                                color: const Color(0xFF2D2D44),
                                child: const Icon(Icons.menu_book,
                                    size: 60, color: Color(0xFF7B7BCC)),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Konten Detail ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Buku
                  Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Penulis
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF7B7BCC), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          book.authorNames.join(', '),
                          style: const TextStyle(
                              color: Color(0xFF7B7BCC),
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info chips (tahun terbit, ISBN)
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (book.firstPublishYear != null)
                        _InfoChip(
                            icon: Icons.calendar_today,
                            label: '${book.firstPublishYear}'),
                      if (book.isbn != null)
                        _InfoChip(icon: Icons.qr_code, label: book.isbn!),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Subjek / Topik buku
                  if (book.subjects.isNotEmpty) ...[
                    const Text(
                      'Topik',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: book.subjects
                          .take(8)
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2E),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFF2D2D44)),
                                ),
                                child: Text(s,
                                    style: const TextStyle(
                                        color: Color(0xFF9D9DB5),
                                        fontSize: 12)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7B7BCC), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7B7BCC)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Color(0xFF9D9DB5), fontSize: 12)),
        ],
      ),
    );
  }
}
