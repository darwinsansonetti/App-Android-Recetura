import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/perfil_repository.dart';

final perfilRepositoryProvider = Provider<PerfilRepository>(
  (_) => PerfilRepository(),
);

/// Estado de las operaciones del perfil
class PerfilState {
  final bool loading;
  final String? error;
  final String? successMessage;

  const PerfilState({this.loading = false, this.error, this.successMessage});

  PerfilState copyWith({
    bool? loading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) => PerfilState(
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
    successMessage: clearSuccess
        ? null
        : (successMessage ?? this.successMessage),
  );
}

class PerfilNotifier extends StateNotifier<PerfilState> {
  final PerfilRepository _repo;
  PerfilNotifier(this._repo) : super(const PerfilState());

  Future<bool> actualizarPerfil({
    String? name,
    String? apellido,
    String? telefono,
    String? celular,
    String? documentoIdentidad,
    String? fechaNacimiento,
    String? genero,
    String? direccion,
    String? ciudad,
    String? estadoProvincia,
    String? pais,
    String? codigoPostal,
  }) async {
    state = state.copyWith(loading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.actualizarPerfil(
        name: name,
        apellido: apellido,
        telefono: telefono,
        celular: celular,
        documentoIdentidad: documentoIdentidad,
        fechaNacimiento: fechaNacimiento,
        genero: genero,
        direccion: direccion,
        ciudad: ciudad,
        estadoProvincia: estadoProvincia,
        pais: pais,
        codigoPostal: codigoPostal,
      );
      state = const PerfilState(successMessage: 'Perfil actualizado');
      return true;
    } catch (e) {
      state = PerfilState(error: e.toString());
      return false;
    }
  }

  Future<bool> cambiarPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(loading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.cambiarPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = const PerfilState(successMessage: 'Contraseña actualizada');
      return true;
    } catch (e) {
      state = PerfilState(error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarDistribuidor({
    required String razonSocial,
    String? codigo,
    String? rif,
    String? zona,
    String? municipio,
    String? nacionalidad,
    bool? contribuyenteEspecial,
    String? sicm,
    String? maestro,
    String? observacion,
  }) async {
    state = state.copyWith(loading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.actualizarDistribuidor(
        razonSocial: razonSocial,
        codigo: codigo,
        rif: rif,
        zona: zona,
        municipio: municipio,
        nacionalidad: nacionalidad,
        contribuyenteEspecial: contribuyenteEspecial,
        sicm: sicm,
        maestro: maestro,
        observacion: observacion,
      );
      state = const PerfilState(
        successMessage: 'Datos del distribuidor actualizados',
      );
      return true;
    } catch (e) {
      state = PerfilState(error: e.toString());
      return false;
    }
  }

  void reset() => state = const PerfilState();
}

final perfilProvider = StateNotifierProvider<PerfilNotifier, PerfilState>(
  (ref) => PerfilNotifier(ref.read(perfilRepositoryProvider)),
);
