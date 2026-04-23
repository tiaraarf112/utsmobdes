// widgets/book_card.dart
// Komponen kartu buku yang reusable, ditampilkan di halaman home dan pencarian.
// Kartu ini bertanggung jawab menampilkan gambar cover, judul, penulis, dan tahun terbit.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover Buku ──────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: book.coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          width: 90,
                          height: 130,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _buildCoverPlaceholder(),
                          errorWidget: (_, __, ___) => _buildCoverPlaceholder(),
                        )
                      : _buildCoverPlaceholder(),
                ),
                if (book.isIndonesian)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF7B7BCC), width: 0.5),
                      ),
                      child: const Text(
                        '🇮🇩 ID',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info Buku ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Color(0xFF9D9DB5)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.primaryAuthor,
                            style: const TextStyle(
                                color: Color(0xFF9D9DB5), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (book.firstPublishYear != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Color(0xFF9D9DB5)),
                          const SizedBox(width: 4),
                          Text(
                            '${book.firstPublishYear}',
                            style: const TextStyle(
                                color: Color(0xFF9D9DB5), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                    if (book.subjectPreview.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        book.subjectPreview,
                        style: const TextStyle(
                          color: Color(0xFF7B7BCC),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Tombol Favorit ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? const Color(0xFFFF6B8A)
                      : const Color(0xFF9D9DB5),
                ),
                onPressed: onFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      width: 90,
      height: 130,
      color: const Color(0xFF2D2D44),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, color: Color(0xFF7B7BCC), size: 32),
        ],
      ),
    );
  }
}
