import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';

import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/profile/AddTeam/AddTeam.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/profileModify/MyProfileModify.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class NotificationModel {
  int id;
  int from;
  int to;
  int type;
  int index;
  String time;
  String teamRoomName;
  int isRead;
  int isSend;
  String createdAt;
  String updatedAt;
  bool isLoad;

  NotificationModel({this.id,this.from,this.to,this.type,this.index,this.time, this.teamRoomName, this.isRead, this.isSend, this.createdAt, this.updatedAt, this.isLoad = false});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id : json['id'] as int,
      from: json['UserID'] as int,
      to: json['TargetID'] as int,
      type: GetType(json['Type'] as String),
      index: json['TableIndex'] as int,
      time: json['Time'] as String,
      isRead: 0,
      isSend: 0,
      createdAt: replaceUTCDate(json["createdAt"] as String),
      updatedAt: replaceUTCDate(json["updatedAt"] as String),
      teamRoomName: null
    );
  }

  Map<String, dynamic> toJson(String roomName, int response) =>{
    'id' : id,
    'from' : from,
    'to' : to,
    'type' : type,
    'index' : index,
    'time' : time,
    'isRead' : isRead,
    'isSend' : isSend,
    'roomName' : roomName,
    'response' : response,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}


final String WhiteBellIcon= 'assets/images/TotalNotification/WhiteBellIcon.svg';
final String WhiteChatIcon= 'assets/images/TotalNotification/WhiteChatIcon.svg';
final String WhiteNewsIcon= 'assets/images/TotalNotification/WhiteNewsIcon.svg';
final String WhitePeopleIcon2= 'assets/images/TotalNotification/WhitePeopleIcon2.svg';

String GetNotificationIcon(String NotificationIcon) {
  if(NotificationIcon == '알림')
    return WhiteBellIcon;
  else if(NotificationIcon == '쪽지')
    return WhiteNewsIcon;
  else if(NotificationIcon == '지원')
    return WhitePeopleIcon2;
  else if(NotificationIcon == '댓글')
    return WhiteChatIcon;
  else
    return WhiteBellIcon;
}

String GetNotificationIconIndex(int type) {

  String res = WhiteBellIcon;
  switch(type){
    case NOTI_EVENT_PROFILE_MODIFY_RECOMMEND:
    case NOTI_EVENT_TEAM_PROFILE_ADD_RECOMMEND:
    case NOTI_EVENT_TEAM_PROFILE_JOIN_RECOMMEND:
      res = WhiteBellIcon;
      break;
    case NOTI_EVENT_PROFILE_LIKE:
    case NOTI_EVENT_TEAM_INVITE:
    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
    case NOTI_EVENT_TEAM_INVITE_REFUSE:
    case NOTI_EVENT_TEAM_LIKE:
    case NOTI_EVENT_TEAM_REQUEST:
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
    case NOTI_EVENT_TEAM_REQUEST_REFUSE:
      res = WhiteNewsIcon;
      break;
    case NOTI_EVENT_POST_LIKE:
    case NOTI_EVENT_POST_REPLY_LIKE:
    case NOTI_EVENT_POST_REPLY_REPLY_LIKE:
    case NOTI_EVENT_POST_REPLY:
    case NOTI_EVENT_POST_REPLY_REPLY:
      res = WhiteChatIcon;
      break;
  }

  return res;
}

List<NotificationModel> notiList = new List<NotificationModel>();

Future SetHandLoginNotificationListByEvent() async {
  var notiListGet = await ApiProvider().post('/Notification/HandLoginSelect', jsonEncode(
      {
        "userID" : GlobalProfile.loggedInUser.userID,
      }
  ));

  if(null != notiListGet){
    for(int i = 0; i < notiListGet.length; ++i){
      NotificationModel noti = NotificationModel.fromJson(notiListGet[i]);
      notiList.add(noti);
      await NotiDBHelper().createData(noti);
    }
  }

  notiList = notiList.reversed.toList();
}

Future SetNotificationListByEvent() async {
  var notiListGet = await ApiProvider().post('/Notification/UnSendSelect', jsonEncode(
      {
        "userID" : GlobalProfile.loggedInUser.userID,
      }
  ));

  if(null != notiListGet){
    for(int i = 0; i < notiListGet.length; ++i){
      NotificationModel noti = NotificationModel.fromJson(notiListGet[i]);
      notiList.add(noti);
      await NotiDBHelper().createData(noti);
    }
  }
}

SetNotificationListToNewMember() {
  NotificationModel profileModifyRecommendNoti = NotificationModel(
    type: NOTI_EVENT_PROFILE_MODIFY_RECOMMEND,
    from: -1,
    time: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    updatedAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    createdAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
  );
  profileModifyRecommendNoti.isRead = 0;
  profileModifyRecommendNoti.isSend = 0;
  profileModifyRecommendNoti.isLoad = true;

  NotificationModel teamProfileJoinRecommend = NotificationModel(
    type: NOTI_EVENT_TEAM_PROFILE_JOIN_RECOMMEND,
    from: -1,
    time: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    updatedAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    createdAt: replacLocalUTCDate(DateTime.now().toUtc().toString())
  );
  teamProfileJoinRecommend.isRead = 0;
  teamProfileJoinRecommend.isSend = 0;
  teamProfileJoinRecommend.isLoad = true;

  NotificationModel teamProfileAddRecommend = NotificationModel(
    type: NOTI_EVENT_TEAM_PROFILE_ADD_RECOMMEND,
    from: -1,
    time: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    updatedAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    createdAt: replacLocalUTCDate(DateTime.now().toUtc().toString())
  );
  teamProfileAddRecommend.isRead = 0;
  teamProfileAddRecommend.isSend = 0;
  teamProfileAddRecommend.isLoad = true;

  notiList.add(profileModifyRecommendNoti);
  notiList.add(teamProfileAddRecommend);
  notiList.add(teamProfileJoinRecommend);
}

const int NOTI_EVENT_INVITE = 1;
const int NOTI_EVENT_INVITE_ACCEPT = 2;
const int NOTI_EVENT_INVITE_REFUSE = 3;
const int NOTI_EVENT_TEAM_INVITE = 4;
const int NOTI_EVENT_TEAM_INVITE_ACCEPT = 5;
const int NOTI_EVENT_TEAM_INVITE_REFUSE = 6;
const int NOTI_EVENT_TEAM_REQUEST = 7;
const int NOTI_EVENT_TEAM_REQUEST_ACCEPT = 8;
const int NOTI_EVENT_TEAM_REQUEST_REFUSE = 9;
const int NOTI_EVENT_PROFILE_LIKE = 10;
const int NOTI_EVENT_TEAM_LIKE = 11;
const int NOTI_EVENT_POST_LIKE = 12;
const int NOTI_EVENT_POST_REPLY = 13;
const int NOTI_EVENT_POST_REPLY_LIKE = 14;
const int NOTI_EVENT_POST_REPLY_REPLY = 15;
const int NOTI_EVENT_POST_REPLY_REPLY_LIKE = 16;
const int NOTI_EVENT_TEAM_MEMBER_ADD = 17;
const int NOTI_EVENT_PROFILE_MODIFY_RECOMMEND = 100;
const int NOTI_EVENT_TEAM_PROFILE_ADD_RECOMMEND = 101;
const int NOTI_EVENT_TEAM_PROFILE_JOIN_RECOMMEND = 102;

int GetType(String typeStr){
  int type = 0;
  switch(typeStr){
    case "INVITE":
      type = NOTI_EVENT_INVITE;
      break;
    case "INVITE_ACCEPT":
      type = NOTI_EVENT_INVITE_ACCEPT;
      break;
    case "INVITE_REFUSE":
      type = NOTI_EVENT_INVITE_REFUSE;
      break;
    case "TEAM_INVITE":
      type = NOTI_EVENT_TEAM_INVITE;
      break;
    case "TEAM_INVITE_ACCEPT":
      type = NOTI_EVENT_TEAM_INVITE_ACCEPT;
      break;
    case "TEAM_INVITE_REFUSE":
      type = NOTI_EVENT_TEAM_INVITE_REFUSE;
      break;
    case "TEAM_REQUEST":
      type = NOTI_EVENT_TEAM_REQUEST;
      break;
    case "TEAM_REQUEST_ACCEPT":
      type = NOTI_EVENT_TEAM_REQUEST_ACCEPT;
      break;
    case "TEAM_REQUEST_REFUSE":
      type = NOTI_EVENT_TEAM_REQUEST_REFUSE;
      break;
    case "PROFILE_LIKE":
      type = NOTI_EVENT_PROFILE_LIKE;
      break;
    case "TEAM_LIKE":
      type = NOTI_EVENT_TEAM_LIKE;
      break;
    case "POST_LIKE":
      type = NOTI_EVENT_POST_LIKE;
      break;
    case "POST_REPLY":
      type = NOTI_EVENT_POST_REPLY;
      break;
    case "POST_REPLY_LIKE":
      type = NOTI_EVENT_POST_REPLY_LIKE;
      break;
    case "POST_REPLY_REPLY":
      type = NOTI_EVENT_POST_REPLY_REPLY;
      break;
    case "POST_REPLY_REPLY_LIKE":
      type = NOTI_EVENT_POST_REPLY_REPLY_LIKE;
      break;
    case "TEAM_MEMBER_ADD":
      type = NOTI_EVENT_TEAM_MEMBER_ADD;
      break;
    default:
      type = 0;
      break;
  }

  return type;
}

bool isPersonalNotification(int type){
  bool res = false;
  switch(type){
    case NOTI_EVENT_INVITE:
    case NOTI_EVENT_INVITE_ACCEPT:
    case NOTI_EVENT_INVITE_REFUSE:
    case NOTI_EVENT_POST_REPLY:
    case NOTI_EVENT_POST_REPLY_REPLY:
    case NOTI_EVENT_POST_LIKE:
    case NOTI_EVENT_POST_REPLY_LIKE:
    case NOTI_EVENT_POST_REPLY_REPLY_LIKE:
    case NOTI_EVENT_PROFILE_LIKE:
    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
    case NOTI_EVENT_TEAM_INVITE_REFUSE:
    case NOTI_EVENT_TEAM_REQUEST:
    case NOTI_EVENT_TEAM_LIKE:
    case NOTI_EVENT_TEAM_MEMBER_ADD:
      res = true;
      break;
    case NOTI_EVENT_TEAM_INVITE:
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
    case NOTI_EVENT_TEAM_REQUEST_REFUSE:
      res = false;
      break;
  }

  return res;
}

String getNotiInformation(NotificationModel notificationModel){
  String info = '잘못된 접근입니다.';
  UserData user = GlobalProfile.getUserByUserID(notificationModel.from);

  String part = notificationModel.from == -1 ? '' : user.part == '' ? '' : ' / ' + user.part;
  String location = notificationModel.from == -1 ? '' : user.location == '' ? '' : ' / ' + user.subLocation;

  switch(notificationModel.type){
    case NOTI_EVENT_INVITE:
      info = "'" + user.name + part + location + "' 님이 당신에게 채팅 요청을 보냈습니다!";
      break;
    case NOTI_EVENT_INVITE_ACCEPT:
      info = "'" + user.name + part + location + "' 님이 채팅 초대를 수락하였습니다.";
      break;
    case NOTI_EVENT_INVITE_REFUSE:
      info = "'" + user.name + part + location + "' 님이 채팅 초대를 거절하였습니다.";
      break;
    case NOTI_EVENT_TEAM_INVITE:
      Team team;
      if(notificationModel.teamRoomName != null){
        team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
      }
      else{
       team = GlobalProfile.getTeamByID(notificationModel.index);
      }

      info = "'" + team.name + ' / ' + team.category + ' / '  + team.part + ' / ' + team.location + "' 팀이 당신에게 팀 초대를 보냈습니다!";
      break;
    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
      info = "'" + user.name + part + location + "' 님이 팀 초대를 수락하였습니다.";
      break;
    case NOTI_EVENT_TEAM_INVITE_REFUSE:
      info = "'" + user.name + part + location + "' 님이 팀 초대를 거절하였습니다.";
      break;
    case NOTI_EVENT_TEAM_REQUEST:
      info = "'" + user.name + part + location + "' 님이 팀 참가 요청을 보냈습니다.";
      break;
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
      Team team;
      if(notificationModel.teamRoomName != null && notificationModel.teamRoomName != 'null'){
        team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
      }
      else{
        team = GlobalProfile.getTeamByID(notificationModel.index);
      }
      info = "'" + team.name + ' / ' + team.category + ' / '  + team.part + ' / ' + team.location + "' 팀이 요청을 수락하였습니다!";
      break;
    case NOTI_EVENT_TEAM_REQUEST_REFUSE:
      Team team;
      if(notificationModel.teamRoomName != null && notificationModel.teamRoomName != 'null'){
        team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
      }
      else{
        team = GlobalProfile.getTeamByID(notificationModel.index);
      }
      info = "'" + team.name + ' / ' + team.category + ' / '  + team.part + ' / ' + team.location + "' 팀이 요청을 거절하였습니다!";
      break;
    case NOTI_EVENT_PROFILE_LIKE:
      info = "'" + user.name + part + location + "' 님이 당신의 프로필에 좋아요를 남겼습니다.";
      break;
    case NOTI_EVENT_TEAM_LIKE:
      info = "'" + user.name + part + location + "' 님이 당신의 팀 프로필에 좋아요를 남겼습니다.";
      break;
    case NOTI_EVENT_POST_LIKE:
      if(notificationModel.teamRoomName == "비밀"){
        info = "익명 님이 당신의 게시물에 좋아요를 남겼습니다.";
      }else{
        info = "'" + user.name + part + location + "' 님이 당신의 게시물에 좋아요를 남겼습니다.";
      }

      break;
    case NOTI_EVENT_POST_REPLY:
      if(notificationModel.teamRoomName == "비밀"){
        info = "익명 님이 당신의 게시물에 댓글을 남겼습니다.";
      }else{
        info = "'" + user.name + part + location + "' 님이 당신의 게시물에 댓글을 남겼습니다.";
      }
      break;
    case NOTI_EVENT_POST_REPLY_LIKE:
      if(notificationModel.teamRoomName == "비밀"){
        info = "익명 님이 당신의 댓글에 좋아요를 남겼습니다.";
      }else{
        info = "'" + user.name + part + location + "' 님이 당신의 댓글에 좋아요를 남겼습니다.";
      }
      break;
    case NOTI_EVENT_POST_REPLY_REPLY:
      if(notificationModel.teamRoomName == "비밀"){
        info = "익명 님이 당신의 댓글에 댓글을 남겼습니다.";
      }else{
        info = "'" + user.name + part + location + "' 님이 당신의 댓글에 댓글을 남겼습니다.";
      }
      break;
    case NOTI_EVENT_POST_REPLY_REPLY_LIKE:
      if(notificationModel.teamRoomName == "비밀"){
        info = "익명 님이 당신의 댓글에 좋아요를 남겼습니다.";
      }else{
        info = "'" + user.name + part + location + "' 님이 님이 당신의 댓글에 좋아요를 남겼습니다.";
      }
      break;
    case NOTI_EVENT_TEAM_MEMBER_ADD:
      info = "'" + user.name + part + location + "' 님이 당신이 속한 팀에 가입하였습니다.";
      break;
    case NOTI_EVENT_PROFILE_MODIFY_RECOMMEND:
      info = GlobalProfile.loggedInUser.name + '님, 정보를 채워 매력적인 프로필을 만들어 보세요! 💃🕺';
      break;
    case NOTI_EVENT_TEAM_PROFILE_JOIN_RECOMMEND:
      info = '아직 팀이 없으시군요. 마음에 드는 팀을 찾으러 가실래요? 🧚';
      break;
    case NOTI_EVENT_TEAM_PROFILE_ADD_RECOMMEND:
      info = '팀을 직접 만들고, 개인 프로필에서 팀을 구해보세요! 😎';
      break;
    default:
      info = '잘못된 접근입니다.';
      break;
  }

  return info;
}

Future NotiEvent(BuildContext context, NotificationModel notificationModel, index){
  //이미 응답한 알림은 보낼 수 없다.
  if(notificationModel.isSend == 1) {
    showSheepsDialog(
      context: context,
      title: '알림',
      description: '이미 응답한 알림입니다.',
      isCancelButton: false,
    );
    return Future.value(false);
  }

  switch(notificationModel.type){
    case NOTI_EVENT_INVITE: //개별 채팅 초대
      UserData user = GlobalProfile.getUserByUserID(notificationModel.from);

      Function okFunc = () {
        ApiProvider().post('/Room/Invite/Response', jsonEncode(
          notificationModel.toJson(getRoomName(notificationModel.to, notificationModel.from, false), 1))
        );

        //알림 상태 바꿈
        NotiDBHelper().updateIsSend(notificationModel.id, 1);
        notiList[index].isSend = 1;

        notificationModel.type = NOTI_EVENT_INVITE_ACCEPT;
        SetNotificationData(notificationModel, null);

        Navigator.pop(context);
      };

      Function cancelFunc = () {
        ApiProvider().post('/Room/Invite/Response', jsonEncode(
          notificationModel.toJson(getRoomName(notificationModel.to, notificationModel.from, false), 2))
        );

        //알림 상태 바꿈
        NotiDBHelper().updateIsSend(notificationModel.id, 1);
        notiList[index].isSend = 1;

        Navigator.pop(context);
      };

      String major = user.major == '' ? '' : ' / ' + user.major;
      String location = user.location == '' ? '' : ' / ' + user.subLocation;

      showSheepsDialog(
        context: context,
        title: '채팅 초대 요청',
        isLogo: false,
        imgUrl: user.profileUrlList[0],
        description:  user.name + major + location,
        okText: '수락할래요',
        okFunc: okFunc,
        cancelText: '거절할래요',
        cancelFunc: cancelFunc,
        isBarrierDismissible: true,
      );

      break;
    case NOTI_EVENT_TEAM_INVITE:  //팀 초대
      Team team;
      if(notificationModel.teamRoomName != null){
        team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
      }
      else{
        team = GlobalProfile.getTeamByID(notificationModel.index);
      }
      String roomName = notificationModel.teamRoomName == null ? getRoomName(team.id,team.leaderID, true) : notificationModel.teamRoomName;

      Function okFunc = () async {

        notificationModel.from = team.leaderID;
        var res = await ApiProvider().post('/Team/Invite/Response', jsonEncode(
            notificationModel.toJson(roomName, 1))
        );

        List<int> chatList = new List<int>();

        if(res != null){
          for(int i = 0 ; i < res.length; ++i){
            chatList.add(res[i]['UserID'] as int);
          }
        }
        //알림 상태 바꿈
        NotiDBHelper().updateIsSend(notificationModel.id, 1);
        notiList[index].isSend = 1;
        notificationModel.teamRoomName = roomName;

        bool isRoom = false;
        int roomIndex = 0;

        for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
          if(ChatGlobal.roomInfoList[i].roomName == notificationModel.teamRoomName){
            ChatGlobal.roomInfoList[i].chatUserIDList.add(notificationModel.from);
            GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName).userList.add(notificationModel.from);
            roomIndex = i;
            isRoom = true;
            break;
          }
        }

        if(false == isRoom) {
          ChatGlobal.roomInfoList.insert(0,SetTeamRoomInfoData(notificationModel));
          roomIndex = ChatGlobal.roomInfoList.length - 1;
        }

        if(chatList != null){
          for(int i = 0; i < chatList.length; ++i){
            ChatGlobal.roomInfoList[roomIndex].chatUserIDList.add(chatList[i]);
          }
        }

        Navigator.pop(context);
      };

      Function cancelFunc = () {
        notificationModel.from = team.leaderID;
        ApiProvider().post('/Team/Invite/Response', jsonEncode(
            notificationModel.toJson(roomName, 2))
        );

        //알림 상태 바꿈
        NotiDBHelper().updateIsSend(notificationModel.id, 1);
        notiList[index].isSend = 1;

        Navigator.pop(context);
      };

      showSheepsDialog(
        context: context,
        title: '팀 초대 요청',
        isLogo: false,
        imgUrl: team.profileUrlList[0],
        description: team.name + ' / ' + team.category + ' / ' + team.part + ' / '  + team.location,
        okText: '수락할래요',
        okFunc: okFunc,
        cancelText: '거절할래요',
        cancelFunc: cancelFunc,
        isBarrierDismissible: true,
      );

      break;
    case NOTI_EVENT_TEAM_REQUEST: //팀에 요청
      UserData user = GlobalProfile.getUserByUserID(notificationModel.from);

      Function okFunc = () async {

        Team team;
        if(notificationModel.teamRoomName != null){
          team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
        }
        else{
          team = GlobalProfile.getTeamByID(notificationModel.index);
        }
        String roomName = notificationModel.teamRoomName == null ? getRoomName(team.id,team.leaderID, true) : notificationModel.teamRoomName;

        var res = await ApiProvider().post('/Team/Request/Response', jsonEncode(
            notificationModel.toJson(roomName, 1))
        );

        List<int> chatList = new List<int>();

        if(res != null){
          for(int i = 0 ; i < res.length; ++i){
            chatList.add(res[i]['UserID']);
          }
        }

        //알림 상태 바꿈
        NotiDBHelper().updateIsSend(notificationModel.id, 1);
        notificationModel.teamRoomName = roomName;
        notiList[index].isSend = 1;

        bool isRoom = false;
        int roomIndex = 0;

        for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
          if(ChatGlobal.roomInfoList[i].roomName == notificationModel.teamRoomName){
            ChatGlobal.roomInfoList[i].chatUserIDList.add(notificationModel.from);
            GlobalProfile.getTeamByRoomName(roomName).userList.add(notificationModel.from);
            isRoom = true;
            roomIndex = i;
            break;
          }
        }

        if(false == isRoom) {
          ChatGlobal.roomInfoList.insert(0, SetTeamRoomInfoData(notificationModel));
          roomIndex = ChatGlobal.roomInfoList.length - 1;
        }

        if(chatList != null){
          for(int i = 0; i < chatList.length; ++i){
            ChatGlobal.roomInfoList[roomIndex].chatUserIDList.add(chatList[i]);
          }
        }

        Navigator.pop(context);
      };

      Function cancelFunc = () {
        ApiProvider().post('/Team/Request/Response', jsonEncode(
            notificationModel.toJson(notificationModel.teamRoomName, 2))
        );


        //알림 상태 바꿈
        NotiDBHelper().updateIsSend(notificationModel.id, 1);
        notiList[index].isSend = 1;

        Navigator.pop(context);
      };

      String major = user.major == null || user.major == '' ?  ''  :   ' / ' + user.major;
      String location = user.location == null || user.location == '' ? '' : ' / ' + user.location;

      showSheepsDialog(
        context: context,
        title: '팀 참가 요청',
        isLogo: false,
        imgUrl: user.profileUrlList[0],
        description: user.name + major + location,
        okText: '수락할래요',
        okFunc: okFunc,
        cancelText: '거절할래요',
        cancelFunc: cancelFunc,
        isBarrierDismissible: true,
      );

      break;
  }

  return Future.value(true);
}

bool isHaveButton(BuildContext context, int type){
  bool res = false;

  if(type == NOTI_EVENT_INVITE || type == NOTI_EVENT_TEAM_INVITE || type == NOTI_EVENT_TEAM_REQUEST)
    res = true;

  return res;
}

void SetNotificationData(NotificationModel model, List<int> chatList){
  switch(model.type){
    case NOTI_EVENT_INVITE_ACCEPT:
      ChatGlobal.roomInfoList.insert(0,SetRoomInfoData(model));
      break;
    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
      bool isRoom = false;
      int index = 0;

      for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
        if(ChatGlobal.roomInfoList[i].roomName == model.teamRoomName){
          ChatGlobal.roomInfoList[i].chatUserIDList.add(model.from);
          GlobalProfile.getTeamByRoomName(model.teamRoomName).userList.add(model.from);
          index = i;
          isRoom = true;
          break;
        }
      }

      if(false == isRoom) {
        ChatGlobal.roomInfoList.insert(0,SetTeamRoomInfoData(model));
        index = ChatGlobal.roomInfoList.length - 1;
      }

      if(chatList != null){
        for(int i = 0; i < chatList.length; ++i){
          ChatGlobal.roomInfoList[index].chatUserIDList.add(chatList[i]);
        }
      }


      break;
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
      bool isRoom = false;
      int index = 0;

      for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
        if(ChatGlobal.roomInfoList[i].roomName == model.teamRoomName){
          ChatGlobal.roomInfoList[i].chatUserIDList.add(model.from);
          GlobalProfile.getTeamByRoomName(model.teamRoomName).userList.add(model.from);
          isRoom = true;
          index = i;
          break;
        }
      }

      if(false == isRoom) {
        ChatGlobal.roomInfoList.insert(0, SetTeamRoomInfoData(model));
        index = ChatGlobal.roomInfoList.length - 1;
      }

      if(chatList != null){
        for(int i = 0; i < chatList.length; ++i){
          ChatGlobal.roomInfoList[index].chatUserIDList.add(chatList[i]);
        }
      }

      break;
    case NOTI_EVENT_TEAM_MEMBER_ADD:
      for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
        if(ChatGlobal.roomInfoList[i].roomName == model.teamRoomName){
          ChatGlobal.roomInfoList[i].chatUserIDList.add(model.from);
          break;
        }
      }
      break;
  }
}

Future notiClickEvent(BuildContext context, NotificationModel notificationModel, ProfileState profileState, NavigationNum navigationNum) async {

  switch(notificationModel.type){
    case NOTI_EVENT_PROFILE_LIKE:
    case NOTI_EVENT_TEAM_LIKE:
    case NOTI_EVENT_TEAM_REQUEST:
    case NOTI_EVENT_TEAM_INVITE_ACCEPT:
    case NOTI_EVENT_TEAM_INVITE_REFUSE:
    case NOTI_EVENT_TEAM_MEMBER_ADD:
      UserData user = GlobalProfile.getUserByUserID(notificationModel.from);

      if(user != null){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new DetailProfile(
                    index: 0,
                    user: user
                )));
      }
      break;
    case NOTI_EVENT_TEAM_REQUEST_ACCEPT:
    case NOTI_EVENT_TEAM_REQUEST_REFUSE:
    case NOTI_EVENT_TEAM_INVITE:
      Team team;
      if(notificationModel.teamRoomName != null && notificationModel.teamRoomName != 'null'){
        team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
      }
      else{
        team = GlobalProfile.getTeamByID(notificationModel.index);
      }

      if(team != null){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new DetailTeamProfile(
                    index: 0,
                    team: team)));
      }
      break;
    case NOTI_EVENT_POST_LIKE:
    case NOTI_EVENT_POST_REPLY:
    case NOTI_EVENT_POST_REPLY_LIKE:
    case NOTI_EVENT_POST_REPLY_REPLY:
    case NOTI_EVENT_POST_REPLY_REPLY_LIKE:
      var resCommunity = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({
        "id" : notificationModel.index
      }));

      if(resCommunity != null){

        Community community = Community.fromJson(resCommunity);

        var tmp = await ApiProvider().post('/CommunityPost/PostSelect',jsonEncode({
          "id" : community.id
        }));

        if (tmp == null) return;

        GlobalProfile.communityReply = new List<CommunityReply>();
        for (int i = 0; i < tmp.length; i++) {
          Map<String, dynamic> data = tmp[i];
          CommunityReply tmpReply = CommunityReply.fromJson(data);
          GlobalProfile.communityReply.add(tmpReply);
        }

        Navigator.push(
            navigatorKey.currentContext, // 기본 파라미터, SecondRoute로 전달
            MaterialPageRoute(
                builder: (context) =>
                    CommunityMainDetail(community)));
      }
      break;
    case NOTI_EVENT_PROFILE_MODIFY_RECOMMEND:
      Navigator.push(
          context, // 기본 파라미터, SecondRoute로 전달
          MaterialPageRoute(
              builder: (context) => MyProfileModify()));
      break;
    case NOTI_EVENT_TEAM_PROFILE_ADD_RECOMMEND:
      Navigator.push(
          context, // 기본 파라미터, SecondRoute로 전달
          MaterialPageRoute(
              builder: (context) =>
                  AddTeam()) // SecondRoute를 생성하여 적재
      );
      break;
    case NOTI_EVENT_TEAM_PROFILE_JOIN_RECOMMEND:
      profileState.setNum(1);
      navigationNum.setNum(PROFILE_PAGE);
      Navigator.of(context).pushNamedAndRemoveUntil("/MainPage", (route) => false);
      break;
    default: break;
  }

  return Future.value(true);
}

bool isHaveReadNoti(){
  bool res = false;
  for(int i = 0 ; i < notiList.length; ++i){
    if(notiList[i].isRead == 0) {
      res = true;
      break;
    }
  }

  return res;
}

void setNotiListRead() {
  for(int i = 0 ; i < notiList.length; ++i){
    if(notiList[i].isRead == 0){
      notiList[i].isRead = 1;
      NotiDBHelper().updateDate(notiList[i].id, 1);
    }
  }
}