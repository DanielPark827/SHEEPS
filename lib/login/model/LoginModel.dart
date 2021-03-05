import 'package:flutter/cupertino.dart';

class LoginModel {
  String _userID;
  String _userPassword;
  String _pageState;
  bool isValidForLogin;
  bool isValidForNextPage;

  factory LoginModel.empty() {
    return LoginModel("","", "NAME", false, false);
  }

  LoginModel(this._userID, this._userPassword, this._pageState, this.isValidForLogin, this.isValidForNextPage);

  LoginModel copyWith({String userName, String userID, String userPassword, String userConfirmPassword, String pageState, @required isValid, @required isValidPage}){
    return LoginModel(userID ?? this._userID, userPassword ?? this._userPassword,pageState ?? this._pageState, isValid, isValidPage);
  }

  LoginModel.fromJson(Map<String, dynamic> parsedJson){
    this._userID = parsedJson['userID'];
  }

  String get userID => _userID;
  String get userPassword => _userPassword;
  String get pageState => _pageState;
}