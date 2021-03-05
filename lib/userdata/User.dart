import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';

class UserCareer {
  int PfCareerID;
  int PfCUserID;
  String PfCareerImgUrl;
  String PfCareerContents;
  String PfCareerStart;
  String PfCareerDone;
  bool PfCareerNow;
  int PfCareerAuth;
  String createdAt;
  String updatedAt;

  UserCareer({this.PfCareerAuth,this.PfCareerContents,this.PfCareerDone,this.PfCareerNow,this.PfCareerStart,this.updatedAt,this.createdAt,this.PfCareerID,this.PfCareerImgUrl,this.PfCUserID});

  factory UserCareer.fromJson(Map<String, dynamic> json){
    return UserCareer(
      PfCareerID: json['PfCareerID'] as int,
      PfCUserID: json['PfCUserID'] as int,
      PfCareerContents: json['PfCareerContents'] as String,
      PfCareerImgUrl: json['PfCareerImgUrl'] as String,
      PfCareerStart: json['PfCareerStart'] as String,
      PfCareerDone: json['PfCareerDone'] as String,
      PfCareerNow: json['PfCareerNow'] as bool,
      PfCareerAuth: json['PfCareerAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
class UserLicense {
  int PfLicenseID;
  int PfLUserID;
  String PfLicenseContents;
  String PfLicenseImgUrl;
  int PfLicenseAuth;
  String createdAt;
  String updatedAt;

  UserLicense({this.PfLicenseAuth,this.PfLicenseContents,this.createdAt,this.updatedAt,this.PfLicenseID,this.PfLicenseImgUrl,this.PfLUserID});

  factory UserLicense.fromJson(Map<String, dynamic> json){
    return UserLicense(
      PfLicenseID: json['PfLicenseID'] as int,
      PfLUserID: json['PfLUserID'] as int,
      PfLicenseContents: json['PfLicenseContents'] as String,
      PfLicenseImgUrl: json['PfLicenseImgUrl'] as String,
      PfLicenseAuth: json['PfLicenseAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
class UserWin {
  int PfWinID;
  int PfWUserID;
  String PfWinContents;
  String PfWinImgUrl;
  int PfWinAuth;
  String createdAt;
  String updatedAt;

  UserWin({this.PfWinAuth,this.PfWinContents,this.updatedAt,this.createdAt,this.PfWinID,this.PfWinImgUrl,this.PfWUserID});

  factory UserWin.fromJson(Map<String, dynamic> json){
    return UserWin(
      PfWinID: json['PfWinID'] as int,
      PfWUserID: json['PfWUserID'] as int,
      PfWinContents: json['PfWinContents'] as String,
      PfWinImgUrl: json['PfWinImgUrl'] as String,
      PfWinAuth: json['PfWinAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
class UserUniv {
  int PfLicenseID;
  int PfLUserID;
  String PfLicenseContents;
  String PfLicenseImgUrl;
  int PfLicenseAuth;
  String createdAt;
  String updatedAt;

  UserUniv({this.createdAt,this.updatedAt,this.PfLUserID,this.PfLicenseImgUrl,this.PfLicenseID,this.PfLicenseContents,this.PfLicenseAuth});

  factory UserUniv.fromJson(Map<String, dynamic> json){
    return UserUniv(
      PfLicenseID: json['PfUnivID'] as int,
      PfLUserID: json['PfUUserID'] as int,
      PfLicenseContents: json['PfUnivName'] as String,
      PfLicenseImgUrl: json['PfUnivImgUrl'] as String,
      PfLicenseAuth: json['PfUnivAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
class UserGraduate {
  int PfGraduateID;
  int PfGUserID;
  String PfGraduateName;
  String PfGraduateImgUrl;
  int PfGraduateAuth;
  String createdAt;
  String updatedAt;

  UserGraduate({this.updatedAt,this.createdAt,this.PfGraduateAuth,this.PfGraduateID,this.PfGraduateImgUrl,this.PfGraduateName,this.PfGUserID});

  factory UserGraduate.fromJson(Map<String, dynamic> json){
    return UserGraduate(
      PfGraduateID: json['PfGraduateID'] as int,
      PfGUserID: json['PfGUserID'] as int,
      PfGraduateName: json['PfGraduateName'] as String,
      PfGraduateImgUrl: json['PfGraduateImgUrl'] as String,
      PfGraduateAuth: json['PfGraduateAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class SampleUser {
  int userID;
  String name;
  String part;
  String location;
  String profileURL;
  SampleUser({this.userID, this.name, this.part, this.location, this.profileURL});

  factory SampleUser.fromJson(Map<String, dynamic> json) {
    return SampleUser(
      userID: json['UserID'] as int,
      name: json['Name'],
      part: json['Part'],
      location: json['Location'],
      profileURL: json['PfImgUrl1'] as String == null ?  'BasicImage' : ApiProvider().getUrl + json['PfImgUrl1']
    );
  }
}

class UserData {
  int userID;
  String id;
  String name;
  String information;
  String major;
  String subMajor;
  String part;
  String subPart;
  String location;
  String subLocation;
  String PhoneNumber;
  int badge1;
  int badge2;
  int badge3;
  List<String> profileUrlList;
  String createdAt;
  String updatedAt;
  String accessToken;
  //refreshtoken


  //테이블 변경에 따른 연동 작업
  String job;
  String subJob;

  List<Career> careerList = [];
  List<Certification> CertificationList = [];
  List<Award> AwardList = [];
  List<BadgeModel> badgeList = new List<BadgeModel>();

  List<UserCareer> UserCareerList = new List<UserCareer>();
  List<UserLicense> UserLicenseList = new List<UserLicense>();
  List<UserWin> UserWinList = new List<UserWin>();
  List<UserUniv> UserUnivList = new List<UserUniv>();
  List<UserGraduate> UserGraduateList = new List<UserGraduate>();

  UserData({this.userID, this.id, this.name,this.information, this.major, this.subMajor, this.part, this.subPart, this.location, this.subLocation,this.PhoneNumber,
    this.badge1, this.badge2, this.badge3, this.profileUrlList, this.createdAt, this.updatedAt, this.accessToken,this.job,this.subJob, this.badgeList,this.UserCareerList,this.UserGraduateList,this.UserLicenseList,this.UserUnivList,this.UserWinList});

  factory UserData.fromJson(Map<String, dynamic> json) {

    List<String> urlList = List<String>();

    urlList.add(json['PfImgUrl1'] as String == null ? 'BasicImage' : ApiProvider().getUrl + json['PfImgUrl1']);

    if(json['PfImgUrl2'] as String != null ) urlList.add(ApiProvider().getUrl + json['PfImgUrl2']);
    if(json['PfImgUrl3'] as String != null ) urlList.add(ApiProvider().getUrl + json['PfImgUrl3']);
    if(json['PfImgUrl4'] as String != null ) urlList.add(ApiProvider().getUrl + json['PfImgUrl4']);
    if(json['PfImgUrl5'] as  String != null ) urlList.add(ApiProvider().getUrl + json['PfImgUrl5']);


    return  UserData(
      userID: json["UserID"] as int,
      id: json["ID"] as String,
      name: json["Name"] as String,
      information: json["Information"] as String,
      major: json["Job"] as String,
      subMajor: json["SubJob"] as String,
      part: json["Part"] as String,
      subPart: json["SubPart"] as String,
      location: json["Location"] as String,
      subLocation : json["SubLocation"] as String,
      badge1: json["Badge1"] as int,
      badge2: json["Badge2"] as int,
      badge3: json["Badge3"] as int,
      PhoneNumber: json["PhoneNumber"] as String,
      profileUrlList: urlList,
      createdAt: replaceUTCDate(json["createdAt"] as String),
      updatedAt: replaceUTCDate(json["updatedAt"] as String),
      accessToken: json["AccessToken"] as String,
      job: json["job"] as String,
      subJob: json["subJob"] as String,
      badgeList : json['PersonalBadgeLists'] == null ? null : (json['PersonalBadgeLists'] as List).map((e) => BadgeModel.fromJson(e)).toList(),

      UserCareerList : json['profilecareers'] == null ? null : (json['profilecareers'] as List).map((e) => UserCareer.fromJson(e)).toList(),
      UserLicenseList : json['profilelicenses'] == null ? null : (json['profilelicenses'] as List).map((e) => UserLicense.fromJson(e)).toList(),
      UserWinList : json['profilewins'] == null ? null : (json['profilewins'] as List).map((e) => UserWin.fromJson(e)).toList(),
      UserUnivList : json['profileunivs'] == null ? null : (json['profileunivs'] as List).map((e) => UserUniv.fromJson(e)).toList(),
      UserGraduateList : json['profilegraduates'] == null ? null : (json['profilegraduates'] as List).map((e) => UserGraduate.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userID' : userID,
    'id': id,
    'name': name,
    'information' : information,
    'major' : major,
    'subMajor' : subMajor,
    'part' : part,
    'subPart' : subPart,
    'location' : location,
    'subLocation' : subLocation,
    'badge1' : badge1,
    'badge2' : badge2,
    'badge3' : badge3,
    'profileURL' : profileUrlList,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'accessToken' : accessToken,
    'job':job,
    'subJob':subJob,
    'PhoneNumber':PhoneNumber,
  };
}
