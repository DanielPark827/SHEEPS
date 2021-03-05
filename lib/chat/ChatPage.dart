import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/CustomException.dart';
import '../notification/models/LocalNotiProvider.dart';
import '../notification/models/LocalNotification.dart';
import './models/ChatItem.dart';
import './models/ChatRecvMessageModel.dart';
import './models/ChatGlobal.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './models/ChatDatabase.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/Setting/PageReport.dart';


class ChatPage extends StatefulWidget {
  String roomName;
  UserData chatUser;

  ChatPage({Key key, this.roomName, this.chatUser}) : super(key : key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  double sizeUnit = 1;

  LocalNotification _localNotification;
  SocketProvider _socket;
  ChatGlobal _chatGlobal;

  int roomIndex;
  int chatStartIndex;
  ScrollController _chatLVController;
  TextEditingController _chatTfController;

  bool isToggleButton = false;
  GlobalKey<RefreshIndicatorState> refreshKey;

  @override
  void initState() {
    super.initState();

    roomIndex = 0;
    _chatLVController = ScrollController(initialScrollOffset: 0.0);   //flutter 제공
    _chatTfController = TextEditingController();
    chatStartIndex = 0;

    if(widget.chatUser == null)
      throw FetchDataException('Chat User Data is Null');

  }

  @override
  void dispose() {
    _chatLVController.dispose();
    _chatTfController.dispose();
    super.dispose();
  }

  Future<void> _initMessageData() async{
    if(null != _chatGlobal.getRoomInfoList){

      for(int i = 0; i < _chatGlobal.getRoomInfoList.length; ++i){
        if(widget.roomName != _chatGlobal.getRoomInfoList[i].roomName) continue;
        if(null == _chatGlobal.getRoomInfoList[i].chatList) return;

        _chatGlobal.getRoomInfoList[i].messageCount = 0;

        roomIndex = i;
        ChatGlobal.currentRoomIndex = roomIndex;

        bool isReadPoint = false;
        bool isRebuild = false;
        //List<int> dateList = List<int>();

        for(int j = _chatGlobal.getRoomInfoList[i].chatList.length - 1 ; j >= 0; --j){
          if(_chatGlobal.getRoomInfoList[i].chatList[j].message == "여기까지 읽었습니다."){
            _chatGlobal.getRoomInfoList[i].chatList.removeAt(j);
            break;
          }
        }

        await ChatDBHelper().updateRoomData(widget.roomName, 1);

        for(int j = 0 ; j < _chatGlobal.getRoomInfoList[i].chatList.length; ++j){
          ChatRecvMessageModel message = _chatGlobal.getRoomInfoList[i].chatList[j];

          if((_chatGlobal.getRoomInfoList[i].chatList.length - 1) == j) isRebuild = true;

          //안읽은 데이터 체크
          if(message.isRead == 0){
            _chatGlobal.getRoomInfoList[i].chatList[j].isRead = 1;

            if(false == isReadPoint){
              chatStartIndex = j;
              isReadPoint = true;
            }
          }

          if(j != 0) setContinue(message, j-1, isRebuild);
        }

        //읽은 중단 점 표시
        if(isReadPoint){
          ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
              to: CENTER_MESSAGE.toString(),
              from: CENTER_MESSAGE,
              roomName: widget.roomName,
              message: "여기까지 읽었습니다.",
              isImage: 0,
              date: "00:00",
              isRead: 1
          );

          _addRecvMessage(0, chatRecvMessageModel, chatStartIndex, true);
        }
        break;
      }
    }
  }

  _chatList() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          cacheExtent: 30,
          controller: _chatLVController,
          reverse: false,
          shrinkWrap: true,
          padding: EdgeInsets.all(10*sizeUnit),
          itemCount: null == _chatGlobal.getRoomInfoList[roomIndex].chatList ? 0 : _chatGlobal.getRoomInfoList[roomIndex].chatList.length,
          itemBuilder: (context, index) {
            ChatRecvMessageModel chatMessage = _chatGlobal.getRoomInfoList[roomIndex].chatList[index];
            bool isContinue = index == 0 ? false : (_chatGlobal.getRoomInfoList[roomIndex].chatList[index - 1].from == _chatGlobal.getRoomInfoList[roomIndex].chatList[index].from) && (_chatGlobal.getRoomInfoList[roomIndex].chatList[index - 1].date == _chatGlobal.getRoomInfoList[roomIndex].chatList[index].date);
            return Container(
              padding: EdgeInsets.symmetric(vertical: 2*sizeUnit),
              child: ChatItem(
                message: chatMessage,
                isContinue: isContinue,
                isImage: chatMessage.from == CENTER_MESSAGE ? false : chatMessage.isImage.isOdd,
                chatIconName: widget.chatUser.profileUrlList[0],
              ),
            );
          },
        ),
      ),
    );
  }

  _bottomChatArea() {
    return Container(
      color: Colors.white,
      height: 60*sizeUnit,
      child: Row(
        children: [
          SizedBox(width: 8*sizeUnit),
          GestureDetector(
            onTap: () async {
              PickedFile imagePicked = await ImagePicker().getImage(source: ImageSource.gallery); //camera -> gallery
              if (imagePicked == null) return;

              var chatID = await ApiProvider().get('/ChatLog/Count');

              File file = File(imagePicked.path);
              List<int> imageBytes = await file.readAsBytes();

              String base64Image = base64Encode(imageBytes);

              var dateUtc = DateTime.now().toUtc();
              String date = dateUtc.toLocal().hour.toString() + ":" + ((dateUtc.toLocal().minute < 10) ? "0" + dateUtc.toLocal().minute.toString() : dateUtc.toLocal().minute.toString());

              ChatRecvMessageModel chatRecvMessageModel =  ChatRecvMessageModel(
                chatId: chatID['id'] + 1,
                to: widget.chatUser.userID.toString(),
                from: GlobalProfile.loggedInUser.userID,
                fromName: GlobalProfile.loggedInUser.name,
                roomName: widget.roomName,
                message: base64Image,
                date: date,
                isImage: 1,
                updatedAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
                createdAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
              );
              chatRecvMessageModel.isRead = 1;

              _socket..socket.emit("roomChatMessage", [chatRecvMessageModel.toJson()]);

              _addRecvMessage(0, chatRecvMessageModel, _chatGlobal.getRoomInfoList[roomIndex].chatList.length - 1 , true);
              return;
            },
            child: SvgPicture.asset(
              svgSelectPicture,
              width: 28*sizeUnit,
              height: 28*sizeUnit,
            ),
          ),
          SizedBox(width: 4*sizeUnit),
          Container(
              width: 308*sizeUnit,
              height: 32*sizeUnit,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF888888),
                ),
                borderRadius: BorderRadius.circular(8*sizeUnit),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _chatTfController,
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration (
                        hintText: "채팅 내용을 입력해주세요",
                        hintStyle: SheepsTextStyle.hint4Profile(context),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12*sizeUnit, vertical: 6*sizeUnit),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onChanged: (value){
                        setState(() {

                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      _sendButtonTap();
                    },
                    child: Container(
                      margin: EdgeInsets.all(4*sizeUnit),
                      width: 24*sizeUnit,
                      height: 24*sizeUnit,
                      decoration: BoxDecoration(
                        color: _chatTfController.text.length > 0
                            ? Color(0xFF61C680)
                            : Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(6*sizeUnit),
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        size: 16*sizeUnit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    setScreenWidth(context);
    setScreenHeight(context);
    if(null == _localNotification) _localNotification = Provider.of<LocalNotiProvider>(context).localNotification;

    if(null == _chatGlobal)  {
       _chatGlobal = Provider.of(context);
       _initMessageData();
    }

    if(null == _socket) _socket = Provider.of<SocketProvider>(context)
      ..socket.on(SocketProvider.CHAT_RECEIVED_EVENT, (data) {
        ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel.fromJson(data);
        for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
          if( ChatGlobal.roomInfoList[i].roomName == chatRecvMessageModel.roomName){
            bool isRebuild = false;
            if(widget.roomName == chatRecvMessageModel.roomName){
              chatRecvMessageModel.isRead = 1;
              isRebuild = true;
            }else{
              chatRecvMessageModel.isRead = 0;
              isRebuild = false;

              String notiMessage = chatRecvMessageModel.isImage == 1 ? "사진을 보냈습니다." : chatRecvMessageModel.message;

              Future.microtask(() async => await _localNotification.showNoti(title: GlobalProfile.getUserByUserID(chatRecvMessageModel.from).name, des: notiMessage));
            }
            processRecvMessage(chatRecvMessageModel, i, isRebuild);
            break;
          }
        }
      }
      );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: Colors.white,
        child: ConditionalWillPopScope(
          shouldAddCallbacks: true,
          onWillPop: () {
            ChatGlobal.sortRoomInfoList();
            ChatGlobal.currentRoomIndex = -1;
            Navigator.pop(context, 'HotReload');
            return;
          },
          child: SafeArea(
            child: RefreshIndicator(
              backgroundColor: hexToColor("#61C680"),
              color: Colors.white,
              key: refreshKey,
              onRefresh: () async {
                Future.delayed(Duration(seconds: 1), () async {

                  int cnt = 0;

                  List<ChatRecvMessageModel> chatList = (await ChatDBHelper().getRoomData(widget.roomName, offset: _chatGlobal.getRoomInfoList[roomIndex].chatList.length)).cast<ChatRecvMessageModel>();
                  for(int i = 0 ; i < chatList.length; ++i){
                      ChatRecvMessageModel chatRecvMessageModel = chatList[i];
                      chatRecvMessageModel.isContinue = true;

                      if(chatRecvMessageModel.isImage == 1){

                        var getImageData = await ApiProvider().post('/ChatLog/SelectImageData', jsonEncode({
                          "id" : int.parse(chatRecvMessageModel.message)
                        }));

                        if(getImageData != null){
                          chatRecvMessageModel.fileMessage = await base64ToFileURL(getImageData['message']);
                        }
                      }

                      if (cnt != 0) {
                        bool isContinue = (chatRecvMessageModel.from ==_chatGlobal.getRoomInfoList[roomIndex].chatList[cnt - 1].from) &&
                            ( chatRecvMessageModel.date == _chatGlobal.getRoomInfoList[roomIndex].chatList[cnt - 1].date);
                        if (true == isContinue) {
                          _chatGlobal.getRoomInfoList[roomIndex].chatList[cnt - 1].isContinue = false;
                        }
                        else {
                          _chatGlobal.getRoomInfoList[roomIndex].chatList[cnt - 1].isContinue = true;
                        }
                      }
                      _chatGlobal.getRoomInfoList[roomIndex].chatList.insert(0 + cnt, chatRecvMessageModel);
                      cnt++;
                  }
                });

                setState(() {});
              },
              child: GestureDetector(
                onTap: (){
                  FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                  if (!currentFocus.hasPrimaryFocus) {
                    if(Platform.isIOS){
                      FocusManager.instance.primaryFocus.unfocus();
                    } else{
                      currentFocus.unfocus();
                    }
                  }
                },
                child: Scaffold(
                    appBar: SheepsAppBar(context, widget.chatUser.name,
                      backFunc: (){
                        ChatGlobal.sortRoomInfoList();
                        ChatGlobal.currentRoomIndex = -1;
                        Navigator.pop(context, 'HotReload');
                      },
                      actions: [
                        GestureDetector(
                          onTap: () {
                            _settingModalBottomSheet(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 12*sizeUnit),
                            child: SvgPicture.asset(
                              'assets/images/Community/Grey3dot.svg',
                              width: 28*sizeUnit,
                              height: 28*sizeUnit,
                            ),
                          ),
                        ),
                      ],
                    ),
                    body: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(width: 360*sizeUnit,height: 1, decoration: BoxDecoration( color: hexToColor('#eeeeee'))),
                            _chatList(),
                            Container(width: 360*sizeUnit,height: 1, decoration: BoxDecoration( color: hexToColor('#eeeeee'))),
                            _bottomChatArea(),
                          ],
                        )
                    )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _sendButtonTap() async {
    if (_chatTfController.text.isEmpty) {
      return;
    }

    var dateUtc = DateTime.now().toUtc();
    String date = dateUtc.toLocal().hour.toString() + ":" + ((dateUtc.toLocal().minute < 10) ? "0" + dateUtc.toLocal().minute.toString() : dateUtc.toLocal().minute.toString());

    ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel(
        to: widget.chatUser.userID.toString(),
        from: GlobalProfile.loggedInUser.userID,
        fromName : GlobalProfile.loggedInUser.name,
        roomName: widget.roomName,
        message: _chatTfController.text,
        isImage: 0,
        date: date,
        updatedAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
        createdAt: replacLocalUTCDate(DateTime.now().toUtc().toString()),
    );

    chatRecvMessageModel.isRead = 1;

    _socket..socket.emit("roomChatMessage", [chatRecvMessageModel.toJson()]);

    _addRecvMessage(0, chatRecvMessageModel, _chatGlobal.getRoomInfoList[roomIndex].chatList.length - 1 , true);
    _clearMessage();
  }

  _clearMessage() {
    _chatTfController.text = '';
  }

  _isFromMe(UserData fromUser) {
    return fromUser.userID == GlobalProfile.loggedInUser.userID;
  }

  processRecvMessage(ChatRecvMessageModel chatRecvMessageModel, int index, isRebuild) async {
    if(false == isRebuild){
      await _chatGlobal.addChatRecvMessage(chatRecvMessageModel, index, doSort: false);
      return;
    }

    _addRecvMessage(0, chatRecvMessageModel, _chatGlobal.getRoomInfoList[roomIndex].chatList.length - 1, isRebuild);
  }

  _addRecvMessage(id, ChatRecvMessageModel chatRecvMessageModel,int prevIndex , isRebuild) async{

    if(!kReleaseMode) print('Adding Message to UI ${chatRecvMessageModel.message}');

    chatRecvMessageModel.isContinue = chatRecvMessageModel.from == CENTER_MESSAGE ? false : true;

    if(chatRecvMessageModel.from == CENTER_MESSAGE){
      _chatGlobal.getRoomInfoList[roomIndex].chatList.insert(prevIndex, chatRecvMessageModel);
    }else{
      await _chatGlobal.addChatRecvMessage(chatRecvMessageModel, roomIndex, doSort: false);
    }

    setContinue(chatRecvMessageModel, prevIndex, isRebuild);
  }

  void setContinue(ChatRecvMessageModel chatRecvMessageModel, int prevIndex, bool isRebuild){

    _chatGlobal.setContinue(chatRecvMessageModel, prevIndex, roomIndex);

    if(this.mounted && isRebuild){
      setState(() {

      });
    }

    if(isRebuild)
      _chatListScrollToBottom();
  }

  /// Scroll the Chat List when it goes to bottom
  _chatListScrollToBottom() {
    Timer(Duration(milliseconds: 100), () {
      if (_chatLVController.hasClients) {
        _chatLVController.animateTo(
          _chatLVController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.decelerate,
        );

      }
    });
  }


  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
            )
        ),
        context: context,
        builder: (BuildContext bc) {
          return SizedBox(
            height: 92 * sizeUnit,
            child: Column(
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8*sizeUnit),
                    child: Container(
                      width: 20 * sizeUnit,
                      height: 4 * sizeUnit,
                      decoration: BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(2 * sizeUnit),
                      ),
                    ),
                  ),
                ],
              ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        // 기본 파라미터, SecondRoute로 전달
                        MaterialPageRoute(
                            builder: (context) => PageReport(
                              userID: GlobalProfile.loggedInUser.userID,
                              classification: 'ChatRoom',
                              reportedID: widget.roomName,
                            )
                        )
                    );
                  },
                  child: Container(
                    height: 48 * sizeUnit,
                    width: 360 * sizeUnit,
                    child: Center(
                      child: Text(
                        '신고하기',
                        style: SheepsTextStyle.b1(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}


