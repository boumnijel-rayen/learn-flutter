import 'package:learn_flutter/services/auth/auth_provider.dart';
import 'package:learn_flutter/services/auth/auth_user.dart';


class AuthService implements AuthProvider {
  final AuthProvider provider;
  AuthService(this.provider);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<AuthUser> signUp({required String email, required String password}) {
    return provider.signUp(email: email, password: password);
  }

  
}