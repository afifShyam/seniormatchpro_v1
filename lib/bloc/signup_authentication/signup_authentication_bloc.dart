import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

part 'signup_authentication_event.dart';
part 'signup_authentication_state.dart';

class SignupAuthenticationBloc
    extends Bloc<SignupAuthenticationEvent, SignupAuthenticationState> {
  SignupAuthenticationBloc() : super(SignupAuthenticationState.initial()) {
    on<SignUpRealtimeDatabaseUser>(_userSignUpUser);
    on<SignUpAuthenticationUser>(_userSignUpAuth);
    on<SignInUser>(_signInUser);
  }

  //count currentUser
  Future<int> getNextId() async {
    // Get the current maximum ID from the database.
    final databaseReference =
        FirebaseDatabase.instance.ref().child('user/currentUser');
    final snapshot = await databaseReference.get();

    // If the maxId does not exist, initialize it to 0.
    int maxId = 0;
    if (snapshot.exists) {
      maxId = snapshot.value as int;
    }

    // Increment the maxId by 1.
    maxId++;

    // Set the new maxId in the database.
    await databaseReference.set(maxId);

    return maxId;
  }

  //sign up user in realtime database
  Future<void> _userSignUpUser(
    SignUpRealtimeDatabaseUser event,
    Emitter<SignupAuthenticationState> emit,
  ) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref().child('user/');

      emit(state.copyWith(signupStatus: SignupStatus.loading));

      // Get the next ID for the new user.
      final id = await getNextId();
      print('ID: $id');

      final userData = {
        'id': id,
        'username': event.username,
        'email': event.email,
        'password': event.password,
        'role': event.role,
      };

      // generate unique key
      final userRef = databaseReference.child('/$id');

      // Set user data at the generated reference
      await userRef.set(userData);

      emit(state.copyWith(
        signupStatus: SignupStatus.completed,
        databaseReference: userRef,
      ));
    } catch (e) {
      print('Error during signup: $e');
      emit(state.copyWith(
        signupStatus: SignupStatus.error,
        error: 'Error: $e',
      ));
    }
  }

  Future<void> _userSignUpAuth(SignUpAuthenticationUser event,
      Emitter<SignupAuthenticationState> emit) async {
    try {
      emit(
        state.copyWith(
          signupStatus: SignupStatus.loading,
        ),
      );

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: event.email, password: event.password);

      emit(
        state.copyWith(
          signupStatus: SignupStatus.completed,
          userCredential: userCredential,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Error $e'));
    }
  }

  /// Handles the `SignInUser` event.
  Future<void> _signInUser(
      SignInUser event, Emitter<SignupAuthenticationState> emit) async {
    try {
      emit(state.copyWith(signupStatus: SignupStatus.loading));

      final userLogin = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email, password: event.password);

      emit(state.copyWith(
        userLogin: userLogin,
        signupStatus: SignupStatus.completed,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Error $e'));
    }
  }
}
