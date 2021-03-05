
part of 'LoginBloc.dart';

abstract class LoginState extends Equatable {
  final LoginModel loginModel;
  const LoginState(this.loginModel);
}

class LoginInitial extends LoginState{
  LoginInitial() : super(LoginModel.empty());

  @override
  List<Object> get props =>[loginModel];
}

class LoginModelChanged extends LoginState{
  final LoginModel loginModel;
  LoginModelChanged(this.loginModel) : super(loginModel);

  @override
  List<Object> get props => [loginModel];
}

