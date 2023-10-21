part of 'signup_authentication_bloc.dart';

abstract class SignupAuthenticationEvent {}

class SignUpRealtimeDatabaseUser extends SignupAuthenticationEvent {
  final String username;
  final String email;
  final String password;

  SignUpRealtimeDatabaseUser({
    required this.username,
    required this.email,
    required this.password,
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
