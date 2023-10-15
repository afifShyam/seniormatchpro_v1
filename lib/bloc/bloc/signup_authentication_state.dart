// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'signup_authentication_bloc.dart';

enum SignupStatus {
  initial,
  loading,
  completed,
  error,
}

class SignupAuthenticationState extends Equatable {
  final SignupStatus signupStatus;
  final String error;
  final DatabaseReference databaseReference;

  const SignupAuthenticationState({
    required this.signupStatus,
    required this.error,
    required this.databaseReference,
  });

  factory SignupAuthenticationState.initial() {
    return SignupAuthenticationState(
      signupStatus: SignupStatus.initial,
      error: '',
      databaseReference: FirebaseDatabase.instance.ref().child('user/'),
    );
  }

  SignupAuthenticationState copyWith({
    SignupStatus? signupStatus,
    String? error,
    DatabaseReference? databaseReference,
  }) {
    return SignupAuthenticationState(
      signupStatus: signupStatus ?? this.signupStatus,
      error: error ?? this.error,
      databaseReference: databaseReference ?? this.databaseReference,
    );
  }

  @override
  List<Object> get props => [signupStatus, error, databaseReference];
}
