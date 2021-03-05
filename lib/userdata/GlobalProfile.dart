import 'dart:async';
import 'dart:convert';

import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/User.dart';

class GlobalProfile {
  static bool personalFiltered = false;
  static List<UserData> personalProfile = new List<UserData>();
  static List<UserData> personalProfileFiltered = new List<UserData>();

  static List<SampleUser> personalSampleProfile = new List<SampleUser>();
  static List<SampleTeam> teamSampleProfile = new List<SampleTeam>();

  static bool teamFiltered = false;
  static List<Team> teamProfile = new List<Team>();
  static List<Team> teamProfileFiltered = new List<Team>();

  //전체
  //일반 커뮤니티 인기게시글
  static List<Community> popularCommunityList = new List<Community>();
  //일반 켜뮤니티 신규게시글
  static List<Community> newCommunityList = new List<Community>();
  //직군별 커뮤니티 인기게시군
  static List<Community> popularCommunityListByJob = new List<Community>();
  //직군별 커뮤니티 신규게시글
  static List<Community> newCommunityListByJob = new List<Community>();

  //분야별 게시글
  static List<Community> filteredCommunityList = new List<Community>();

  //필터된 게시글
  static List<Community> searchWord = new List<Community>();


  //커뮤니티 댓글
 static List<CommunityReply> communityReply = new List<CommunityReply>();

  static UserData loggedInUser;
  static String accessToken;
  static String refreshToken;
  static String accessTokenExpiredAt;

  static List<Community> postedList = new List<Community>();

  static Future<UserData> getFutureUserByUserID(int userID) async {
    if(loggedInUser.userID == userID) return Future.value(loggedInUser);

    for (int i = 0; i < personalProfile.length; ++i) {
      if (personalProfile[i].userID== userID) {
        return Future.value(personalProfile[i]);
      }
    }

    var res = await ApiProvider().post('/Profile/Personal/UserSelect', jsonEncode(
        {
          "userID" : userID
        }
    ));

    if(res == null) return null;

    UserData user = UserData.fromJson(res);

    personalProfile.add(user);

    return Future.value(user);
  }

  static UserData getUserByUserID(int userID) {

    if(loggedInUser.userID == userID) return loggedInUser;

    UserData user = null;
    for (int i = 0; i < personalProfile.length; ++i) {
        if (personalProfile[i].userID== userID) {
          user = personalProfile[i];
        }
    }

    //받아온 데이터 중에서 없으면
    if(null == user){
      if(loggedInUser.userID == userID){
        user = loggedInUser;
      }else{
        Future.microtask(() async => {
          user = await GlobalProfile().selectAndAddUser(userID)
        });
      }
    }

    return user;
  }

  static UserData getUserByUserIDAndloggedInUser(int userID) {
    UserData user = null;
    user = getUserByUserID(userID);

    if(null == user &&
        loggedInUser.userID == userID
    ) {
     user = loggedInUser;
    }

    return user;
  }

  //데이터를 받아와 저장함
  Future<UserData> selectAndAddUser(int userID) async {
    var res = await ApiProvider().post('/Profile/Personal/UserSelect', jsonEncode(
      {
        "userID" : userID
      }
    ));

    if(res == null){
      return null;
    }

    UserData user = UserData.fromJson(res);
    personalProfile.add(user);

    return user;
  }


  static List<UserData> getUserListByUserIDList(List<int> userIDList){
    List<UserData> userList = new List<UserData>();


    personalProfile.forEach((element) {
      for(int j = 0 ; j < userIDList.length; ++j){
        if (element.userID == userIDList[j]) {
          userList.add(element);
        }
      }
    });

    return userList;
  }



  static CommunityReply getReplyByIndex(int index){
    if(index >= communityReply.length) return null;

    return communityReply[index];
  }

  static Future<Team> getFutureTeamByRoomName(String roomName) async {
    String teamIDWord = roomName.replaceRange(0, 6, '');
    String teamID = '';
    //48은 ASCI CODE 값
    for(int i = 0 ; i < teamIDWord.length; ++i){
      if((teamIDWord.codeUnitAt(i) - 48) < 10){
        teamID += (teamIDWord.codeUnitAt(i) - 48).toString();
      }else{
        break;
      }
    }

    return await getFutureTeamByID(int.parse(teamID));
  }

  static Team getTeamByRoomName(String roomName){
    String teamIDWord = roomName.replaceRange(0, 6, '');
    String teamID = '';
	//48은 ASCI CODE 값 
    for(int i = 0 ; i < teamIDWord.length; ++i){
      if((teamIDWord.codeUnitAt(i) - 48) < 10){
        teamID += (teamIDWord.codeUnitAt(i) - 48).toString();
      }else{
        break;
      }
    }

    return getTeamByID(int.parse(teamID));
  }

  static Future<Team> getFutureTeamByID(int id) async {
    for(int i = 0 ; i < teamProfile.length; ++i) {
      if(teamProfile[i].id == id){
        return Future.value(teamProfile[i]);
      }
    }

    var res = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode(
        {
          "id" : id
        }
    ));

    if(res == null) return Future.value(null);

    return Future.value(Team.fromJson(res));
  }

  static Team getTeamByID(int id){
    Team team = null;

    for(int i = 0 ; i < teamProfile.length; ++i) {
      if(teamProfile[i].id == id){
        team = teamProfile[i];
        break;
      }
    }

    if(null == team){
      GlobalProfile().selectAndAddTeam(id).then((value) {
        return value;
      });
    }else{
      return team;
    }
  }

  //데이터를 받아와 저장함
  Future<Team> selectAndAddTeam(int id) async {
    await ApiProvider().post('/Team/Profile/SelectID', jsonEncode(
        {
          "id" : id
        }
    )).then((value) {
      if(value == null) return null;

      Team team = Team.fromJson(value);
      teamProfile.add(team);

      return team;
    });

    return null;
  }

  Future<Team> selectAndAddFutureTeam(int id) async {
    var res = await ApiProvider().post('/Team/Profile/SelectID', jsonEncode(
        {
          "id" : id
        }
    ));

    return res;
  }

  static void acceceTokenCheck() {
    Timer.periodic(Duration(minutes: 5), (timer) {
      if(int.parse(accessTokenExpiredAt) > int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(0,10))){
        Future.microtask(() async {
          var res = await ApiProvider().post('/Profile/Personal/Login/Token', jsonEncode({
            "userID" : loggedInUser.userID,
            "refreshToken" : refreshToken
          }));

          if(res != null){
            accessToken = res['AccessToken'] as String;
            accessTokenExpiredAt =  (res['AccessTokenExpiredAt'] as int).toString();
          }
        });
      }
    });
  }
}
