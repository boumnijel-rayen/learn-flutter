import 'package:learn_flutter/services/auth/auth_exceptions.dart';
import 'package:learn_flutter/services/auth/auth_provider.dart';
import 'package:learn_flutter/services/auth/auth_user.dart';
import 'package:test/test.dart';


void main() {
  group('Mock Authentification', () {
    final provider = MockAuthProvider();

    test('should to be initialized to begin with', (){
      expect(provider.isInitialized, false);
    });

    test('cannot log out if not initialized', (){
      expect(provider.logOut(),
      throwsA(const TypeMatcher<NotInitializedException>())
      );
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
          () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.signUp(
        email: 'ra.boumnije@gmail.com',
        password: 'anypassword',
      );

      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundException>()));

      final badPasswordUser = provider.signUp(
        email: 'ra.boumnijel@gmail.com',
        password: 'rayen12',
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordException>()));

      final user = await provider.signUp(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });

  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider{
  var _isInitialized = false;
  AuthUser? _user;
  bool get isInitialized => _isInitialized;


  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'ra.boumnijel@gmail.com') throw UserNotFoundException();
    if (password == 'rayen123') throw WrongPasswordException();
    const user = AuthUser(id: 'my_id' ,isEmailVerified: false, email: 'ra.boumnijel@gmail.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async{
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async{
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundException();
    const newUser = AuthUser(id : 'my_id',isEmailVerified: true, email: 'ra.boumnijel@gmail.com');
    _user = newUser;
  }

  @override
  Future<AuthUser> signUp({required String email, required String password}) async{
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

}