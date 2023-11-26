part of 'signup_authentication_bloc.dart';

abstract class SignupAuthenticationEvent {}

class SignUpRealtimeDatabaseUser extends SignupAuthenticationEvent {
  final String username;
  final String email;
  final String password;
  final String role;
  // final File image;

  SignUpRealtimeDatabaseUser({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    // required this.image,
  });
}

class SignUpAuthenticationUser extends SignupAuthenticationEvent {
  SignUpAuthenticationUser({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignInUser extends SignupAuthenticationEvent {
  SignInUser({required this.email, required this.password});

  final String email;
  final String password;
}
