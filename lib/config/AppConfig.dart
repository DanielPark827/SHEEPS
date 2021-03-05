import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Setting/model/Banner.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/FirebaseNotification.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sheeps_app/userdata/User.dart';

////////////////////////////공통변수는 여기에 추가//////////////////////////////////
double screenWidth = 360;
double screenHeight = 640;
bool AllNotification = true;
bool isNewMemeber=false;
String globalNotificationType = 'NOTIFICATION';

const int MAX_PREV_CHAT_MESSAGE = 20;
const int ROOM_STATUS_ROOM = 0;
const int ROOM_STATUS_CHAT = 1;
const int ROOM_STATUS_ETC = 2;

final int DASHBOARD_MAIN_PAGE = 0;
final int PROFILE_PAGE = 1;
final int COMMUNITY_MAIN_PAGE =2;
final int CHATROOM_PAGE = 3;
final int TEAM_RECRUIT_PAGE = 4;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

// final int TOTAL_NOTIFICATION_PAGE=4;
//
// final int MY_PAGE_PAGE=5;
// final int MY_PROFILES_PAGE=6;
// final int MY_COMMUNITY_PAGE=7;
//
// final int FILTER_AFTER_SELECT_PAGE = 8;

////////////////////////////공통함수는 여기에 추가//////////////////////////////////
Size screenSize(BuildContext context){
  return  MediaQuery.of(context).size;
}

void setScreenWidth(BuildContext context, {double divededBy = 1}){
  screenWidth = screenSize(context).width / divededBy;
}

void setScreenHeight(BuildContext context, {double divededBy = 1}){
  screenHeight = screenSize(context).height / divededBy;
}

Color hexToColor(String code) {
  //int.parse : 문자열을 정수로 파싱
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

String GetWeekDay(String WeekDay) {
  if(WeekDay == 'Monday')
    return '월요일';
  else if(WeekDay == 'Tuesday')
    return '화요일';
  else if(WeekDay == 'Wednesday')
    return '수요일';
  else if(WeekDay == 'Thursday')
    return '목요일';
  else if(WeekDay == 'Friday')
    return '금요일';
  else if(WeekDay == 'Saturday')
    return '토요일';
  else if(WeekDay == 'Sunday')
    return '일요일';
}

String getYearMonthDayByString(String date){
  return date[0] + date[1] + date[2] + date[3] + date[4] + date[5] + date[6] + date[7];
}

String getYearMonthDayByDate(){
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month < 10 ? '0' + DateTime.now().month.toString() : DateTime.now().month.toString();
  String day = DateTime.now().day < 10 ? '0' + DateTime.now().day.toString() : DateTime.now().day.toString();

  return year+month+day;
}

String getPrevRoomDate(String date) {
  String year = DateTime.now().year.toString();
  String month = DateTime.now().month < 10 ? '0' + DateTime.now().month.toString() : DateTime.now().month.toString();
  String day = DateTime.now().day < 10 ? '0' + DateTime.now().day.toString() : DateTime.now().day.toString();

  String strYear = date[0] + date[1] + date[2] + date[3];
  String strDay = date[6] + date[7];

  String res = year+month+day;

  //해가 다르면
  if(year != strYear) {
    res = year + ". " + month + ". " + day + ".";
  }else if ((int.parse(day) - int.parse(strDay)) > 1){
    res = DateTime.now().month.toString() + "월 " + DateTime.now().day.toString() + "일";
  }else{
    res = "어제";
  }

  return res;
}

String setDateAmPm(String date, bool isAmPM, String updatedAt){
  if(date == null) return '';

  int index = date.indexOf(":");
  int sub = int.parse(date.substring(0, index));
  String subRest = date.substring(index+1, date.length);
  String AmOrPM = "오전 ";

  if(true == isAmPM){
    sub = sub + 9;
  }

  if(sub >= 12) {
    AmOrPM = "오후 ";
    sub = sub - 12;

    if(sub == 0)
      sub = 12;
  }

  if(updatedAt == null){
    return AmOrPM + sub.toString() + ":" + subRest;
  }

  if(int.parse(getYearMonthDayByString(updatedAt)) == int.parse(getYearMonthDayByDate())) {
    return AmOrPM + sub.toString() + ":" + subRest;
  }

  return getPrevRoomDate(updatedAt);
}

String getRoomName(int ID1, int ID2, bool isTeam){
  int lowNum = ID1;
  int bigNum = ID2;

  String header = "userID";

  if((lowNum > bigNum) && !isTeam){
    int temp = lowNum;
    lowNum = bigNum;
    bigNum = temp;
  }

  if(isTeam) header = "teamID";

  return header + lowNum.toString() + "userID" + bigNum.toString();
}

String replaceDate(String date){
  int index = date.lastIndexOf('.') == -1 ? date.length : date.lastIndexOf('.');

  String replaceStr = date.substring(0, index);
  return  replaceStr.replaceAll('T', ' ').replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '');
}

String replaceDateToShow(String dateStr){
  DateTime date = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse( dateStr, true);

  return (date.hour + 9).toString() + ":" + date.minute.toString();
}

String replaceUTCDate(String dateStr){

  DateTime date = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(dateStr, true);
  date = date.add(Duration(hours: 9));


  int index = date.toString().lastIndexOf('.') == -1 ? date.toString().length : date.toString().lastIndexOf('.');

  String replaceStr = date.toString().substring(0, index);


  return replaceStr.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');
}

String replaceUTCDatetest(String dateStr){
  DateTime date = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(dateStr, true);

  return date.toLocal().toString().replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');
}

String replacLocalUTCDate(String dateStr){
  DateTime date = new DateFormat("yyyy-MM-dd HH:mm:ssZ").parse(dateStr, true);
  date = date.add(Duration(hours: 9));

  String d = date.toString().substring(0, date.toString().indexOf('.'));

  return d.replaceAll('-', '').replaceAll(':', '').replaceAll('.', '').replaceAll(' ', '');
}

Future<String> getFileURL() async {
  Directory documentsDirectory = await getTemporaryDirectory();
  return documentsDirectory.path + '/' + DateFormat('yyyyMMddHHmmss"').format(DateTime.now().toLocal())+ ".png";
}

String getOptimizeImageURL(String name, int size) {
  if(size == 0) return name;

  String strHead = name.substring(0, name.lastIndexOf('.'));
  String strTail = name.substring(name.lastIndexOf('.'), name.length);

  return  strHead + '_' + size.toString() + strTail;
}

String timeCheck(String tmp) {

  int year = int.parse(tmp[0] + tmp[1] + tmp[2] + tmp[3]);
  int month = int.parse(tmp[4] + tmp[5]);
  int day = int.parse(tmp[6] + tmp[7]);
  int hour = int.parse(tmp[8] + tmp[9]);
  int minute = int.parse(tmp[10] + tmp[11]);
  int second = int.parse(tmp[12] + tmp[13]);

  final date1 = DateTime(year, month, day, hour, minute, second);
  var date2 = DateTime.now();
  final differenceDays = date2.difference(date1).inDays;
  final differenceHours = date2.difference(date1).inHours;
  final differenceMinutes = date2.difference(date1).inMinutes;
  final differenceSeconds = date2.difference(date1).inSeconds;

  if (differenceDays > 7) {
    return "$month" + "월 " + "$day" + "일";
  } else if (differenceDays == 7) {
    return "일주일전";
  } else {
    if (differenceDays > 1) {
      return "$differenceDays" + "일전";
    } else if (differenceDays == 1) {
      return "하루전";
    } else{
      if (differenceHours >= 1) {
        return "$differenceHours" + "시간전";
      } else {
        if (differenceMinutes >= 1) {
          return "$differenceMinutes" + "분전";
        } else {
          if(differenceSeconds>=0){
            return "$differenceSeconds" +"초전";
          }
          else{
            return "error";
          }
        }
      }
    }
  }
}

Future permissionRequest() async {

  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.notification
  ].request();

}

Future<bool> getNotiByStatus() async {
  bool isNoti;
  var status = await Permission.notification.status;

  switch(status){
    case PermissionStatus.denied:
      isNoti = false;
      break;
    case PermissionStatus.granted:
      isNoti = true;
      break;
    default:
      isNoti = false;
      break;
  }

  return isNoti;
}

String getFileName(int index, String filePath){
  return GlobalProfile.loggedInUser.userID.toString() + '_' + DateTime.now().millisecondsSinceEpoch.toString() + index.toString() + getMimeType(filePath);
}

String getMimeType(String file){
  return file.substring(file.lastIndexOf('.'), file.length);
}

Future<List<File>> UrlToFile(List<String> urlList) async {
  List<File> subList;

  for(int i = 0; i < urlList.length; i++) {
    final response = await http.get(urlList[i]);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, urlList[i] + '.jpeg'));
    file.writeAsBytesSync(response.bodyBytes);
    subList.add(file);
  }

  return subList;
}

Future globalLogin(BuildContext context, SocketProvider provider, dynamic result, {bool isHandLogin = true}) async {

  try {
    EasyLoading.show(status: "로그인 중...");

    UserData user = UserData.fromJson(result['result']);
    GlobalProfile.loggedInUser = user;
    GlobalProfile.accessToken = result['AccessToken'];
    GlobalProfile.refreshToken = result['RefreshToken'];
    GlobalProfile.accessTokenExpiredAt = result['AccessTokenExpiredAt'];
    GlobalProfile.acceceTokenCheck();

    //Personal Profile 데이터 get
    GlobalProfile.personalProfile.clear();
    var tmp3 = await ApiProvider().post('/Profile/Personal/UserList', jsonEncode(
        {
          "userID" : GlobalProfile.loggedInUser.userID
        }
    ));
    if(tmp3 != null) {
      for (int i = 0; i < tmp3.length; i++) {
        UserData _userTmp = UserData.fromJson(tmp3[i]);
        GlobalProfile.personalProfile.add(_userTmp);
      }
    }

    GlobalProfile.teamProfile.clear();
    var tmp4 = await ApiProvider().get('/Team/Profile/Select');
    if( tmp4 != null) {
      for (int i = 0; i < tmp4.length; i++) {
        Team _userTmp = Team.fromJson(tmp4[i]);
        GlobalProfile.teamProfile.add(_userTmp);
      }
    }


    var chatLogList = await ApiProvider().post('/ChatLog/UnSendSelect', jsonEncode(
        {
          "userID" : user.userID
        }
    ));

    ChatGlobal.roomInfoList.clear();
    //join된 방들 List 받음
    var list = await ApiProvider().post('/Room/User/Select', jsonEncode(
        {
          "userID" : GlobalProfile.loggedInUser.userID
        }
    ));

    if(null != list){
      //방 List 재조합
      for(int i = 0 ; i < list.length; ++i){
        List<dynamic> temp = list[i];

        if(temp.isEmpty) continue;

        RoomInfo roomInfo = new RoomInfo();

        Map<String, dynamic> data = temp[0];
        String roomName = data['RoomName'];
        List<dynamic> userListTemp = data['RoomUsers'];
        List<int> userList = List<int>();

        for(int j = 0 ; j < userListTemp.length; ++j){
          userList.add(userListTemp[j]['UserID']);
        }

        String roomNameSub = roomName.substring(0,4);
        bool isPersonal = false;

        //개인인지 팀인지 따라 세팅을 여러가지 해야함 chatList 부터 방이름 등등
        if(roomNameSub == 'user') isPersonal = true;

        if(isPersonal) {
          UserData userData = await GlobalProfile.getFutureUserByUserID(userList[0]);

          roomInfo.name = userData.name;
          roomInfo.profileImage = userData.profileUrlList[0];
        }
        else {
          Future.microtask(() async {
            await GlobalProfile.getFutureTeamByRoomName(roomName).then((value) {
              roomInfo.name = value.name;
              roomInfo.profileImage = value.profileUrlList[0];
            });
          });
        }

        List<ChatRecvMessageModel> chatList = (await ChatDBHelper().getRoomData(roomName)).cast<ChatRecvMessageModel>();

        //이미지 파일 미리 생성하는 부분
        for(int i = 0 ; i < chatList.length; ++i){
          if(chatList[i].isImage == 1){
            var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({
              "id" : int.parse(chatList[i].message)
            }));

            chatList[i].fileMessage = await base64ToFileURL(getImageData['message']);
          }
        }

        if(chatLogList != null){
          for(int i = 0 ; i < chatLogList.length; ++i){
            ChatRecvMessageModel message = ChatRecvMessageModel(
              chatId: chatLogList[i]['id'],
              roomName: chatLogList[i]['roomName'],
              to: chatLogList[i]['to'].toString(),
              from : chatLogList[i]['from'],
              message: chatLogList[i]['message'],
              date: chatLogList[i]['date'],
              isRead: 0,
              isImage: chatLogList[i]['isImage'],
              updatedAt: replaceUTCDate(chatLogList[i]['updatedAt']),
              createdAt: replaceUTCDate(chatLogList[i]['createdAt']),
            );

            if(message.roomName == roomName) {
              await ChatDBHelper().createData(message);
              chatList.add(message);
            }
          }
        }
        int messageCount = 0;

        if(chatList != null){
          for(int j = 0 ; j < chatList.length; ++j){
            if(0 == chatList[j].isRead)
              messageCount += 1;
          }
        }

        String message = chatList.length == 0 ? "" : chatList[chatList.length-1].message;
        if(message != null && message.isNotEmpty){
          if(chatList[chatList.length-1].isImage == 1){
            message = "사진을 보내셨습니다.";
          }
        }
        String date = chatList.length == 0 ? "" : setDateAmPm(chatList[chatList.length-1].date, false,replaceUTCDate(data['updatedAt']));

        String roomCreateDate = replaceUTCDate(list[i][0]['createdAt']);
        ChatRecvMessageModel roomCreateTime = ChatRecvMessageModel(
            to: CENTER_MESSAGE.toString(),
            from: CENTER_MESSAGE,
            roomName: roomName,
            message: roomCreateDate[0] + roomCreateDate[1] + roomCreateDate[2] + roomCreateDate[3] + "년 " + roomCreateDate[4] + roomCreateDate[5] + "월 " + roomCreateDate[6] + roomCreateDate[7] + "일",
            isImage: 0,
            date: null,
            isRead: 1
        );

        chatList.insert(0, roomCreateTime);

        //이쪽 어디에서 오류
        roomInfo.roomName = roomName;
        roomInfo.date = date;
        roomInfo.isPersonal = isPersonal;
        roomInfo.lastMessage = message;
        roomInfo.messageCount = messageCount;
        roomInfo.chatList = chatList;
        roomInfo.chatUserIDList = userList;
        roomInfo.updateAt = replaceUTCDate(data['updatedAt']);
        roomInfo.createdAt = replaceUTCDate(data['createdAt']);
        ChatGlobal.roomInfoList.add(roomInfo);
      }
    }

    ChatGlobal.sortRoomInfoList();

    notiList.clear();
    notiList = await NotiDBHelper().getAllData();
    if(isHandLogin) await SetHandLoginNotificationListByEvent();
    await SetNotificationListByEvent();

    if(isNewMemeber){
      SetNotificationListToNewMember();
    }else{
      if(!kReleaseMode) SetNotificationListToNewMember();
    }

    //커뮤니티 신규게시글 받아오는곳
    GlobalProfile.newCommunityList.clear();
    List<dynamic> tmp = new List<dynamic>();
    tmp = await ApiProvider().get('/CommunityPost/Select/BasicPost');
    for (int i = 0; i < tmp.length; i++) {
      Community community =
      Community.fromJson(tmp[i]);
      GlobalProfile.newCommunityList.add(community);
      await GlobalProfile.getFutureUserByUserID(community.userID);
    }


    //커뮤니티  인기게시글 받아오는곳
    GlobalProfile.popularCommunityList.clear();

    tmp = new List<dynamic>();
    await ApiProvider().get('/CommunityPost/Select/PopularBasicPost').then((value) async{

      for (int i = 0; i < value.length; i++) {
        Community community = Community.fromJson(value[i]);
        GlobalProfile.popularCommunityList.add(community);
        await GlobalProfile.getFutureUserByUserID(community.userID);
      }
    });


    //커뮤니티 직군별 신규게시글 받아오은곳
    GlobalProfile.newCommunityListByJob.clear();
    tmp = new List<dynamic>();
    tmp = await ApiProvider().get('/CommunityPost/Select/JobGroupPost');
    for (int i = 0; i <  tmp.length; i++) {
      Community community =
      Community.fromJson( tmp[i]);
      GlobalProfile.newCommunityListByJob.add(community);
      await GlobalProfile.getFutureUserByUserID(community.userID);
    }


    //커뮤니티 직군별 인기게시글 받아오는곳
    GlobalProfile.popularCommunityListByJob.clear();

    tmp = new List<dynamic>();
    await ApiProvider().get('/CommunityPost/Select/PopularJobGroupPost').then((value) async {
      if(value != null){
        for (int i = 0; i < value.length; i++) {
          Community community = Community.fromJson(value[i]);
          GlobalProfile.popularCommunityListByJob.add(community);
          await GlobalProfile.getFutureUserByUserID(community.userID);
        }
      }
    });
    
    //대시보드 메인에 쓸 최근 생성된 유저
    GlobalProfile.personalSampleProfile.clear();
    await ApiProvider().get('/Profile/Personal/NewUserSelect').then((value) async {
      if(value != null){
        for(int i = 0 ; i < value.length; ++i){
          GlobalProfile.personalSampleProfile.add(SampleUser.fromJson(value[i]));
        }
      }
    });

    //대시보드 메인에 쓸 최근 생성된 팀
    GlobalProfile.teamSampleProfile.clear();
    await ApiProvider().get('/Team/Profile/NewUserSelect').then((value) async {
      if(value != null){
        for(int i = 0 ; i < value.length; ++i){
          GlobalProfile.teamSampleProfile.add(SampleTeam.fromJson(value[i]));
        }
      }
    });

    await provider.initSocket(user);
    FirebaseNotifications().setFcmToken('');

    initAllBadge();
    //setWebBannerData();

    EasyLoading.dismiss();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('IfNewUser',true);

    Navigator.of(context).pushNamedAndRemoveUntil("/MainPage", (route) => false);
  } catch (e) {
    EasyLoading.showError(e.toString());
    print(e);
  }
}