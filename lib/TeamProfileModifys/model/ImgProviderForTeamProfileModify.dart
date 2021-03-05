import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';


class ImgProviderForTeamProfileModify with ChangeNotifier {

  List<File> _files = [
  ];


  ImgProviderForTeamProfileModify(){
    File f;
    _files.add(f);
  }

  List<File> get filesList => _files;
  List<bool> FlagList = [false, false, false, false, false, false,];
  void addFiles(File addFile) {
    _files.add(addFile);
    FlagList[_files.length-1] = true;
    var tmp = _files[_files.length-1];
    removeFile(targetFile : _files[_files.length-2]);
    _files.add(tmp);
    notifyListeners();
    return;
  }


  void removeFile({File targetFile}) {
    int index = _files.indexOf(targetFile);
    if (index < 0) return;
    FlagList[_files.length-1] = false;
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
