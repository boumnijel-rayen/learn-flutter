import 'package:learn_flutter/services/auth/auth_user.dart';
import 'package:learn_flutter/services/auth/auth_exceptions.dart';
import 'package:learn_flutter/services/auth/auth_provider.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null){
      return AuthUser(isEmailVerified: user.emailVerified);
    }else{
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    // TODO: implement logIn
    throw UnimplementedError();
  }

  @override
  Future<void> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signUp({required String email, required String password}) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

}