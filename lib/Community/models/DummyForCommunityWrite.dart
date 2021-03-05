import 'package:flutter/cupertino.dart';

class ProviderForCommmunityWrite with ChangeNotifier {
  String Title = null;
  String Description = null;
  String Topic = '등록위치 선택';
  bool Complete = false;

  bool GalleryChange = false;
  bool IfUnknown = false;

  String getTitle() => Title;
  String getDescription() => Description;
  bool getComplete() => Complete;

  bool getGalleryChange() => GalleryChange;
  bool getIfUnknown() => IfUnknown;

  void ChangeTopic(String value){
    Topic = value;
    notifyListeners();
  }
  void ChangeTitle(String value){
    Title = value;
    notifyListeners();
  }
  void ChangeDescription(String value){
    Description = value;
    notifyListeners();
  }
  void MakeCompleteOn(){
    Complete = true;
    notifyListeners();
  }
  void MakeCompleteOff(){
    Complete = false;
    notifyListeners();
  }

  void ChangeGallery(bool value){
    GalleryChange = value;
    notifyListeners();
  }
  void ChangeIfUnknown(){
    IfUnknown = !IfUnknown;
    notifyListeners();
  }

}