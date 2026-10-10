import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

class AuthState {
  final User? user;
  final bool loading;
  final String? error;

  const AuthState({this.user, this.loading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? loading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) => AuthState(
    user: clearUser ? null : (user ?? this.user),
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> bootstrap() async {
    debugPrint('AUTH: bootstrap inicio');
    state = state.copyWith(loading: true, clearError: true);
    try {
      debugPrint('AUTH: leyendo caché');
      User? cached;
      try {
        cached = await _repo.cachedUser().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('AUTH: caché falló: $e');
      }

      if (cached != null) {
        debugPrint('AUTH: usuario cacheado encontrado');
        state = state.copyWith(user: cached, loading: false);
      }

      debugPrint('AUTH: llamando me()');
      final fresh = await _repo.me().timeout(const Duration(seconds: 6));
      debugPrint('AUTH: me() OK');
      state = AuthState(user: fresh);
      return true;
    } catch (e) {
      debugPrint('AUTH: bootstrap error: $e');
      state = const AuthState();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.login(email: email, password: password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    String? apellido,
    required String email,
    required String password,
    String? telefono,
    String? celular,
    String? documentoIdentidad,
    String? fechaNacimiento,
    String? genero,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.register(
        name: name,
        apellido: apellido,
        email: email,
        password: password,
        telefono: telefono,
        celular: celular,
        documentoIdentidad: documentoIdentidad,
        fechaNacimiento: fechaNacimiento,
        genero: genero,
      );
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  /// Refresca el usuario desde la API (útil después de editar el perfil)
  Future<void> refresh() async {
    try {
      final fresh = await _repo.me().timeout(const Duration(seconds: 6));
      state = AuthState(user: fresh);
    } catch (e) {
      debugPrint('AUTH: refresh falló: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
