// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'signup_authentication_bloc.dart';

abstract class SignupAuthenticationEvent {}

class SignUpRealtimeDatabaseUser extends SignupAuthenticationEvent {
  final String username;
  final String email;
  final String password;
  final String role;
  final File image;
  final String age;
  final String exp;
  final String phoneNum;

  SignUpRealtimeDatabaseUser({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.image,
    required this.age,
    required this.exp,
    required this.phoneNum,
  });
}

class SignUpAuthenticationUser extends SignupAuthenticationEvent {
  SignUpAuthenticationUser({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  String toString() => 'email : $email, password: $password';
}

class SignInUser extends SignupAuthenticationEvent {
  SignInUser({required this.email, required this.password});

  final String email;
  final String password;
}

class UploadImage extends SignupAuthenticationEvent {}
