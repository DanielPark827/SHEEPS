import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/bloc/UserRepository.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:equatable/equatable.dart';

part 'RegistrationEvent.dart';
part 'RegistrationState.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final UserRepository _userRepository;
  String errMsg = '';

  RegistrationBloc(this._userRepository);

  @override
  RegistrationState get initialState => RegistrationInitial();

  @override
  Stream<RegistrationState> mapEventToState(RegistrationEvent event,) async* {
    if (event is UserNameChanged) {
      bool isValidModel = await isValidName(event.userName);
      yield RegistrationModelChanged(state.model
          .copyWith(
          userName: event.userName, errMsg: errMsg, isValid: isValidModel, isValidPage: false));
    }
    if (event is UserIDChanged) {
      bool isValidModel = await isValidID(event.userID);
      yield RegistrationModelChanged(state.model
          .copyWith(
          userID: event.userID, errMsg: errMsg, isValid: isValidModel, isValidPage: false));
    }
    if (event is PasswordChanged) {
      bool isValidModel = await isValidPassword(
          event.password, state.model.userConfirmPassword);
      yield RegistrationModelChanged(state.model
          .copyWith(userPassword: event.password, errMsg: errMsg,
          isValid: isValidModel,
          isValidPage: false));
    }
    if (event is ConfirmPasswordChanged) {
      bool isValidModel = await isValidConfirmPassword(
          state.model.userPassword, event.confirmPassword);
      yield RegistrationModelChanged(state.model.copyWith(
          userConfirmPassword: event.confirmPassword, errMsg: errMsg,
          isValid: isValidModel,
          isValidPage: false));
    }

    if (event is ConfirmPhoneNumberChanged) {
      bool isValidModel = await isValidPhoneNumber(event.confirmPhoneNumber);
      yield RegistrationModelChanged(state.model.copyWith(
          phoneNumber: event.confirmPhoneNumber, errMsg: errMsg,
          isValid: isValidModel,
          isValidPage: false));
    }

    if (event is PageChanged) {
      yield RegistrationModelChanged(state.model.copyWith(
          pageState: event.pageState, isValid: true, isValidPage: true));
    }
  }

  Future<bool> isValidName(String userName) async {
    int utf8Length = utf8.encode(userName).length;

    RegExp regExp = new RegExp(r'[$/!@#<>?":`~;[\]\\|=+)(*&^%\s-]');//허용문자 _.

    bool isCheck = true;
    if(regExp.hasMatch(userName)){
      isCheck = false;
      errMsg = "특수문자가 들어갈 수 없어요.";
    }else if(userName.length < 2){
      isCheck = false;
      errMsg = "너무 짧아요. 2자 이상 작성해주세요.";
    }else if(userName.length > 15 || utf8Length > 30){
      isCheck = false;
      errMsg = "너무 길어요. 한글 10자 또는 영어 15자 이하로 작성해 주세요.";
    }

    return isCheck;
  }

  Future<bool> isValidID(String userID) async {
    bool isValid = true;
    if(userID.length < 6){
      errMsg = "최소 6글자 이상의 아이디어야 해요.";
      isValid = false;
    }
    else{
      RegExp regExp = new RegExp(
          r'^[0-9a-zA-Z][0-9a-zA-Z\_\-\.\+]+[0-9a-zA-Z]@[0-9a-zA-Z][0-9a-zA-Z\_\-]*[0-9a-zA-Z](\.[a-zA-Z]{2,6}){1,2}$');


      if(regExp.hasMatch(userID)){
        var res = await ApiProvider().post('/Profile/Personal/IDCheck',jsonEncode({
          "id" : userID
        }));

        if(res != null){
          errMsg = "이미 등록된 아이디인걸요ㅠㅠ";
          isValid = false;
        }else{
          errMsg = "";
        }
      }else{
        errMsg = "올바르지 않은 이메일 형식입니다.";
        isValid = false;
      }
    }

    return isValid;
  }

  Future<bool> isValidPassword(String password, String confirmPassword) async {

    if(password == ''){
      errMsg = '';
      return false;
    }

    RegExp exp = new RegExp(r"^[A-Za-z\d$@$!%*#?&]{1,}$");
    if(!exp.hasMatch(password)){
      errMsg = "영문, 숫자, 특수문자를 사용해주세요.";
      return false;
    }

    if(password.length < 8){
      errMsg = '비밀번호가 너무 짧습니다.';
      return false;
    }

    if(confirmPassword == ''){
      errMsg = "비밀번호를 확인해주세요";
      return false;
    }

    return await isValidConfirmPassword(password, confirmPassword);
  }

  Future<bool> isValidConfirmPassword(String password, String confirmPassword) async {



    bool isConfirmPasswordMatched = false;
    if(password == confirmPassword){
      isConfirmPasswordMatched = true;
      errMsg = "";
    }else{
      errMsg = "비밀번호가 일치하지 않아요!";
    }

    return isConfirmPasswordMatched;
  }

  Future<bool> isValidPhoneNumber(String phoneNumber) async {
    errMsg = '';
    if (phoneNumber.length != 11){
      errMsg = "핸드폰 번호가 올바르지 않습니다.";
      return false;
    }


    return true;
  }
}
