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
  final UserCredential? userCredential;
  final UserCredential? userLogin;
  final File imageUpload;

  const SignupAuthenticationState({
    required this.signupStatus,
    required this.error,
    required this.databaseReference,
    this.userCredential,
    this.userLogin,
    required this.imageUpload,
  });

  factory SignupAuthenticationState.initial() {
    return SignupAuthenticationState(
      signupStatus: SignupStatus.initial,
      error: '',
      databaseReference: FirebaseDatabase.instance.ref().child('user/'),
      userCredential: null,
      userLogin: null,
      imageUpload: File(''),
    );
  }

  SignupAuthenticationState copyWith({
    SignupStatus? signupStatus,
    String? error,
    DatabaseReference? databaseReference,
    UserCredential? userCredential,
    UserCredential? userLogin,
    File? imageUpload,
  }) {
    return SignupAuthenticationState(
      signupStatus: signupStatus ?? this.signupStatus,
      error: error ?? this.error,
      databaseReference: databaseReference ?? this.databaseReference,
      userCredential: userCredential ?? this.userCredential,
      userLogin: userLogin ?? this.userLogin,
      imageUpload: imageUpload ?? this.imageUpload,
    );
  }

  // Add a method to check if the user is logged in.
  bool isLoggedIn() {
    return userLogin != null;
  }

  @override
  List<dynamic> get props => [
        signupStatus,
        error,
        databaseReference,
        userLogin,
        userCredential,
        imageUpload
      ];
}
