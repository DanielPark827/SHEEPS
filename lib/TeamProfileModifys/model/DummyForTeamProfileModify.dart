import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';

enum TeamIdentifiedType {Complete, Proceed, Reject}

class ModelTeamProfile with ChangeNotifier {

  bool FlagForIdentified = false;
  bool FlagForProject = false;
  bool FlagForTeamAward = false;

  String TeamName = null;
  String TeamCategory = null;
  String TeamField = null;
  String TeamArea = '';
  bool FlagForTeamArea = false;
  bool IfSupportTeam = false;
  String TeamIntroduce = null;

  //인증
  String IdentifiedName = null;
  String IdentifiedAgency = null;
  bool IfAddIdentifiedUploadComplete = false;
  bool IfAddIdentifiedComplete = null;
  List<String> IdentifiedList = [];
  List<int> IdentifiedStateList = [];

  //수행 내역
  String ProjectName = null;
  String ProjectAgency = null;
  String ProjectStart = null;
  String ProjectEnd = null;
  bool IfAddProjectUploadComplete = false;
  bool IfAddProjectComplete = false;
  List<String> ProjectList = [];
  List<int> ProjectStateList = [];


  //수상경력
  String TeamAwardName = null;
  String TeamAwardGrade = null;
  String TeamAwardAgency = null;
  String TeamAwardTime =null;
  bool IfAddTeamAwardUploadComplte = false;
  bool IfAddTeamAwardComplete = false;
  List<String> TeamAwardList = [];
  List<int>  TeamAwardStateList = [];

  int badge1 = 0;
  int badge2 = 0;
  int badge3 = 0;

  List<File> IdentifiedFile = []; //1
  List<File> ProjectFile = []; //2
  List<File> AwardFile = []; //3

  bool AddTeamComplete = false;


  void resetModelAddTeam() {
    FlagForIdentified = false;
    FlagForProject = false;
    FlagForTeamAward = false;

    TeamName = null;
    TeamCategory = null;
    TeamField = null;
    TeamArea = '';
    FlagForTeamArea = false;
    IfSupportTeam = false;
    TeamIntroduce = null;

    //인증
    IdentifiedName = null;
    IdentifiedAgency = null;
    IfAddIdentifiedUploadComplete = false;
    IfAddIdentifiedComplete = null;
    IdentifiedList = [];
    IdentifiedStateList = [];

    //수행 내역
    ProjectName = null;
    ProjectAgency = null;
    ProjectStart = null;
    ProjectEnd = null;
    IfAddProjectUploadComplete = false;
    IfAddProjectComplete = false;
    ProjectList = [];
    ProjectStateList = [];


    //수상경력
    TeamAwardName = null;
    TeamAwardGrade = null;
    TeamAwardAgency = null;
    TeamAwardTime =null;
    IfAddTeamAwardUploadComplte = false;
    IfAddTeamAwardComplete = false;
    TeamAwardList = [];
    TeamAwardStateList = [];

    badge1 = 0;
    badge2 = 0;
    badge3 = 0;

    IdentifiedFile = []; //1
    ProjectFile = []; //2
    AwardFile = []; //3

    AddTeamComplete = false;
  }

  void ChangeAddTeamComplete(bool value) {
    AddTeamComplete = value;
    notifyListeners();
  }

  List<bool> FlagIdentifiedList = [false,false,false,false,false,false,false,false,false,false,];
  List<bool> FlagProjectList = [false,false,false,false,false,false,false,false,false,false,];
  List<bool> FlagTeamAwardList = [false,false,false,false,false,false,false,false,false,false,];
  void addFiles(File addFile, int target) {
    if(target == 1) {
      IdentifiedFile.add(addFile);
      FlagIdentifiedList[IdentifiedFile.length-1] = true;
//      var tmp = IdentifiedFile[IdentifiedFile.length-1];
//      removeFile(IdentifiedFile[IdentifiedFile.length-2],1);
//      IdentifiedFile.add(tmp);
      notifyListeners();
      return;
    } else if(target == 2) {
      ProjectFile.add(addFile);
      FlagProjectList[ProjectFile.length-1] = true;
//      var tmp = ProjectFile[ProjectFile.length-1];
//      removeFile(ProjectFile[ProjectFile.length-2],2);
//      ProjectFile.add(tmp);
      notifyListeners();
      return;
    } else {
      AwardFile.add(addFile);
      FlagTeamAwardList[AwardFile.length-1] = true;
//      var tmp = AwardFile[AwardFile.length-1];
//      removeFile(AwardFile[AwardFile.length-2],3);
//      AwardFile.add(tmp);
      notifyListeners();
      return;
    }
  }
  void removeEndFile(int target) {
    if(target == 1) {
      FlagIdentifiedList[IdentifiedFile.length-1] = false;
      IdentifiedFile.removeAt(IdentifiedFile.length-1);
      notifyListeners();
      return;
    } else if(target == 2) {
      FlagProjectList[ProjectFile.length-1] = false;
      ProjectFile.removeAt(ProjectFile.length-1);
      notifyListeners();
      return;
    } else {
      FlagTeamAwardList[AwardFile.length-1] = false;
      AwardFile.removeAt(AwardFile.length-1);
      notifyListeners();
      return;
    }
  }

  void removeFile(File targetFile,int target) {
    if(target == 1) {
      int index = IdentifiedFile.indexOf(targetFile);
      if (index < 0) return;
      IdentifiedFile.removeAt(index);
      FlagIdentifiedList[index] = false;
      notifyListeners();
      return;
    } else if(target == 2) {
      int index = ProjectFile.indexOf(targetFile);
      if (index < 0) return;
      ProjectFile.removeAt(index);
      FlagProjectList[index] = false;
      notifyListeners();
      return;
    } else {
      int index = AwardFile.indexOf(targetFile);
      if (index < 0) return;
      AwardFile.removeAt(index);
      FlagTeamAwardList[index] = false;
      notifyListeners();
      return;
    }
  }
  void reset(int target) {
    if(target == 1) {
      List<File> tmp = [];
      IdentifiedFile = tmp;
      notifyListeners();
    } else if(target == 2) {
      List<File> tmp = [];
      ProjectFile = tmp;
      notifyListeners();
    } else {
      List<File> tmp = [];
      AwardFile = tmp;
      notifyListeners();
    }
  }

  void ChangeBadge1(int value, int index) {
    if(index == 1) {
      badge1 = value;
    } else if(index == 2) {
      badge2 = value;
    } else {
      badge3 = value;
    }
    notifyListeners();
  }

  String getIdentifiedListComponent(int index) => IdentifiedList[index];
  void ChangeIdentifiedStateList(int index,int value) {
    IdentifiedStateList[index] = value;
    notifyListeners();
  }
  void AddIdentifiedList(String value) {
    IdentifiedList.add(value);
    IdentifiedStateList.add(3);
    notifyListeners();
  }
  void RemoveIdentifiedListAndFile (int index) {
    IdentifiedList.removeAt(index);
    IdentifiedStateList.removeAt(index);
    if(IdentifiedFile.length != 0 ) {
      IdentifiedFile.removeAt(index);
    }
    notifyListeners();
  }

  String getProjectListComponent(int index) => ProjectList[index];
  void ChangeProjectStateList(int index,int value) {
    ProjectStateList[index] = value;
    notifyListeners();
  }
  void AddProjectList(String value) {
    ProjectList.add(value);
    ProjectStateList.add(3);
    notifyListeners();
  }
  void RemoveProjectListAndFile (int index) {
    ProjectList.removeAt(index);
    ProjectStateList.removeAt(index);
    if(ProjectFile.length != 0) {
      ProjectFile.removeAt(index);
    }
    notifyListeners();
  }

  String getTeamAwardListComponent(int index) => TeamAwardList[index];
  void ChangeTeamAwardStateList(int index,int value) {
    TeamAwardStateList[index] = value;
    notifyListeners();
  }
  void AddTeamAwardList(String value) {
    TeamAwardList.add(value);
    TeamAwardStateList.add(3);
    notifyListeners();
  }
  void RemoveTeamAwardListAndFile (int index) {
    TeamAwardList.removeAt(index);
    TeamAwardStateList.removeAt(index);
    if(AwardFile.length != 0) {
      AwardFile.removeAt(index);
    }
    notifyListeners();
  }

  //get함수


  String getTeamName() => TeamName;
  String getTeamCategory() => TeamCategory;
  String getTeamField() => TeamField;
  String getTeamArea() => TeamArea;
  bool getIfSupportTeam() => IfSupportTeam;
  String getTeamIntroduce() => TeamIntroduce;

  String getTeamAwardName() => TeamAwardName;
  String getTeamAwardGrade() => TeamAwardGrade;
  String getTeamAwardAgency() => TeamAwardAgency;
  String getTeamAwardTime() => TeamAwardTime;
  bool getIfAddAwardUploadComplte() => IfAddTeamAwardUploadComplte;
  bool getIfAddAwardClear() => IfAddTeamAwardComplete;


  //Flag
  void ChangeFlagForIdentifiedOn(bool value) {
    FlagForIdentified = value;
    FlagForProject = false;
    FlagForTeamAward = false;
  }
  void ChangeFlagForProjectOn(bool value) {
    FlagForIdentified = false;
    FlagForProject = value;
    FlagForTeamAward = false;
  }
  void ChangeFlagForTeamAwardOn(bool value) {
    FlagForIdentified = false;
    FlagForProject = false;
    FlagForTeamAward = value;
  }

  void ChangeIfAddIdentifiedComplete(bool value) {
    IfAddIdentifiedComplete = value;
    notifyListeners();
  }
  void ChangeIfAddProjectComplete(bool value) {
    IfAddProjectComplete = value;
    notifyListeners();
  }
  void ChangeIfAddTeamAwardComplete(bool value) {
    IfAddTeamAwardComplete = value;
    notifyListeners();
  }

  void ChangeIfAddIdentifiedUploadComplete(bool value) {
    IfAddIdentifiedUploadComplete = value;
    notifyListeners();
  }
  void ChangeIfAddProjectUploadComplete(bool value) {
    IfAddProjectUploadComplete = value;
    notifyListeners();
  }
  void ChangeIfAddTeamAwardUploadComplete(bool value) {
    IfAddTeamAwardUploadComplte = value;
    notifyListeners();
  }

  //수상 경력
  void ChangeTeamAwardName(String value) {
    TeamAwardName = value;
    notifyListeners();
  }
  void ChangeTeamAwardGrade(String value) {
    TeamAwardGrade = value;
    notifyListeners();
  }
  void ChangeTeamAwardAgency(String value) {
    TeamAwardAgency = value;
    notifyListeners();
  }
  void ChangeTeamAwardTime(String value) {
    TeamAwardTime = value;
    notifyListeners();
  }
  void ChangeIsAddAwardUploadComplte(bool value) {
    IfAddTeamAwardUploadComplte = value;
    notifyListeners();
  }
  void ChangeIfAddAwardComplete(bool value) {
    IfAddTeamAwardComplete = value;
    notifyListeners();
  }

  //메인
  void ChangeTeamName(String value) {
    TeamName = value;
    notifyListeners();
  }
  void ChangeTeamCategory(String value) {
    TeamCategory = value;
    notifyListeners();
  }
  void ChangeTeamField(String value) {
    TeamField = value;
    notifyListeners();
  }
  void ChangeTeamAreaByAdd(bool check, String value) {
    if(check == true) {
      TeamArea += value;
    }
    else {
      TeamArea = value;
    }
    notifyListeners();
  }
  void ChangeFlagForTeamArea(bool value) {
    FlagForTeamArea = value;
    notifyListeners();
  }
  void ChangeIfSupportTeam(bool value) {
    IfSupportTeam = value;
    notifyListeners();
  }
  void ChangeTeamIntroduce(String value) {
    TeamIntroduce = value;
    notifyListeners();
  }

  //인증
  void ChangeIdentifiedName(String value) {
    IdentifiedName = value;
    notifyListeners();
  }
  void ChangeIdentifiedAgency(String value) {
    IdentifiedAgency = value;
    notifyListeners();
  }


  //수행내역
  void ChangeProjectName (String value) {
    ProjectName  = value;
    notifyListeners();
  }
  void ChangeProjectAgency (String value) {
    ProjectAgency  = value;
    notifyListeners();
  }
  void ChangeProjectStart (String value) {
    ProjectStart  = value;
    notifyListeners();
  }
  void ChangeProjectEnd (String value) {
    ProjectEnd  = value;
    notifyListeners();
  }

  void SetData(Team team){
    TeamName = team.name;
    TeamIntroduce = team.information;
    TeamCategory = team.category;
    TeamField = team.part;
    TeamArea = team.location +' '+team.subLocation;
    IfSupportTeam = team.possibleJoin == 0 ? false : true;

    IdentifiedList.clear();
    IdentifiedStateList.clear();

    if(team.TeamAuthList != null){
      for(int i = 0 ; i < team.TeamAuthList.length; ++i){
        IdentifiedList.add(team.TeamAuthList[i].TAuthContents);
        IdentifiedStateList.add(team.TeamAuthList[i].TAuthAuth);
      }
    }

    ProjectList.clear();
    ProjectStateList.clear();
    if(team.TeamPerformList != null){
      for(int i = 0; i < team.TeamPerformList.length; i++) {
        ProjectList.add(team.TeamPerformList[i].TPerformContents);
        ProjectStateList.add(team.TeamPerformList[i].TPerformAuth);
      }
    }

    TeamAwardList.clear();
    TeamAwardStateList.clear();
    if(team.TeamWinList != null){
      for(int i = 0; i < team.TeamWinList.length; i++) {
        TeamAwardList.add(team.TeamWinList[i].TWinContents);
        TeamAwardStateList.add(team.TeamWinList[i].TWinAuth);
      }
    }
  }

  void CheckMyTeamModify(){
    if(TeamName != null && TeamCategory != null && TeamField != null && TeamArea != null && TeamIntroduce != null &&
        TeamName != "" && TeamCategory != "" && TeamField != "" && TeamArea != "" && TeamIntroduce != "") {
      AddTeamComplete = true;
    } else {
      AddTeamComplete = false;
    }
  }

}