// main.dart
// Entry point aplikasi Book Catalog.
// Menginisialisasi Hive (cache lokal), menyediakan semua BLoC via MultiBlocProvider,
// dan menjalankan aplikasi mulai dari SplashPage.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/book_service.dart';
import 'services/auth_service.dart';

import 'blocs/book/book_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/favorite/favorite_bloc.dart';
import 'blocs/auth/auth_bloc.dart';

import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk caching data buku dan favorit
  await Hive.initFlutter();
  await Hive.openBox(kBooksBoxName);
  await Hive.openBox(kFavoritesBoxName);

  runApp(const BookCatalogApp());
}

class BookCatalogApp extends StatelessWidget {
  const BookCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi service
    final bookService = BookService();
    final authService = AuthService();

    return MultiBlocProvider(
      // Menyediakan semua BLoC ke seluruh widget tree
      providers: [
        BlocProvider(
          create: (_) => BookBloc(bookService: bookService),
        ),
        BlocProvider(
          create: (_) => SearchBloc(bookService: bookService),
        ),
        BlocProvider(
          create: (_) => FavoriteBloc(bookService: bookService),
        ),
        BlocProvider(
          create: (_) => AuthBloc(authService: authService),
        ),
      ],
      child: MaterialApp(
        title: 'Book Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0F1E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7B7BCC),
            secondary: Color(0xFFFF6B8A),
            surface: Color(0xFF1E1E2E),
          ),
          fontFamily: 'sans-serif',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1A2E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A2E),
            selectedItemColor: Color(0xFF7B7BCC),
            unselectedItemColor: Color(0xFF9D9DB5),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
