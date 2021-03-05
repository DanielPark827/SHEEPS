import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';


class ImgProviderForAddTeam with ChangeNotifier {

  List<File> _files = [
  ];
  List<bool> FlagList = [false, false, false, false, false, false,];

  ImgProviderForAddTeam(){
    File f;
    _files.add(f);
  }

  List<File> get filesList => _files;


  void addFiles(File addFile) {
    _files.add(addFile);
    var tmp = _files[_files.length-1];
    removeFile(targetFile : _files[_files.length-2]);
    _files.add(tmp);
    notifyListeners();
    return;
  }
  void ChangeFlagList(int index, bool value) {
    FlagList[index] = value;

    notifyListeners();
  }


  void removeFile({File targetFile}) {
    int index = _files.indexOf(targetFile);
    if (index < 0) return;
    _files.removeAt(index);
    notifyListeners();
    return;
  }


  void swap(int i) {
    var tmp = filesList[i - 1];
    filesList[i - 1] = filesList[i];
    filesList[i] = tmp;
    notifyListeners();
  }


  void reset() {
    List<File> tmp = [];
    _files = tmp;
    notifyListeners();
  }
}
