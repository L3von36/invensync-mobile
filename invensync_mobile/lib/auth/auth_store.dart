import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'token_storage.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final String? error;
  final bool requires2FA;
  final String? pendingUserId;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
    this.requires2FA = false,
    this.pendingUserId,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? error,
    bool? requires2FA,
    String? pendingUserId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      requires2FA: requires2FA ?? this.requires2FA,
      pendingUserId: pendingUserId ?? this.pendingUserId,
    );
  }
}