// blocs/auth/auth_bloc.dart
// BLoC untuk mengelola state autentikasi pengguna (login/logout).
// Menggunakan AuthService untuk validasi dan penyimpanan token secara aman.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/auth_service.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email];
}

class LogoutRequested extends AuthEvent {}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;
  AuthAuthenticated({required this.username});

  @override
  List<Object?> get props => [username];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Cek apakah token masih tersimpan di secure storage saat aplikasi dibuka
  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final username = await _authService.getUsername() ?? 'User';
      emit(AuthAuthenticated(username: username));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// Proses login: validasi → simpan token di secure storage
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final success =
          await _authService.login(event.email, event.password);
      if (success) {
        emit(AuthAuthenticated(username: event.email));
      } else {
        emit(AuthError(message: 'Email atau password salah. Coba lagi.'));
      }
    } catch (e) {
      emit(AuthError(message: 'Terjadi kesalahan. Periksa koneksi Anda.'));
    }
  }

  /// Logout: hapus token dari secure storage
  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.logout();
    emit(AuthUnauthenticated());
  }
}
