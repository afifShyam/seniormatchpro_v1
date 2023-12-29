import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

part 'signup_authentication_event.dart';
part 'signup_authentication_state.dart';

class SignupAuthenticationBloc
    extends Bloc<SignupAuthenticationEvent, SignupAuthenticationState> {
  SignupAuthenticationBloc() : super(SignupAuthenticationState.initial()) {
    on<SignUpRealtimeDatabaseUser>(_userSignUpUser);
    on<SignUpAuthenticationUser>(_userSignUpAuth);
    on<SignInUser>(_signInUser);
    on<UploadImage>(_uploadImage);
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
      print('ID: ${state.imageUpload}');

      final userData = {
        'id': id,
        'username': event.username,
        'email': event.email,
        'password': event.password,
        'role': event.role,
        'image': event.image,
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

  Future<void> _uploadImage(UploadImage event, Emitter emit) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageUp = File(pickedFile.path);

        emit(
          state.copyWith(
            imageUpload: imageUp,
            signupStatus: SignupStatus.loading,
          ),
        );

        UploadTask imageUploaded = FirebaseStorage.instance
            .ref()
            .child('images')
            .child('${DateTime.now()}.png')
            .putFile(imageUp);

        TaskSnapshot snapshot = await imageUploaded;
        String imageUrl = await snapshot.ref.getDownloadURL();

        if (imageUrl.isNotEmpty) {
          emit(
            state.copyWith(
              imageUrl: imageUrl,
              signupStatus: SignupStatus.completed,
            ),
          );
        } else {
          emit(
            state.copyWith(
              signupStatus: SignupStatus.error,
              error: 'Error: Image URL is null.',
            ),
          );
        }

        // Log the image URL for verification
        log('Image URL: $imageUrl');
      }
    } catch (e) {
      emit(
        state.copyWith(
          signupStatus: SignupStatus.error,
          error: 'Error uploading image: $e',
        ),
      );
      log('Error uploading image: $e');
    }
  }
}
