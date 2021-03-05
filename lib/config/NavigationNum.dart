import 'package:flutter/material.dart';

class NavigationNum extends ChangeNotifier{
  int pastNum = -1;
  int _num = 0;

  int getNum() => _num;
  int getPastNum() => pastNum;

  void setNum(int num){
    setPastNum(_num);
    _num = num;
    notifyListeners();
  }
  void setPastNum(int num){
    pastNum = num;
    notifyListeners();
  }

  void setNormalPastNum(int num) {
    pastNum = num;
  }
}

