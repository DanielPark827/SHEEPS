import 'package:flutter/material.dart';

class ProfileState extends ChangeNotifier{
  int _num = 0;
  Color _color = Color(0xff888888);
  Color _color2 = Color(0xffffffff);

  Color getColor() => _color;
  Color getColor2() => _color2;

  void changeColor(){
    if(_color == Color(0xff888888)){
      _color = Color(0xffffffff);
    }
    else{
      _color = Color(0xff888888);
    }
  }
  void changeColor2(){
    if(_color2 == Color(0xff888888)){
      _color2 = Color(0xffffffff);
    }
    else{
      _color2 = Color(0xff888888);
    }
  }


  int getNum() => _num;

  void setNum(int num){
    _num = num;
    notifyListeners();
  }
}
