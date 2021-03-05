import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class Career {
  String CareerValue;
  int CareerState;

  Career(this.CareerValue,this.CareerState);
}

class Certification {
  String CertificationValue;
  int CertificationState;

  Certification(this.CertificationValue,this.CertificationState);
}

class Award {
  String AwardValue;
  int AwardState;

  Award(this.AwardValue,this.AwardState);
}

class ModifiedProfile with ChangeNotifier {

  bool FlagForCareer = false;
  bool FlagForCertification = false;
  bool FlagForAward = false;
  bool IfThisSubField = false;
  bool IfThisGraduateSchool = false;
  bool ProfileModifyClear = false;

  //내 프로필 수정
  String name = GlobalProfile.loggedInUser.name;
  String major = GlobalProfile.loggedInUser.major;
  String part = GlobalProfile.loggedInUser.part;
  String subPart = GlobalProfile.loggedInUser.subPart;
  String subMajor =GlobalProfile.loggedInUser.subMajor;
  String location =GlobalProfile.loggedInUser.location;
  bool FlagForLocation = false;

  String MainLocation = null;
  String SubLocation = null;
  String Introduce = GlobalProfile.loggedInUser.information;

  String University = GlobalProfile.loggedInUser.UserUnivList != null && GlobalProfile.loggedInUser.UserUnivList.length != 0 ? GlobalProfile.loggedInUser.UserUnivList[0].PfLicenseContents : null;
  int UniversityState = GlobalProfile.loggedInUser.UserUnivList != null && GlobalProfile.loggedInUser.UserUnivList.length != 0 ? GlobalProfile.loggedInUser.UserUnivList[0].PfLicenseAuth : null;
  String GraduateSchool = GlobalProfile.loggedInUser.UserGraduateList != null && GlobalProfile.loggedInUser.UserGraduateList.length != 0 ? GlobalProfile.loggedInUser.UserGraduateList[0].PfGraduateName : null;
  int GraduateSchoolState = GlobalProfile.loggedInUser.UserGraduateList != null && GlobalProfile.loggedInUser.UserGraduateList.length != 0 ? GlobalProfile.loggedInUser.UserGraduateList[0].PfGraduateAuth : null;

  //경력
  String Company = null;
  String Role =null;
  bool IfHoldOffice = false;
  List<bool> IfHoldOfficeList = [];
  String Start = null;
  String End = null;
  int Years = 0;
  int StartYears = 0;
  int EndYears = 0;
  bool CareerUploadComplete =false;
  bool IfAddCareerComplete = false;

  List<Career> CareerList = GlobalProfile.loggedInUser.careerList;

  //자격증
  String CertificationName = null;
  String CertificationAgency = null;
  bool IfHaveVality = false;
  String CertificationStart = null;
  String CertificationEnd = null;
  bool CertificationUploadComplete = false;
  bool IfAddCertificationComplete = false;

  List<Certification> CertificationList = GlobalProfile.loggedInUser.CertificationList;

  //수상경력
  String AwardName = null;
  String AwardGrader = null;
  String AwardAgency = null;
  String AwardTime = null;
  bool AwardUploadComplete = false;
  bool IfAddAwardComplete = false;

  List<Award> AwardList = GlobalProfile.loggedInUser.AwardList;


  //뱃지
  List<String> BadgeList = [];

  List<File> CareerFile = []; //1\
  List<bool> FlagCareerFile = [false, false, false, false, false, false, false, false, false, false, ];
  List<File> CertificationFile = []; //2
  List<bool> FlagCertificationFile = [false, false, false, false, false, false, false, false, false, false, ];
  List<File> AwardFile = []; //3
  List<bool> FlagAwardFile = [false, false, false, false, false, false, false, false, false, false, ];

  bool AddTeamComplete = false;

  List<String> CareerStart = [];
  List<String> CareerEnd = [];

  File UnivFile = null;
  File GraduateFile = null;

  void Reset() {
    FlagForCareer = false;
    FlagForCertification = false;
    FlagForAward = false;
    IfThisSubField = false;
    IfThisGraduateSchool = false;
    ProfileModifyClear = false;

    //내 프로필 수정
    name = GlobalProfile.loggedInUser.name;
    major = GlobalProfile.loggedInUser.major;
    subMajor =GlobalProfile.loggedInUser.subMajor;
    location =GlobalProfile.loggedInUser.location;
    FlagForLocation = false;

    MainLocation = null;
    SubLocation = null;
    Introduce = GlobalProfile.loggedInUser.information;

    University = GlobalProfile.loggedInUser.UserUnivList != null && GlobalProfile.loggedInUser.UserUnivList.length != 0 ? GlobalProfile.loggedInUser.UserUnivList[0].PfLicenseContents : null;
    UniversityState = GlobalProfile.loggedInUser.UserUnivList != null && GlobalProfile.loggedInUser.UserUnivList.length != 0 ? GlobalProfile.loggedInUser.UserUnivList[0].PfLicenseAuth : null;
    GraduateSchool = GlobalProfile.loggedInUser.UserGraduateList != null && GlobalProfile.loggedInUser.UserGraduateList.length != 0 ? GlobalProfile.loggedInUser.UserGraduateList[0].PfGraduateName : null;
    GraduateSchoolState = GlobalProfile.loggedInUser.UserGraduateList != null && GlobalProfile.loggedInUser.UserGraduateList.length != 0 ? GlobalProfile.loggedInUser.UserGraduateList[0].PfGraduateAuth : null;

    //경력
    Company = null;
    Role =null;
    IfHoldOffice = false;
    IfHoldOfficeList = [];
    Start = null;
    End = null;
    Years = 0;
    StartYears = 0;
    EndYears = 0;
    CareerUploadComplete =false;
    IfAddCareerComplete = false;

    CareerList = GlobalProfile.loggedInUser.careerList;

    //자격증
    CertificationName = null;
    CertificationAgency = null;
    IfHaveVality = false;
    CertificationStart = null;
    CertificationEnd = null;
    CertificationUploadComplete = false;
    IfAddCertificationComplete = false;

    CertificationList = GlobalProfile.loggedInUser.CertificationList;

    //수상경력
    AwardName = null;
    AwardGrader = null;
    AwardAgency = null;
    AwardTime = null;
    AwardUploadComplete = false;
    IfAddAwardComplete = false;

    AwardList = GlobalProfile.loggedInUser.AwardList;


    //뱃지
    BadgeList = [];

    CareerFile = []; //1\
    FlagCareerFile = [false, false, false, false, false, false, false, false, false, false, ];
    CertificationFile = []; //2
    FlagCertificationFile = [false, false, false, false, false, false, false, false, false, false, ];
    AwardFile = []; //3
    FlagAwardFile = [false, false, false, false, false, false, false, false, false, false, ];

    AddTeamComplete = false;

    CareerStart = [];
    CareerEnd = [];

    UnivFile = null;
    GraduateFile = null;
  }

  void ChangePart(String value) {
    part = value;
    notifyListeners();
  }
  void ChangeSubPart(String value) {
    subPart = value;
    notifyListeners();
  }

  void ChangeUnivFile(File file) {
    UnivFile = file;
    notifyListeners();
  }
  void ChangeGraduateFile(File file) {
    GraduateFile = file;
    notifyListeners();
  }

  void AddIfHoldOfficeList(bool value) {
    IfHoldOfficeList.add(value);
  }
  void RemoveIfHoldOfficeList(int index) {
    IfHoldOfficeList.removeAt(index);
  }

  void AddCareerStartAndEnd(String Start,String End) {
    CareerStart.add(Start);
    CareerEnd.add(End);
    notifyListeners();
  }
  void removeCareerStartAndEnd(int index) {
    CareerStart.removeAt(index);
    CareerEnd.removeAt(index);
  }


  void resetModifiedProfile() {
    Company = null;
    Role =null;
    IfHoldOffice = false;
    Start = null;
    End = null;

    CertificationName = null;
    CertificationAgency = null;

    AwardName = null;
    AwardGrader = null;
    AwardAgency = null;
    AwardTime = null;
    notifyListeners();
  }

  void ChangeAddTeamComplete(bool value) {
    AddTeamComplete = value;
    notifyListeners();
  }

  void addFiles(File addFile, int target) {
    if(target == 1) {
      CareerFile.add(addFile);
      FlagCareerFile[CareerFile.length-1] = true;//CareerList에 대한 Length로 바꾸는게..?
//      var tmp = IdentifiedFile[IdentifiedFile.length-1];
//      removeFile(IdentifiedFile[IdentifiedFile.length-2],1);
//      IdentifiedFile.add(tmp);
      notifyListeners();
      return;
    } else if(target == 2) {
      CertificationFile.add(addFile);
      FlagCertificationFile[FlagCertificationFile.length-1] = true;
//      var tmp = ProjectFile[ProjectFile.length-1];
//      removeFile(ProjectFile[ProjectFile.length-2],2);
//      ProjectFile.add(tmp);
      notifyListeners();
      return;
    } else {
      AwardFile.add(addFile);
      FlagAwardFile[FlagAwardFile.length-1] = true;
//      var tmp = AwardFile[AwardFile.length-1];
//      removeFile(AwardFile[AwardFile.length-2],3);
//      AwardFile.add(tmp);
      notifyListeners();
      return;
    }
  }
  void removeFile(File targetFile,int target) {
    if(target == 1) {
      int index = CareerFile.indexOf(targetFile);
      if (index < 0) return;
      FlagCareerFile[index] = false;
      CareerFile.removeAt(index);
      notifyListeners();
      return;
    } else if(target == 2) {
      int index = CertificationFile.indexOf(targetFile);
      if (index < 0) return;
      FlagCertificationFile[index] = false;
      CertificationFile.removeAt(index);
      notifyListeners();
      return;
    } else {
      int index = AwardFile.indexOf(targetFile);
      if (index < 0) return;
      FlagAwardFile[index] = true;
      AwardFile.removeAt(index);
      notifyListeners();
      return;
    }
  }
  void removeEndFile(int target) {
    if(target == 1) {
      FlagCareerFile[CareerFile.length-1] = false;
      CareerFile.removeAt(CareerFile.length-1);
      notifyListeners();
      return;
    } else if(target == 2) {
      FlagCertificationFile[FlagCertificationFile.length-1] = false;
      CertificationFile.removeAt(CertificationFile.length-1);
      notifyListeners();
      return;
    } else {
      FlagAwardFile[FlagAwardFile.length-1] = true;
      AwardFile.removeAt(AwardFile.length-1);
      notifyListeners();
      return;
    }
  }

  //경력 추가
  void ChangeCareerStateListComponet(int index, int value) {
    CareerList[index].CareerState = value;
    notifyListeners();
  }
  void AddCareerList(String value) {
    CareerList.add(new Career(value,2));
    notifyListeners();
  }
  void RemoveCareerList(int index) {
    CareerList.removeAt(index);
    if(CareerFile.length != 0) {
      CareerFile.removeAt(index);
    }
    if(CareerStart.length != 0) {
      CareerStart.removeAt(index);
    }
    if(CareerEnd.length != 0) {
      CareerEnd.removeAt(index);
    }
//    CareerStateList.removeAt(index);
    notifyListeners();
  }

  //자격증 추가
  void ChangeCertificationStateListComponet(int index, int value) {
    CertificationList[index].CertificationState = value;
    notifyListeners();
  }
  void AddCertificationList(String value) {
    CertificationList.add(new Certification(value, 2));
    notifyListeners();
  }
  void RemoveCertificationList(int index) {
    CertificationList.removeAt(index);
    if(CertificationFile.length != 0) {
      CertificationFile.removeAt(index);
    }
    //    CertificationStateList.removeAt(index);
    notifyListeners();
  }

  //수상 경력 추가
  void ChangeAwardStateListComponet(int index, int value) {
    AwardList[index].AwardState = value;
    notifyListeners();
  }
  void AddAwardList (String value) {
    AwardList.add(new Award(value,2));
    notifyListeners();
  }
  void RemoveAwardList (int index) {
    AwardList.removeAt(index);
    if(AwardFile.length != 0) {
      AwardFile.removeAt(index);
    }
    //    AwardStateList.removeAt(index);
    notifyListeners();
  }

  //Badge
  void AddBadgeList (String value) {
    BadgeList.add(value);
    notifyListeners();
  }
  void RemoveBadgeList (int index) {
    BadgeList.removeAt(index);
    notifyListeners();
  }

  //Flag
  void MakeFlagForCareerOn() {
    FlagForCareer = true;
    FlagForCertification = false;
    FlagForAward = false;
    notifyListeners();
  }
  void MakeFlagForAwardOn() {
    FlagForCareer = false;
    FlagForCertification = false;
    FlagForAward = true;
    notifyListeners();
  }
  void MakeFlagForCertificationOn() {
    FlagForCareer = false;
    FlagForCertification = true;
    FlagForAward = false;
    notifyListeners();
  }
  void ChangeIfThisSubField(bool value) {
    IfThisSubField = value;
    notifyListeners();
  }
  void ChangeIfThisGraduateSchool(bool value) {
    IfThisGraduateSchool = value;
    notifyListeners();
  }

  //
  void ChangeProfileModifyClear(bool value) {
    ProfileModifyClear = value;
    notifyListeners();
  }
  void ChangeName(String value) {
    name = value;
    notifyListeners();
  }
  void ChangeCareerMainField(String value){
    major = value;
    notifyListeners();
  }
  void ChangeSubField (String value){
    subMajor  = value;
    notifyListeners();
  }
  void ChangeAreaByAdd (bool check,String value){
    if(check == true) {
      location += value;
    }
    else {
      location = value;
    }
    notifyListeners();
  }
  void ChangeFlagForTeamArea(bool value) {
    FlagForLocation = value;
    notifyListeners();
  }

  void ChangeUniversity (String value){
    University  = value;
    notifyListeners();
  }
  void ChangeUniversityState(int value) {
    UniversityState = value;
    notifyListeners();
  }
  void ChangeGraduateSchool (String value){
    GraduateSchool  = value;
    notifyListeners();
  }
  void ChangeGraduateSchoolState(int value) {
    GraduateSchoolState = value;
    notifyListeners();
  }
  void ChangeIntroduce (String value){
    Introduce  = value;
    notifyListeners();
  }

  //수상경력
  void ChangeAwardName(String value) {
    AwardName = value;
    notifyListeners();
  }
  void ChangeAwardGrader (String value) {
    AwardGrader = value;
    notifyListeners();
  }
  void ChangeAwardAgency (String value) {
    AwardAgency  = value;
    notifyListeners();
  }
  void ChangeAwardTime (String value) {
    AwardTime  = value;
    notifyListeners();
  }

  void ChangeAwardUploadComplete(bool value){
    AwardUploadComplete = value;
    notifyListeners();
  }
  void ChangeIfAddAwardComplete(bool value){
    IfAddAwardComplete = value;
    notifyListeners();
  }

  //자격증
  void ChangeCertificationName(String value) {
    CertificationName = value;
    notifyListeners();
  }
  void ChangeAgency(String value) {
    CertificationAgency = value;
    notifyListeners();
  }
  void ChangeIfHaveVality() {
    IfHaveVality = !IfHaveVality;
    notifyListeners();
  }
  void ChangeCertificationStart(String value) {
    CertificationStart = value;
    notifyListeners();
  }
  void ChangeCertificationEnd(String value) {
    CertificationEnd = value;
    notifyListeners();
  }
  ChangeCertificationUploadComplete(bool value) {
    CertificationUploadComplete = value;
    notifyListeners();
  }
  ChangeIfAddCertificationComplete(bool value) {
    IfAddCertificationComplete = value;
    notifyListeners();
  }

  //경력
  void ChangeMainField(String value) {
    major = value;
    notifyListeners();
  }
  void ChangeCareerCompany(String value) {
    Company = value;
    notifyListeners();
  }
  void ChangeCareerRole(String value) {
    Role = value;
    notifyListeners();
  }
  void ChangeCareerIfHoldOffice() {
    IfHoldOffice = !IfHoldOffice;
    notifyListeners();
  }
  void ChangeCareerStart(String value) {
    Start = value;
    notifyListeners();
  }
  void ChangeCareerEnd(String value) {
    End = value;
    notifyListeners();
  }
  void ChangeCareerYears(int value) {
    Years = value;
    notifyListeners();
  }
  void ChangeCareerStartYears(int value) {
    StartYears = value;
    notifyListeners();
  }
  void ChangeCareerEndYears(int value) {
    EndYears = value;
    notifyListeners();
  }
  void ChangeCareerUploadComplete(bool value) {
    CareerUploadComplete = value;
    notifyListeners();
  }
  void MakeIfAddCareerCompleteOn() {
    IfAddCareerComplete = true;
    notifyListeners();
  }
  void MakeIfAddCareerCompleteOff() {
    IfAddCareerComplete = false;
    notifyListeners();
  }

  void SetData(UserData user){
    name = user.name;
    part = user.part;
    subPart = user.subPart;
    major = getFieldCategory(user.part);
    subMajor = getFieldCategory(user.subPart);
    location = user.location + ' ' + user.subLocation;
    Introduce = user.information;

    CareerList.clear();
    if(user.UserCareerList != null){
      for(int i = 0; i < user.UserCareerList.length; i++) {
        Career item = new Career("${user.UserCareerList[i].PfCareerContents}",user.UserCareerList[i].PfCareerAuth);
        CareerList.add(item);
        CareerStart.add(user.UserCareerList[i].PfCareerStart);
        CareerEnd.add(user.UserCareerList[i].PfCareerDone);
      }
    }

    CertificationList.clear();
    if(user.UserLicenseList != null){
      for(int i = 0; i < user.UserLicenseList.length; i++) {
        Certification item = new Certification("${user.UserLicenseList[i].PfLicenseContents}", user.UserLicenseList[i].PfLicenseAuth);
        CertificationList.add(item);
      }
    }

    AwardList.clear();
    if(user.UserWinList != null){
      for(int i = 0; i < user.UserWinList.length; i++) {
        Award item = new Award("${user.UserWinList[i].PfWinContents}",user.UserWinList[i].PfWinAuth);
        AwardList.add(item);
      }
    }

    if(user.UserUnivList != null){
      if(user.UserUnivList.length == 0) {
        University = null;
        UniversityState = 2;
      } else {
        University = user.UserUnivList[0].PfLicenseContents;
        UniversityState = user.UserUnivList[0].PfLicenseAuth;
      }
    }

    if(user.UserGraduateList != null){
      if(user.UserGraduateList.length==0) {
        GraduateSchool = null;
        GraduateSchoolState = 2;
      } else {
        GraduateSchool = user.UserGraduateList[0].PfGraduateName;
        GraduateSchoolState = user.UserGraduateList[0].PfGraduateAuth;;
      }
    }
  }

  void CheckForMyProfile(){
    if( name != null && major != null && location != null && Introduce != null &&
        name != "" && major != "" &&  location != "" &&  Introduce != "") {
      ProfileModifyClear = true;
    } else {
      ProfileModifyClear = false;
    }
  }
}
