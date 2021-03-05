
part of 'LoginBloc.dart';

abstract class LoginEvent extends Equatable{
  const LoginEvent();
}

class LoginIDChanged extends LoginEvent{
  final String loginID;
  LoginIDChanged(this.loginID);
  @override
  List<Object> get props => [loginID];
}

class LoginPasswordChanged extends LoginEvent {
  final String loginPassword;

  LoginPasswordChanged(this.loginPassword);

  @override
  List<Object> get props => [loginPassword];
}
