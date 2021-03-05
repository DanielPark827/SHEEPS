import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import 'package:sheeps_app/config/GlobalAbStractClass.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';

class SocketProvider with ChangeNotifier, StoppableService{

  @override
  void start() {
    super.start();
    if(stopCheck){
      socket.emit('resumed',[{
        "userID" : GlobalProfile.loggedInUser.userID.toString(),
        "roomStatus" : roomStatus,
      }] );
      stopCheck = false;
    }
  }

  @override
  void stop() {
    super.stop();
    if(this._fromUser != null){
      stopCheck = true;
      socket.emit('paused',[{
        "userID" : GlobalProfile.loggedInUser.userID.toString(),
        "roomStatus" : roomStatus,
      }] );
    }
  }

  SocketIO socket;
  SocketIOManager _manager;

  UserData _fromUser;

  int roomStatus;
  int prevRoomStatus;
  int get getRoomStatus => roomStatus;

  bool stopCheck = false;


  static String _providerserverIP = 'http://121.172.129.206';
  static int PROVIDER_SERVER_PORT = 50007;
  static String _connectUrl = '$_providerserverIP:$PROVIDER_SERVER_PORT';   //server와 연결

  static String ROOM_RECEIVED_EVENT = "room_list_receive_message";
  static String CHAT_RECEIVED_EVENT = "receive_message";
  static String ETC_RECEIVED_EVENT = "etc_receive_message";
  static String FORCE_LOGOUT_EVENT = "force_logout";

  initSocket(UserData fromUser) async {
    //async, await : 게으른 연산, 일단 함수가 실행되면 await로가서 처리를하고,
    // 데이터가 들어올때까지 기다리다가, 들어오면 또 처리, stream이 끝나거나 닫힐때 까지 반복

    debugPrint('Connecting user: ${fromUser.name}');
    this._fromUser = fromUser;
    await _init();

    notifyListeners();
  }

  _init() async {
    _manager = SocketIOManager();  //dart 제공
    socket = await _manager.createInstance(_socketOptions());
    socket.connect();
    roomStatus = 2;
    prevRoomStatus = roomStatus;
  }

  _socketOptions() {
    final Map<String, String> userMap = {
      'from': _fromUser.userID.toString(),
    };

    return SocketOptions(
      ApiProvider().getChatUrl,
      enableLogging: true,
      transports: [Transports.WEB_SOCKET],
      query: userMap,
    );
  }

  disconnect() async {
    socket.disconnect();
  }

  setRoomStatus(int status){
    prevRoomStatus = roomStatus;
    roomStatus = status;

    socket.emit('room_status_online', [{
      'userID' : this._fromUser.userID,
      'value' : status,
    }]);
  }

  setPrevStatus(){
    roomStatus = prevRoomStatus;
    socket.emit('room_status_online', [{
      'userID' : this._fromUser.userID,
      'value' : roomStatus,
    }]);
  }

  SocketProvider(){

  }
}