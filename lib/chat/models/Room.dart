import 'package:intl/intl.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

import 'ChatRecvMessageModel.dart';

class Room {
  String roomName;
  List<int> chatUserIDList;

  Room(String str, {this.roomName, this.chatUserIDList});
}

class RoomInfo {
  String name;
  String roomName;
  String lastMessage;
  String date;
  String profileImage;
  int messageCount;
  bool isPersonal;
  List<ChatRecvMessageModel> chatList;
  List<int> chatUserIDList;
  String updateAt;
  String createdAt;

  RoomInfo({this.name, this.roomName, this.lastMessage, this.date, this.profileImage, this.messageCount, this.isPersonal, this.chatList, this.chatUserIDList, this.updateAt, this.createdAt});
}

RoomInfo SetRoomInfoData(NotificationModel model){
  List<int> chatList = new List<int>();
  chatList.add(model.from);

  RoomInfo roomInfo = RoomInfo();

  DateTime date = new DateFormat("yyyy-MM-dd HH:mm:ss").parse( model.time, true);

  String updatedDate = model.time.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');

  roomInfo.name =  GlobalProfile.getUserByUserID(model.from).name;
  roomInfo.roomName = getRoomName(model.to, model.from, false);
  roomInfo.lastMessage = "";
  roomInfo.date = setDateAmPm(date.hour.toString() + ":" + date.minute.toString(), false, updatedDate);
  roomInfo.profileImage = GlobalProfile.getUserByUserID(model.from).profileUrlList[0];
  roomInfo.messageCount = 0;
  roomInfo.chatList = new List<ChatRecvMessageModel>();
  roomInfo.isPersonal = true;
  roomInfo.chatUserIDList = chatList;
  roomInfo.updateAt = updatedDate;
  roomInfo.createdAt = updatedDate;

  ChatRecvMessageModel roomCreateTime = ChatRecvMessageModel(
      to: CENTER_MESSAGE.toString(),
      from: CENTER_MESSAGE,
      roomName: roomInfo.roomName,
      message: updatedDate[0] + updatedDate[1] + updatedDate[2] + updatedDate[3] + "년 " + updatedDate[4] + updatedDate[5] + "월 " + updatedDate[6] + updatedDate[7] + "일",
      isImage: 0,
      date: null,
      isRead: 1
  );

  roomInfo.chatList.insert(0, roomCreateTime);

  return roomInfo;
}

RoomInfo SetTeamRoomInfoData(NotificationModel model){
  List<int> chatList = new List<int>();
  chatList.add(model.from);

  Team team;
  if(model.teamRoomName != null){
    team = GlobalProfile.getTeamByRoomName(model.teamRoomName);
  }
  else{
    team = GlobalProfile.getTeamByID(model.index);
  }

  RoomInfo roomInfo = RoomInfo();

  String updatedDate = model.time.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');

  roomInfo.name = team.name;
  roomInfo.roomName =  model.teamRoomName;
  roomInfo.lastMessage = "";
  roomInfo.date = setDateAmPm(updatedDate[8] + updatedDate[9] + ":" + updatedDate[10] + updatedDate[11], false, updatedDate);
  roomInfo.profileImage = team.profileUrlList[0];
  roomInfo.messageCount = 0;
  roomInfo.chatList = new List<ChatRecvMessageModel>();
  roomInfo.isPersonal = false;
  roomInfo.chatUserIDList = chatList;
  roomInfo.updateAt = updatedDate;
  roomInfo.createdAt = updatedDate;

  ChatRecvMessageModel roomCreateTime = ChatRecvMessageModel(
      to: CENTER_MESSAGE.toString(),
      from: CENTER_MESSAGE,
      roomName: roomInfo.roomName,
      message: updatedDate[0] + updatedDate[1] + updatedDate[2] + updatedDate[3] + "년 " + updatedDate[4] + updatedDate[5] + "월 " + updatedDate[6] + updatedDate[7] + "일",
      isImage: 0,
      date: null,
      isRead: 1
  );

  roomInfo.chatList.insert(0, roomCreateTime);

  return roomInfo;
}
