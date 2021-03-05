import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';

class TeamAuth {
  int TAuthID;
  int TATeamID;
  String TAuthContents;
  String TAuthImgUrl;
  int TAuthAuth;
  String createdAt;
  String updatedAt;

  TeamAuth({this.createdAt,this.updatedAt,this.TATeamID,this.TAuthAuth,this.TAuthContents,this.TAuthID,this.TAuthImgUrl});

  factory TeamAuth.fromJson(Map<String, dynamic> json){
    return TeamAuth(
      TAuthID: json['TAuthID'] as int,
      TATeamID: json['TATeamID'] as int,
      TAuthContents: json['TAuthContents'] as String,
      TAuthImgUrl: json['TAuthImgUrl'] as String,
      TAuthAuth: json['TAuthAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
class TeamWins {
  int TWinID;
  int TWTeamID;
  String TWinContents;
  String TWinImgUrl;
  int TWinAuth;
  String createdAt;
  String updatedAt;

  TeamWins({this.updatedAt,this.createdAt,this.TWinAuth,this.TWinContents,this.TWinID,this.TWinImgUrl,this.TWTeamID});

  factory TeamWins.fromJson(Map<String, dynamic> json){
    return TeamWins(
      TWinID: json['TWinID'] as int,
      TWTeamID: json['TWTeamID'] as int,
      TWinContents: json['TWinContents'] as String,
      TWinImgUrl: json['TWinImgUrl'] as String,
      TWinAuth: json['TWinAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
class TeamPerformances {
  int TPerformID;
  int TPTeamID;
  String TPerformContents;
  String TperformImgUrl;
  int TPerformAuth;
  String createdAt;
  String updatedAt;

  TeamPerformances({this.createdAt,this.updatedAt,this.TPerformAuth,this.TPerformContents,this.TPerformID,this.TperformImgUrl,this.TPTeamID});

  factory TeamPerformances.fromJson(Map<String, dynamic> json){
    return TeamPerformances(
      TPerformID: json['TPerformID'] as int,
      TPTeamID: json['TPTeamID'] as int,
      TPerformContents: json['TPerformContents'] as String,
      TperformImgUrl: json['TPerformImgUrl'] as String,
      TPerformAuth: json['TPerformAuth'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class SampleTeam{
  int id;
  String name;
  String part;
  String location;
  String profileURL;
  SampleTeam({this.id, this.name, this.part, this.location, this.profileURL});

  factory SampleTeam.fromJson(Map<String, dynamic> json){
    return SampleTeam(
      id: json['id'] as int,
      name: json['Name'],
      part: json['Part'],
      location: json['Location'],
      profileURL: json['TImgUrl1'] as String == null ? 'BasicImage' : ApiProvider().getUrl + json['TImgUrl1']
    );
  }
}

class Team {
  int id;
  int leaderID;
  String name;
  String information;
  String category;
  String part;
  String location;
  String subLocation;
  int possibleJoin;
  List<String> profileUrlList;
  int badge1;
  int badge2;
  int badge3;
  List<int> userList;
  String createdAt;
  String updatedAt;

  List<TeamAuth> TeamAuthList = new List<TeamAuth>();
  List<TeamPerformances> TeamPerformList = new List<TeamPerformances>();
  List<TeamWins> TeamWinList = new List<TeamWins>();

  Team({this.id, this.leaderID, this.name,this.information, this.category, this.part, this.location, this.subLocation,
    this.possibleJoin, this.profileUrlList, this.badge1, this.badge2, this.badge3, this.userList, this.createdAt, this.updatedAt,this.TeamWinList,this.TeamPerformList,this.TeamAuthList});

  factory Team.fromJson(Map<String, dynamic> json) {

    List<int> teamList = new List<int>();

    List<dynamic> list = json['TeamLists'] as List;

    if(list != null) {
      for(int i =0;i< list.length;i++){
        Map<String,dynamic> data = (json['TeamLists'] as List)[i];
        teamList.add(data['UserID']);
      }
    }


    List<String> urlList = List<String>();

    urlList.add(json['TImgUrl1'] as String == null ? 'BasicImage' : ApiProvider().getUrl + json['TImgUrl1']);

    if(json['TImgUrl2'] as String != null ) urlList.add(ApiProvider().getUrl + json['TImgUrl2']);
    if(json['TImgUrl3'] as String != null ) urlList.add(ApiProvider().getUrl + json['TImgUrl3']);
    if(json['TImgUrl4'] as String != null ) urlList.add(ApiProvider().getUrl + json['TImgUrl4']);
    if(json['TImgUrl5'] as String != null ) urlList.add(ApiProvider().getUrl + json['TImgUrl5']);

    return Team(
      id: json["id"] as int,
      leaderID: json["LeaderID"] as int,
      name: json["Name"] as String,
      information: json["Information"] as String,
      category: json["Category"] as String,
      part: json["Part"] as String,
      location: json["Location"] as String,
      subLocation : json["SubLocation"] as String,
      possibleJoin: json["PossibleJoin"] as int,
      profileUrlList: urlList,
      badge1: json["Badge1"] as int,
      badge2: json["Badge2"] as int,
      badge3: json["Badge3"] as int,
      userList: teamList,
      TeamAuthList : json['teamauths'] == null ? null : (json['teamauths'] as List).map((e) => TeamAuth.fromJson(e)).toList(),
      TeamPerformList : json['teamperformances'] == null ? null : (json['teamperformances'] as List).map((e) => TeamPerformances.fromJson(e)).toList(),
      TeamWinList : json['teamwins'] == null ? null : (json['teamwins'] as List).map((e) => TeamWins.fromJson(e)).toList(),
      createdAt: replaceUTCDate(json["createdAt"] as String),
      updatedAt: replaceUTCDate(json["updatedAt"] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'leaderID' : leaderID,
    'name': name,
    'information' : information,
    'category' : category,
    'major' : part,
    'location' : location,
    'subLocation' : subLocation,
    'possibleJoin' : possibleJoin,
    'profileUrlList' : profileUrlList,
    'badge1' : badge1,
    'badge2' : badge2,
    'badge3' : badge3,
    'userList' : userList,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}
