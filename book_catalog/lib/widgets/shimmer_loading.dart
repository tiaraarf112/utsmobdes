// widgets/shimmer_loading.dart
// Widget loading kreatif menggunakan efek Shimmer.
// Menampilkan skeleton/placeholder kartu buku saat data masih dimuat dari API.
// Ini memberikan feedback visual yang lebih baik daripada spinner biasa.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBookList extends StatelessWidget {
  final int itemCount;

  const ShimmerBookList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, __) => const _ShimmerBookCard(),
    );
  }
}

class _ShimmerBookCard extends StatelessWidget {
  const _ShimmerBookCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        // Warna shimmer yang kontras dengan background gelap
        baseColor: const Color(0xFF2D2D44),
        highlightColor: const Color(0xFF3D3D5C),
        child: Row(
          children: [
            // Placeholder gambar cover
            Container(
              width: 90,
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D44),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder judul
                    _ShimmerBox(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    _ShimmerBox(width: 180, height: 14),
                    const SizedBox(height: 12),
                    // Placeholder penulis
                    _ShimmerBox(width: 120, height: 12),
                    const SizedBox(height: 8),
                    // Placeholder tahun
                    _ShimmerBox(width: 80, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Widget loading untuk halaman detail buku
class ShimmerDetailPage extends StatelessWidget {
  const ShimmerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2D2D44),
      highlightColor: const Color(0xFF3D3D5C),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 160,
                height: 230,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ShimmerBox(width: double.infinity, height: 22),
            const SizedBox(height: 10),
            _ShimmerBox(width: 200, height: 16),
            const SizedBox(height: 20),
            _ShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            _ShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            _ShimmerBox(width: 250, height: 14),
          ],
        ),
      ),
    );
  }
}
