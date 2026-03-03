import 'users_api.dart';

class UsersRepository {
  UsersRepository({required UsersApi api}) : _api = api;

  final UsersApi _api;

  Future<void> setPin({required String pin, required String password}) async {
    await _api.setPin(pin: pin, password: password);
  }

  Future<void> resetPin({
    required String currentPin,
    required String newPin,
  }) async {
    await _api.resetPin(currentPin: currentPin, newPin: newPin);
  }

  Future<void> verifyPin({required String pin}) async {
    await _api.verifyPin(pin: pin);
  }
}
