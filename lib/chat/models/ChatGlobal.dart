import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import './ChatDatabase.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import './Room.dart';
import 'package:sheeps_app/userdata/User.dart';


const int CENTER_MESSAGE = -1;
class ChatGlobal with ChangeNotifier {

  // Single Chat - To Chat User
  static List<RoomInfo> roomInfoList = new List<RoomInfo>();

  List<RoomInfo> get getRoomInfoList => roomInfoList;

  static UserData toChatUser;
  static String roomName;
  static bool bCheck = false;
  static int currentRoomIndex = -1;
  static SocketProvider socket;

  Future<String> addChatRecvMessage(ChatRecvMessageModel chatRecvMessageModel, int index, {doSort = true}) async{
    if(chatRecvMessageModel.isRead.isOdd){
      roomInfoList[index].messageCount = 0;
    }else{
      roomInfoList[index].messageCount += 1;
    }

    String roomMessage = chatRecvMessageModel.message;

    if(chatRecvMessageModel.isImage == 1) roomMessage = "사진을 보냈습니다.";

    roomInfoList[index].date = setDateAmPm(chatRecvMessageModel.date, false, chatRecvMessageModel.updatedAt);
    roomInfoList[index].lastMessage = roomMessage;
    roomInfoList[index].updateAt = chatRecvMessageModel.updatedAt;
    roomInfoList[index].createdAt = chatRecvMessageModel.createdAt;
    chatRecvMessageModel.fileMessage = await ChatDBHelper().createData(chatRecvMessageModel);
    roomInfoList[index].chatList.add(chatRecvMessageModel);

    if(doSort){
      sortRoomInfoList();
    }

    notifyListeners();
    return chatRecvMessageModel.message;
  }

  static sortRoomInfoList() {
    List<RoomInfo> list = roomInfoList;

    list.sort((a,b) {
      return int.parse(b.updateAt).compareTo(int.parse(a.updateAt));
    });

    roomInfoList = list;
  }

  sortLocalRoomInfoList() {
    List<RoomInfo> list = roomInfoList;

    list.sort((a,b) => int.parse(b.updateAt).compareTo(int.parse(a.updateAt)));

    roomInfoList = list;
  }

  void setContinue(ChatRecvMessageModel chatRecvMessageModel, int prevIndex, int roomIndex){
    if(prevIndex > 0){
      if(chatRecvMessageModel.isContinue == false) return;
      if(roomInfoList[roomIndex].chatList[prevIndex].from != CENTER_MESSAGE){
        bool isContinue = (chatRecvMessageModel.from == roomInfoList[roomIndex].chatList[prevIndex].from) && (chatRecvMessageModel.date == roomInfoList[roomIndex].chatList[prevIndex].date);
        if(true == isContinue) {
          roomInfoList[roomIndex].chatList[prevIndex].isContinue = false;
        }
        else {
          roomInfoList[roomIndex].chatList[prevIndex].isContinue = true;
        }
      }
    }
  }
}

Future<String> base64ToFileURL(String base) async {
  final decodedBytes = base64Decode(base);

  Directory documentsDirectory = await getApplicationDocumentsDirectory();

  String name = DateFormat('yyyyMMddHHmmss').format(DateTime.now().toLocal());

  var file = File(documentsDirectory.path + '/' +  name + ".png");
  await file.writeAsBytes(decodedBytes);
  var fileUrl = file.path;
  return fileUrl;
}