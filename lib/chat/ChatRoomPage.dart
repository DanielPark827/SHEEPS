
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/chat/TeamChatPage.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import '../notification/models/LocalNotiProvider.dart';
import '../notification/models/LocalNotification.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import './models/ChatRecvMessageModel.dart';
import './models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class ChatRoomPage extends StatefulWidget {
  @override
  _ChatRoomPageState createState() => new _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> with SingleTickerProviderStateMixin {
  double sizeUnit = 1;

  ChatGlobal _chatGlobal;

  String teamIconName = "assets/images/Chat/teamIcon.svg";

  AnimationController extendedController;
  LocalNotification _localNotification;
  SocketProvider _socket;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);

  }

  int getDigit(int num) {
    int i = 1;
    int cnt = 0;

    while (num >= i) {
      i *= 10;
      cnt++;
    }

    return cnt;
  }

  @override
  void dispose() {
    extendedController.dispose();
    super.dispose();
  }

  _chatBubble(int messageCount) {
    Color chatBgColor = hexToColor('#F9423A');

    String messageCountText = messageCount.toString();
    if (messageCount >= 100) messageCountText = "99+";

    if (messageCount == 0) return Container();

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF9423A),
        borderRadius: BorderRadius.circular(4*sizeUnit),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4*sizeUnit, vertical: 2*sizeUnit),
        child: Text(
          messageCountText,
          style: SheepsTextStyle.bProfile(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    if(null == _localNotification) _localNotification = Provider.of<LocalNotiProvider>(context).localNotification;
    if(null == _chatGlobal) _chatGlobal = Provider.of(context);

    if(null == _socket) _socket = Provider.of<SocketProvider>(context)
      ..socket.on(SocketProvider.ROOM_RECEIVED_EVENT, (data) {
        if(!mounted) return;
        ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel.fromJson(data);
        setState(() {
          for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
            if( ChatGlobal.roomInfoList[i].roomName == chatRecvMessageModel.roomName){
              chatRecvMessageModel.isRead = 0;
              _chatGlobal.addChatRecvMessage(chatRecvMessageModel, i);
              break;
            }
          }
        });

        return;
      });

    return ConditionalWillPopScope(
      shouldAddCallbacks: true,
      onWillPop: () {
        _socket.setRoomStatus(ROOM_STATUS_ETC);
        Navigator.pop(context, 'HotReload');
        return;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                  appBar: SheepsAppBar(context, '진행 중인 채팅',
                    backFunc: (){
                      _socket.setRoomStatus(ROOM_STATUS_ETC);
                      Navigator.pop(context, 'HotReload');
                    },
                  ),
                  body: SafeArea(
                    child: ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: SingleChildScrollView(
                            child: _chatGlobal.getRoomInfoList.length > 0 ?
                            ListView.separated(
                              separatorBuilder: (context,index) => Container(
                                  height: 1, width: double.infinity, color: Color(0xFFEFEFEF)),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _chatGlobal.getRoomInfoList.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  Container(
                                    width: 360*sizeUnit,
                                    height: 76*sizeUnit,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 12*sizeUnit, right: 16*sizeUnit, top: 8*sizeUnit, bottom: 8*sizeUnit),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap : () {
                                              bool isPersonal = _chatGlobal.getRoomInfoList[index].isPersonal;

                                              if(isPersonal){
                                                Navigator.push(context,
                                                    PageTransition(type: PageTransitionType.fade,
                                                        child: DetailProfile(
                                                            index: 0,
                                                            user: GlobalProfile.getUserByUserID(_chatGlobal.getRoomInfoList[index].chatUserIDList[0])
                                                        )
                                                    )
                                                ).then((value) {
                                                  setState(() {
                                                    _chatGlobal.sortLocalRoomInfoList();
                                                  });
                                                });
                                              }else{
                                                Navigator.push(context,
                                                    PageTransition(type: PageTransitionType.fade,
                                                        child: DetailTeamProfile(
                                                            index: 0,
                                                            team : GlobalProfile.getTeamByRoomName(_chatGlobal.getRoomInfoList[index].roomName)
                                                        )
                                                    )
                                                ).then((value) {
                                                  setState(() {
                                                    _chatGlobal.sortLocalRoomInfoList();
                                                  });
                                                });
                                              }
                                            },
                                            child:
                                            _chatGlobal.getRoomInfoList[index].profileImage == 'BasicImage' ?
                                            SvgPicture.asset(
                                              svgPersonalProfileBasicImage,
                                              width: 60*sizeUnit,
                                            ) :
                                            Container(
                                              width: 60*sizeUnit,
                                              height: 60*sizeUnit,
                                              child: ClipRRect(
                                                  borderRadius: new BorderRadius.circular(8*sizeUnit),
                                                  child: FittedBox(child: getExtendedImage(_chatGlobal.getRoomInfoList[index].profileImage, 120, extendedController),
                                                  )
                                              ),
                                            ),
                                          ),
                                          FlatButton(
                                            onPressed: (){
                                              _socket.setRoomStatus(ROOM_STATUS_CHAT);
                                              bool isPersonal = _chatGlobal.getRoomInfoList[index].isPersonal;

                                              if(isPersonal){
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => new ChatPage(
                                                          roomName: _chatGlobal.getRoomInfoList[index].roomName,
                                                          chatUser: GlobalProfile.getUserByUserID(_chatGlobal.getRoomInfoList[index].chatUserIDList[0]),))).then((value){
                                                  setState(() {
                                                    _socket.setRoomStatus(ROOM_STATUS_ROOM);
                                                  });
                                                });
                                              }else{
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => new TeamChatPage(
                                                            roomName: _chatGlobal.getRoomInfoList[index].roomName,
                                                            titleName: _chatGlobal.getRoomInfoList[index].name,
                                                            chatUserList: GlobalProfile.getUserListByUserIDList(_chatGlobal.getRoomInfoList[index].chatUserIDList)))).then((value){
                                                  setState(() {
                                                    _socket.setRoomStatus(ROOM_STATUS_ROOM);
                                                  });
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: 180*sizeUnit,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 4*sizeUnit),
                                                  Container(
                                                    height: 22*sizeUnit,
                                                    child: Row(
                                                      children : [
                                                        Text(
                                                          _chatGlobal.getRoomInfoList[index].name,
                                                          style: SheepsTextStyle.h3(context),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        SizedBox(width: 12*sizeUnit),
                                                        _chatGlobal.getRoomInfoList[index].isPersonal == false
                                                          ? SvgPicture.asset(
                                                              teamIconName,
                                                              width: 16*sizeUnit,
                                                              height: 16*sizeUnit,
                                                            )
                                                          : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 8*sizeUnit),
                                                  Text(
                                                    _chatGlobal.getRoomInfoList[index].lastMessage,
                                                    style: SheepsTextStyle.b4(context),
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 60*sizeUnit,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(height: 8*sizeUnit),
                                                  ],
                                                ),
                                                Text(
                                                  _chatGlobal.getRoomInfoList[index].date,
                                                  style: SheepsTextStyle.info2(context),
                                                  overflow: TextOverflow.visible,
                                                ),
                                                SizedBox(height: 12*sizeUnit),
                                                _chatBubble(_chatGlobal.getRoomInfoList[index].messageCount),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            )
                            : Column(
                              children: [
                                SizedBox(height: 100*sizeUnit),
                                SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
                                SizedBox(height: 40*sizeUnit),
                                Center(
                                  child: Text(
                                    '진행중인 채팅이 없습니다.\n프로필에서 채팅을 보내 보세요!',
                                    style: SheepsTextStyle.b2(context),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                        )
                    ),
                  )
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
