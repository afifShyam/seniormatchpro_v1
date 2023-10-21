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
  }

  Future<void> _userSignUpUser(SignUpRealtimeDatabaseUser event,
      Emitter<SignupAuthenticationState> emit) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref().child('user/');

      emit(state.copyWith(signupStatus: SignupStatus.loading));

      final userData = {
        'id': event.id,
        'username': event.username,
        'email': event.email,
        'password': event.password,
      };

      //generate unique key
      final userRef = databaseReference.push();

      // Set user data at the generated reference
      await userRef.set(userData);

      emit(state.copyWith(
        signupStatus: SignupStatus.completed,
        databaseReference: userRef,
      ));
    } catch (e) {
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
}
