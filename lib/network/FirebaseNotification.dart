import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import 'package:sheeps_app/chat/TeamChatPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/TotalNotificationPage.dart';
import 'package:sheeps_app/notification/models/LocalNotiProvider.dart';
import 'package:sheeps_app/notification/models/LocalNotification.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';


bool isFirebaseCheck = false;
//Firebase관련 class
class FirebaseNotifications {
  static FirebaseMessaging _firebaseMessaging;
  static String _fcmToken = '';

  static bool isMarketing = false;
  static bool isChatting = false;
  static bool isTeam = false;
  static bool isCommuntiy = false;


  FirebaseMessaging get getFirebaseMessaging => _firebaseMessaging;
  SocketProvider socket;
  LocalNotification _localNotification;
  String get getFcmToken => _fcmToken;


  void setFcmToken (String token) {
    _fcmToken = token;
    isFirebaseCheck = false;
  }

  FirebaseNotifications(){

  }

  void setUpFirebase(BuildContext context) {
    if(isFirebaseCheck == false){
      isFirebaseCheck = true;
    }else{
      return;
    }

    if(null == _localNotification) _localNotification = Provider.of<LocalNotiProvider>(context).localNotification;
    if(null == socket) socket = Provider.of<SocketProvider>(context);


    Future.microtask(() async {
      _firebaseMessaging = FirebaseMessaging();

      await _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
      );

      firebaseCloudMessaging_Listeners();
      return _firebaseMessaging;
    }) .then((_) async{
      if(_fcmToken == ''){
        _fcmToken = await _.getToken();

        var res = await ApiProvider().post('/Fcm/Token/Save', jsonEncode({
          "userID" : GlobalProfile.loggedInUser.userID,
          "token" : _fcmToken,
        }));

        if(res != null){
          FirebaseNotifications.isMarketing = res['item']['Marketing'] == null ? true : res['item']['Marketing'];
          FirebaseNotifications.isChatting = res['item']['Chatting'] == null ? true : res['item']['Chatting'];
          FirebaseNotifications.isTeam = res['item']['Team'] == null ? true : res['item']['Team'];
          FirebaseNotifications.isCommuntiy = res['item']['Community'] == null ? true : res['item']['Community'];

          SetSubScriptionToTopic("SHEEPS_MARKETING");
        }
      }
      return;
    });
  }

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message){
    if(message.containsKey('data'))
      if(message.containsKey('notification')){
        final dynamic notification = message['notification'];
      }
  }


  void firebaseCloudMessaging_Listeners() {

    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      print(token);
    });


    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint('on message $message');

        Future.microtask(() async {
          if(Platform.isAndroid) return (message['data']['body'] as String).split('|');
          return (message['body'] as String).split('|');
        }).then((strList) async {
          if(kReleaseMode){
            if(Platform.isAndroid){
              if(message['notification']['body'] == 'undefined') return;
            }else if(Platform.isIOS){ //에뮬은 해당부분으로 안들어옴.. 실제 기기일때만 해당부분으로 나옴.
              if(message['aps']['alert']['body'] == 'undefined') return;
            }
          }else{
            if(message['notification']['body'] == 'undefined') return;
          }

          if(strList != null && strList.length != 0 && strList[0].length != 0 && strList[0] != ''){
            if(strList[3] == 'LOGOUT'){
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('autoLoginKey',false);
              prefs.setString('autoLoginId', null);
              prefs.setString('autoLoginPw', null);

              Fluttertoast.showToast(msg: ("다른 기기에서 로그인하여 로그아웃됩니다.\n로그인 페이지로 이동합니다."),);

              socket.disconnect();
              await Future.delayed(Duration(microseconds: 3000));
              Navigator.push(
                  navigatorKey.currentContext,
                  // 기본 파라미터, SecondRoute로 전달
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginSelectPage()));
            }

            NotificationModel notificationModel = NotificationModel(
              id:  int.parse(strList[0]),
              from: int.parse(strList[1]),
              to: int.parse(strList[2]),
              type: GetType(strList[3]),
              index: int.parse(strList[4]),
              time: strList[5],
              isRead: 0,
            );
            notificationModel.isSend = 0;

            if(notificationModel.type == NOTI_EVENT_TEAM_INVITE || notificationModel.type == NOTI_EVENT_TEAM_INVITE_ACCEPT ||
                notificationModel.type == NOTI_EVENT_TEAM_REQUEST || notificationModel.type == NOTI_EVENT_TEAM_REQUEST_ACCEPT ||
                notificationModel.type == NOTI_EVENT_TEAM_REQUEST_REFUSE || notificationModel.type == NOTI_EVENT_TEAM_MEMBER_ADD ||
            notificationModel.type == NOTI_EVENT_POST_LIKE || notificationModel.type == NOTI_EVENT_POST_REPLY || notificationModel.type == NOTI_EVENT_POST_REPLY_LIKE ||
            notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY || notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY_LIKE
            ){
              notificationModel.teamRoomName = strList[6];

              if(strList[6] != null && strList[6] == 'null'){
                notificationModel.teamRoomName = null;
              }
            }

            notiList.insert(0, notificationModel);
            NotiDBHelper().createData(notificationModel);

            //여기가 필요함.
            if(notificationModel.type == NOTI_EVENT_TEAM_REQUEST_ACCEPT){
              Team team;
              if(notificationModel.teamRoomName != null){
                team = GlobalProfile.getTeamByRoomName(notificationModel.teamRoomName);
              }
              else{
                team = GlobalProfile.getTeamByID(notificationModel.index);
              }

              var res = await ApiProvider().post('/Team/WithoutTeamList', jsonEncode(
                {
                  "to" : notificationModel.to,
                  "from" : notificationModel.from,
                  "teamID" : team.id
                }
              ));

              List<int> chatList = new List<int>();

              if(res != null){
                for(int i = 0 ; i < res.length; ++i){
                  chatList.add(res[i]['UserID']);
                }
              }
              SetNotificationData(notificationModel, chatList);
            }
            else{
              SetNotificationData(notificationModel, null);
            }
          }

          if(strList[3] != 'LOGOUT'){
            if(kReleaseMode){
              if(Platform.isAndroid){
                globalNotificationType = message['data']['screen'] as String;
                Future.microtask(() async => await _localNotification.showNoti(title: message['notification']['title'] as String, des: message['notification']['body'] as String, payload: strList[4]));
              }else if(Platform.isIOS){
                globalNotificationType = message['screen'] as String;
                Future.microtask(() async => await _localNotification.showNoti(title: message['aps']['alert']['title']as String, des: message['aps']['alert']['body'] as String, payload: strList[4]));
              }
            }else{
              globalNotificationType = message['data']['screen'] as String;
              Future.microtask(() async => await _localNotification.showNoti(title: message['notification']['title'] as String, des: message['notification']['body'] as String, payload: strList[4]));
            }
          }

          return;
        });
      },
      onResume: (Map<String, dynamic> message) async {
        debugPrint('on resume $message');

        await screenControllFunc(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('on launch $message');

        await screenControllFunc(message);
      },
      //onBackgroundMessage: myBackgroundMessageHandler
    );
  }

  Future screenControllFunc(Map<String, dynamic> message) async {
    var screen = 'NOTIFICATION';
    List<String> list = new List<String>();

    if(kReleaseMode){
      if(Platform.isAndroid){
        screen = message['data']['screen'] as String;
        list = (message['data']['body'] as String).split('|');
      }else{
        screen = message['aps']['alert']['screen'] as String;
        list =  (message['aps']['alert']['body'] as String).split('|');
      }
    }else{
      screen = message['data']['screen'] as String;
      list = (message['data']['body'] as String).split('|');
    }

    switch(screen){
      case "NOTIFICATION":
        {
          Navigator.push(
              navigatorKey.currentContext,
              // 기본 파라미터, SecondRoute로 전달
              MaterialPageRoute(
                  builder: (context) =>
                      TotalNotificationPage()));
        }
        break;
      case "CHATROOM":
        {
          var roomName = Platform.isAndroid ? message['data']['body'] as String : message['body'];

          socket.setRoomStatus(ROOM_STATUS_CHAT);

          for(int i = 0; i < ChatGlobal.roomInfoList.length; ++i){
            if(roomName == ChatGlobal.roomInfoList[i].roomName){

              if(ChatGlobal.currentRoomIndex != i){
                RoomInfo roomInfo = ChatGlobal.roomInfoList[i];

                if(roomInfo.isPersonal){
                  Navigator.push(
                      navigatorKey.currentContext,
                      MaterialPageRoute(
                          builder: (context) => new ChatPage(
                            roomName: roomInfo.roomName,
                            chatUser: GlobalProfile.getUserByUserID(roomInfo.chatUserIDList[0]),))).then((value){
                    socket.setPrevStatus();
                  });
                }else{
                  Navigator.push(
                      navigatorKey.currentContext,
                      MaterialPageRoute(
                          builder: (context) => new TeamChatPage(
                              roomName: roomName,
                              titleName: roomInfo.name,
                              chatUserList: GlobalProfile.getUserListByUserIDList(roomInfo.chatUserIDList)))).then((value){
                    socket.setPrevStatus();
                  });
                }
                break;
              }
            }
          }
        }
        break;
      case "COMMUNITY":
        {
          debugPrint('on COMMUNITY $list');

          var resCommunity = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({
            "id" : list[4]
          }));

          Community community = Community.fromJson(resCommunity);

          var tmp = await ApiProvider().post('/CommunityPost/PostSelect',jsonEncode({
              "id" : list[4],
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
    }
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      debugPrint("Settings registered: $settings");
    });
  }

  showNotification(Map<String, dynamic> msg){
  }

  void SetSubScriptionToTopic(String topic){
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void SetUnSubScriptionToTopic(String topic){
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}