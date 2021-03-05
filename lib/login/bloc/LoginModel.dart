import 'package:flutter/material.dart';

class LoginModel{
  String _loginID;
  String _loginPassword;
  bool isValidForLogin;

  factory LoginModel.empty(){
    return LoginModel("","",false);
  }

  LoginModel(this._loginID,this._loginPassword,this.isValidForLogin);

  LoginModel copyWith({String loginID, String loginPassword,loginConfirmPassword, @required isValid}){
    return LoginModel(loginID ?? this._loginID, loginPassword??this._loginPassword, isValid);
  }

  LoginModel.fromJson(Map<String, dynamic> parsedJson){
    this._loginID = parsedJson['loginID'];
  }

  String get loginID => _loginID;
  String get loginPassword => _loginPassword;
}