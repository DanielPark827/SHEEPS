part of 'RegistrationBloc.dart';


// ignore: camel_case_types
abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();
}

class UserNameChanged extends RegistrationEvent {
  final String userName;
  UserNameChanged(this.userName);
  @override
  List<Object> get props => [userName];
}

class UserIDChanged extends RegistrationEvent {
  final String userID;
  UserIDChanged(this.userID);
  @override
  List<Object> get props => [userID];
}

class PasswordChanged extends RegistrationEvent{
  final String password;
  PasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordChanged extends RegistrationEvent{
  final String confirmPassword;
  ConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object> get props => [confirmPassword];
}

class ConfirmPhoneNumberChanged extends RegistrationEvent{
  final String confirmPhoneNumber;
  ConfirmPhoneNumberChanged(this.confirmPhoneNumber);

  @override
  List<Object> get props => [confirmPhoneNumber];
}

class PageChanged extends RegistrationEvent{
  final String pageState;
  PageChanged(this.pageState);

  @override
  List<Object> get props => [pageState];
}
