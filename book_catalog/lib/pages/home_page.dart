// pages/home_page.dart
// Halaman utama aplikasi yang menampilkan katalog buku dari API.
// Menggunakan BLoC untuk mengelola state loading, loaded, dan error.
// Menampilkan shimmer saat loading dan daftar buku saat data berhasil dimuat.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/book/book_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../widgets/book_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_view.dart';
import '../models/book_model.dart';
import 'book_detail_page.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;
  final List<String> _categories = [
    'novel', 'programming', 'science', 'history', 'fiction', 'philosophy'
  ];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    // Memuat buku saat halaman pertama kali dibuka (async - tidak freeze UI)
    context.read<BookBloc>().add(LoadBooks(query: _categories[0]));
    context.read<FavoriteBloc>().add(LoadFavorites());
  }

  void _loadCategory(int index) {
    setState(() => _selectedCategory = index);
    context.read<BookBloc>().add(LoadBooks(query: _categories[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _buildHomeTab(),
            const SearchPage(),
            const FavoritesPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book Catalog 📚',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return Text(
                          'Halo, ${state.username.split('@').first}!',
                          style: const TextStyle(
                              color: Color(0xFF9D9DB5), fontSize: 13),
                        );
                      }
                      return const Text('Jelajahi ribuan buku',
                          style: TextStyle(
                              color: Color(0xFF9D9DB5), fontSize: 13));
                    },
                  ),
                ],
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      if (state is AuthAuthenticated) {
                        context.read<AuthBloc>().add(LogoutRequested());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LoginPage()));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        state is AuthAuthenticated
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                        color: const Color(0xFF7B7BCC),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ── Kategori chips ──────────────────────────────────────────────
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final isSelected = i == _selectedCategory;
              return GestureDetector(
                onTap: () => _loadCategory(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF7B7BCC), Color(0xFFFF6B8A)])
                        : null,
                    color: isSelected ? null : const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _categories[i][0].toUpperCase() +
                        _categories[i].substring(1),
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF9D9DB5),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ── Daftar Buku ─────────────────────────────────────────────────
        Expanded(
          child: BlocConsumer<BookBloc, BookState>(
            listener: (context, state) {
              if (state is BookError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFFF6B8A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is BookLoading) {
                // Tampilkan shimmer saat data sedang dimuat
                return const ShimmerBookList(itemCount: 6);
              } else if (state is BookLoaded) {
                if (state.books.isEmpty) {
                  return const EmptyView(
                    title: 'Tidak ada data ditemukan',
                    subtitle: 'Buku yang Anda cari kosong.',
                  );
                }
                return Column(
                  children: [
                    if (state.fromCache)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B8A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF6B8A), width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.wifi_off_rounded, color: Color(0xFFFF6B8A), size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mode Offline Aktif', 
                                    style: TextStyle(color: Color(0xFFFF6B8A), fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text('Menampilkan koleksi buku versi cadangan.', 
                                    style: TextStyle(color: Color(0xFFFF6B8A), fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: _buildBookList(state.books)),
                  ],
                );
              } else if (state is BookError) {
                return ErrorView(
                  message: state.message,
                  actionLabel: 'Coba Lagi',
                  onAction: () => context.read<BookBloc>().add(
                      LoadBooks(query: _categories[_selectedCategory])),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookList(List<BookModel> books) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favState) {
        final favoriteKeys = favState is FavoriteLoaded
            ? favState.favoriteKeys
            : <String>{};

        return RefreshIndicator(
          color: const Color(0xFF7B7BCC),
          backgroundColor: const Color(0xFF1E1E2E),
          onRefresh: () async {
            context.read<BookBloc>().add(
                RefreshBooks(query: _categories[_selectedCategory]));
          },
          child: ListView.builder(
            itemCount: books.length,
            padding: const EdgeInsets.only(bottom: 20, top: 4),
            itemBuilder: (_, i) => BookCard(
              book: books[i],
              isFavorite: favoriteKeys.contains(books[i].key),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BookDetailPage(book: books[i])),
              ),
              onFavorite: () => context
                  .read<FavoriteBloc>()
                  .add(ToggleFavorite(books[i])),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Color(0xFF2D2D44), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF7B7BCC),
        unselectedItemColor: const Color(0xFF9D9DB5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Cari'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded), label: 'Favorit'),
        ],
      ),
    );
  }
}
