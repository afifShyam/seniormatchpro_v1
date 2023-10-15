part of 'signup_authentication_bloc.dart';

class SignupAuthenticationEvent {
  final String username;
  final String email;
  final String password;
  final int id;

  SignupAuthenticationEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.id,
  });
}
