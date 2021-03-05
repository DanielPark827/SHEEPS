import 'dart:convert';
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Community/CommunityMain.dart';
import 'package:sheeps_app/Community/models/DummyForCommunityWrite.dart';
import 'package:sheeps_app/Setting/model/DummyForModifyMemberInformation.dart';
import 'package:sheeps_app/TeamProfileModifys/TeamProfileModify.dart';
import 'package:sheeps_app/TeamProfileModifys/model/DummyForTeamProfileModify.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/chat/ChatRoomPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAbStractClass.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/DashBoardMain.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/login/LoginCheckPage.dart';
import 'package:sheeps_app/login/PasswordChangePage.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/TotalNotificationPage.dart';
import 'package:sheeps_app/notification/models/NotiDatabase.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/onboarding/components/SplashScreen.dart';
import 'package:sheeps_app/profile/models/FilterState.dart';
import 'package:sheeps_app/profile/models/ImgProviderForAddTeam.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/profile/modelsForPersonalImageList/MultipartImgFilesProvider.dart';
import 'package:sheeps_app/profileModify/AddCareer.dart';
import 'package:sheeps_app/registration/CertificationSuccessPage.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import './notification/models/LocalNotiProvider.dart';
import 'package:sheeps_app/profile/ProfilePage.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/profileModify/MyProfileModify.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';
import 'package:sheeps_app/registration/bloc/UserRepository.dart';
import 'package:sheeps_app/TeamProfileModifys/model/ImgProviderForTeamProfileModify.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'config/SheepsTextStyle.dart';
import 'network/ApiProvider.dart';
import 'package:fluttertoast/fluttertoast.dart';


double sizeUnit = 1;

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  LifeCycleManager({Key key, this.child}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver {

  SocketProvider socket;
  ChatGlobal _chatGlobal;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('state = $state');

    List<StoppableService> services = [
      socket,
    ];

    services.forEach((service) {
      if(state == AppLifecycleState.resumed){

        if(GlobalProfile.loggedInUser != null ) {
          if(int.parse(GlobalProfile.accessTokenExpiredAt) > int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(0,10))){
            Future.microtask(() async {
              var res = await ApiProvider().post('/Profile/Personal/Login/Token', jsonEncode({
                "userID" : GlobalProfile.loggedInUser.userID,
                "refreshToken" : GlobalProfile.refreshToken
              }));

              if(res != null){
                GlobalProfile.accessToken = res['AccessToken'] as String;
                GlobalProfile.accessTokenExpiredAt = (res['AccessTokenExpiredAt'] as int).toString();
              }
            });
          }

          //알림 가져오기
          Future.microtask(() async {
            var notiListGet = await ApiProvider().post('/Notification/UnSendSelect', jsonEncode(
                {
                  "userID" : GlobalProfile.loggedInUser.userID,
                }
            ));

            if(null != notiListGet){
              for(int i = 0; i < notiListGet.length; ++i){
                NotificationModel notificationModel = NotificationModel.fromJson(notiListGet[i]);
                notiList.insert(0,notificationModel);
                await NotiDBHelper().createData(notificationModel);

                //알림 이벤트 가져오기 필요함
                if(notificationModel.type == NOTI_EVENT_TEAM_REQUEST_ACCEPT){
                  Team team = await GlobalProfile.getFutureTeamByID(notificationModel.index);

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
            }

            //채팅 가져오기 필요함
            var chatLogList = await ApiProvider().post('/ChatLog/UnSendSelect', jsonEncode(
                {
                  "userID" : GlobalProfile.loggedInUser.userID
                }
            ));

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

                for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
                  if(ChatGlobal.roomInfoList[i].roomName == message.roomName){
                    message.isRead = 0;
                    bool DoSort = true;
                    if(socket.getRoomStatus == ROOM_STATUS_CHAT){
                      DoSort = false;
                      if(ChatGlobal.currentRoomIndex == i){
                        message.isRead = 1;
                      }
                    }
                    message.isContinue = true;
                    await _chatGlobal.addChatRecvMessage(message, i, doSort: DoSort);

                    int prevIndex = ChatGlobal.roomInfoList[i].chatList.length > 2 ? ChatGlobal.roomInfoList[i].chatList.length - 2 : 0;

                    _chatGlobal.setContinue(message, prevIndex, i);
                  }
                }
              }
            }
          });

        }
        service.start();
      }else if(state == AppLifecycleState.paused){
        service.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    if(null == socket) socket = Provider.of<SocketProvider>(context);
    if(null == _chatGlobal) _chatGlobal = Provider.of(context);

    return Container(
      child: widget.child,
    );
  }
}


const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.white,
  systemNavigationBarDividerColor: Colors.white,
  statusBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

void main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: hexToColor('#FFFFFF'),
  ));
  //SystemChrome.setSystemUIOverlayStyle(dark);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   bool inDebug = false;
  //   assert(() { inDebug = true; return true; }());
  //   // In debug mode, use the normal error widget which shows
  //   // the error message:
  //   if (inDebug)
  //     return ErrorWidget(details.exception);
  //   // In release builds, show a yellow-on-blue message instead:
  //   return Container(
  //     alignment: Alignment.center,
  //     child: Text(
  //       'Error! ${details.exception}',
  //       style: TextStyle(color: Colors.yellow),
  //       textDirection: TextDirection.ltr,
  //     ),
  //   );
  // };

  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.75)
    ..userInteractions = true;

}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UserRepository userRepository = UserRepository();

  double sizeUnit;

  @override
  void initState() {
    //기기별 사이즈 기준 측정
    sizeUnit = WidgetsBinding.instance.window.physicalSize.width/WidgetsBinding.instance.window.devicePixelRatio/360;
    debugPrint("size unit is $sizeUnit");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MultipartImgFilesProvider>(
          create: (_) => new MultipartImgFilesProvider(),),
        ChangeNotifierProvider<ModifiedProfile>(
          create: (_) => ModifiedProfile(),
        ),
        /*  ChangeNotifierProvider<CheckForSearch>(
          create: (_) => CheckForSearch(false, null),
        ),*/
        ChangeNotifierProvider<NavigationNum>(
          create: (_) => NavigationNum(),
        ),
        ChangeNotifierProvider<ProfileState>(
          create: (_) => ProfileState(),
        ),
        ChangeNotifierProvider<ModifiedMemberInformation>(
          create: (_) => ModifiedMemberInformation(),
        ),
        ChangeNotifierProvider<ProviderForCommmunityWrite>(
          create: (_) => ProviderForCommmunityWrite(),
        ),
        ChangeNotifierProvider<ModelTeamProfile>(
          create: (_) => ModelTeamProfile(),
        ),
        ChangeNotifierProvider<SocketProvider>(
          create: (_) => new SocketProvider(),
        ),
        ChangeNotifierProvider<ModelAddTeam>(
          create: (_) => new ModelAddTeam(),
        ),
        ChangeNotifierProvider<ImgProviderForAddTeam>(
          create: (_) => new ImgProviderForAddTeam(),
        ),
        Provider<LocalNotiProvider>(create: (_) => LocalNotiProvider(),),
        ChangeNotifierProvider<FilterStateForPersonal>(
          create: (_) =>FilterStateForPersonal(),
        ),
        ChangeNotifierProvider<ImgProviderForTeamProfileModify>(
          create: (_) =>ImgProviderForTeamProfileModify(),
        ),
        ChangeNotifierProvider<ChatGlobal>(
          create: (_) => new ChatGlobal(),
        ),
      ],
      child: LifeCycleManager(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/SplashScreen',
          routes: {
            //'/': (BuildContext context) => DashBoardMain(),
            '/LoginSelectPage': (BuildContext context) => LoginSelectPage(),
            '/MainPage': (BuildContext context) => MainPage(),
            '/MyProfileModify': (BuildContext context) => MyProfileModify(),
            '/AddCareer': (BuildContext context) => AddCareer(),
            '/ProfilePage': (BuildContext context) => ProfilePage(),
            '/CommunutyMain': (BuildContext context) => CommunutyMain(),

            '/SplashScreen': (context) => SplashScreen(),
            '/TeamProfileModify': (context) => TeamProfileModify(),

            '/certification-result': (context) => LoginCheckPage(),
            '/certification-result-PW': (context) => PasswordChangePage(),

            '/MyProfiles': (BuildContext context) => MyPage(),
            '/CertificationSuccessPage': (BuildContext context) => CertificationSuccessPage(),

            //알람 클릭시 사용하려는 코드
            '/ChatRoomPage' : (BuildContext context) => ChatRoomPage(),
            '/NotificationPage' : (BuildContext context) => TotalNotificationPage()
          },
          builder: EasyLoading.init(),
          navigatorKey: navigatorKey,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,//기본 배경색 지정
            bottomAppBarColor: Colors.white,
            backgroundColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            primaryColor: Colors.white,
            textTheme: TextTheme(
                bodyText1: TextStyle(fontSize: sizeUnit)
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder()
              }
            )
          ),
        ),
      ),
    );
  }
}


class MainPage extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static List<Widget> _widgetOptions = <Widget>[
    DashBoardMain(),
    ProfilePage(),
    CommunutyMain(),
    Empty(),


    // //대쉬보드메인 알람4
    // TotalNotificationPage(),
    //
    //
    // //마이페이지5
    // MyPage(),
    // //나의프로필6
    // MyProfiles(),
    // //나의커뮤니티7
    // MyCommunity(),
    //
    // FilterAfterSelect(),
  ];

  final String svgHomeIcon = 'assets/images/NavigationBar/HomeIcon.svg';
  final String svgHomeIconBlack = 'assets/images/NavigationBar/HomeIconBlack.svg';
  final String NewsIcon = 'assets/images/NavigationBar/NewsIcon.svg';
  final String NewsIconBlack = 'assets/images/NavigationBar/NewsIconBlack.svg';
  final String ChatIcon = 'assets/images/NavigationBar/ChatIcon.svg';
  final String ChatIconBlack = 'assets/images/NavigationBar/ChatIconBlack.svg';
  final String PeopleIcon = 'assets/images/NavigationBar/PeopleIcon.svg';


  static DateTime currentBackPressTime;
  _isEnd(){
    DateTime now = DateTime.now();
    if(currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)){
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "뒤로가기를 한 번 더 입력하시면 종료됩니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromRGBO(22, 22, 22, 0.3),
        textColor: Colors.white,
        fontSize: 14,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    final navigationNum = Provider.of<NavigationNum>(context);

    return ConditionalWillPopScope(
      shouldAddCallbacks: true,
      onWillPop: ()async {
        if (navigationNum.getNum() == DASHBOARD_MAIN_PAGE) {
          bool result = _isEnd();
          return await Future.value(result);
        }
        else if (navigationNum.getNum() == PROFILE_PAGE ||
            navigationNum.getNum() == COMMUNITY_MAIN_PAGE) {
          navigationNum.setNum(DASHBOARD_MAIN_PAGE);
          return Future.value(false);
        }
        else {
          navigationNum.setNum(DASHBOARD_MAIN_PAGE);
          return Future.value(false);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              body: _widgetOptions[navigationNum.getNum()],
              bottomNavigationBar: Container(
                height: 56*sizeUnit,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      new BoxShadow(
                        offset: Offset(0,-2.5),
                        color: Color.fromRGBO(116, 125, 130, 0.2),
                        blurRadius: 2,
                      ),
                    ]
                ),
                child: BottomNavigationBar(
                  elevation: 0.0,
                  backgroundColor: hexToColor("#FFFFFF"),
                  showSelectedLabels: false,
                  // <-- HERE
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) {
                    if (index == TEAM_RECRUIT_PAGE) {
                      showSheepsDialog(
                        context: context,
                        title: "준비중입니다!",
                        description: '공모전 / 지원사업등 목적별 팀 모집이\n가능한 기능이 현재 개발 중이에요.\n조금만 기다려주세요!',
                        isCancelButton: false,
                      );
                    } else {
                      navigationNum.setNum(index);
                    }
                  },
                  currentIndex: navigationNum.getNum(),
                  items: [
                    new BottomNavigationBarItem(
                      icon: Column(
                        children: [
                          SvgPicture.asset(
                            svgHomeIcon,
                            width: 20*sizeUnit,
                            height: 20*sizeUnit,
                            color: navigationNum.getNum() == DASHBOARD_MAIN_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 4*sizeUnit),
                          Text('홈',style: SheepsTextStyle.navigationBarTitle(context).copyWith(
                              color: navigationNum.getNum() == DASHBOARD_MAIN_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC)
                          )),
                          SizedBox(height: 4*sizeUnit),
                        ],
                      ),
                      title: Text('홈',style: TextStyle(fontSize: 0)),
                    ),
                    new BottomNavigationBarItem(
                      icon: Column(
                        children: [
                          SvgPicture.asset(
                            NewsIcon,
                            width: 20*sizeUnit,
                            height: 20*sizeUnit,
                            color: navigationNum.getNum() == PROFILE_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 4*sizeUnit),
                          Text('프로필',style: SheepsTextStyle.navigationBarTitle(context).copyWith(
                              color: navigationNum.getNum() == PROFILE_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC)
                          )),
                          SizedBox(height: 4*sizeUnit),
                        ],
                      ),
                      title: Text('프로필',style: TextStyle(fontSize: 0)),
                    ),
                    new BottomNavigationBarItem(
                      icon: Column(
                        children: [
                          SvgPicture.asset(
                            ChatIcon,
                            width: 20*sizeUnit,
                            height: 20*sizeUnit,
                            color: navigationNum.getNum() == COMMUNITY_MAIN_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 4*sizeUnit),
                          Text('커뮤니티',style: SheepsTextStyle.navigationBarTitle(context).copyWith(
                              color: navigationNum.getNum() == COMMUNITY_MAIN_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC)
                          )),
                          SizedBox(height: 4*sizeUnit),
                        ],
                      ),
                      title: Text('커뮤니티',style: TextStyle(fontSize: 0)),
                    ),
                    BottomNavigationBarItem(
                      icon: Column(
                        children: [
                          Icon(Icons.chat_outlined, size: 20*sizeUnit, color: navigationNum.getNum() == CHATROOM_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC),),
                          SizedBox(height: 4*sizeUnit),
                          Text('채팅',style: SheepsTextStyle.navigationBarTitle(context).copyWith(
                              color: navigationNum.getNum() == CHATROOM_PAGE ? Color(0xFF222222) : Color(0xFFCCCCCC)
                          )),
                          SizedBox(height: 4*sizeUnit),
                        ],
                      ),
                      title: Text('채팅',style: TextStyle(fontSize: 0)),
                    ),
                    new BottomNavigationBarItem(
                      icon: Column(
                        children: [
                          SvgPicture.asset(
                            PeopleIcon,
                            width: 20*sizeUnit,
                            height: 20*sizeUnit,
                            color: Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 4*sizeUnit),
                          Text('팀 모집',style: SheepsTextStyle.navigationBarTitle(context).copyWith(color: Color(0xFFCCCCCC))),
                          SizedBox(height: 4*sizeUnit),
                        ],
                      ),
                      title: Text('팀 모집',style: TextStyle(fontSize: 0)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class dialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Empty extends StatefulWidget {
  @override
  _EmptyState createState() => _EmptyState();
}

class _EmptyState extends State<Empty> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}