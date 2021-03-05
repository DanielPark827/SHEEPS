import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
//import 'package:sheeps_app/network/Network.dart';
import 'LoginModel.dart';

part 'LoginEvent.dart';
part 'LoginState.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event,) async* {
    if (event is LoginIDChanged) {
      bool isValidModel = await isValidID(event.loginID);
      yield LoginModelChanged(state.loginModel
          .copyWith(
          loginID: event.loginID, isValid: isValidModel));
    }

    if (event is LoginPasswordChanged) {
      bool isValidModel = await isValidPassword(
          event.loginPassword);
      yield LoginModelChanged(state.loginModel
          .copyWith(loginPassword: event.loginPassword,
          isValid: isValidModel));
    }
  }

  Future<bool> isValidID(String userID) async {
    return true;
  }

  Future<bool> isValidPassword(String password) async {
    RegExp exp = new RegExp(
        r"^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{8,})");

    bool isValidPassword = true;
    return (isValidPassword);
  }
}
