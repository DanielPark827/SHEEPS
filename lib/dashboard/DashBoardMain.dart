import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Setting/model/Banner.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyHomePage.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/FirebaseNotification.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/TotalNotificationPage.dart';
import 'package:sheeps_app/notification/models/NotificationModel.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import '../notification/models/LocalNotiProvider.dart';
import '../notification/models/LocalNotification.dart';
import 'package:sheeps_app/Community/CommunityListItem.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/profile/MyDetailProfile.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';

class DashBoardMain extends StatefulWidget {
  @override
  _DashBoardMainState createState() => _DashBoardMainState();
}

class _DashBoardMainState extends State<DashBoardMain> with SingleTickerProviderStateMixin{

  ScrollController _scrollController;
  NavigationNum navigationNum;

  PageController _PageController = PageController(
    initialPage: 0,
    viewportFraction: 0.9,
  );
  int currentPage = 0;
  Timer timer;

  bool showNotificationBadge = false;
  AnimationController extendedController;

  int MAX_PERSONAL_PROFILE_VIEW = 10;
  int MAX_TEAM_PROFILE_VIEW = 10;

  List<bool> personalVisibleList;
  List<bool> teamVisibleList;

  LocalNotification _localNotification;
  SocketProvider _socket;
  ChatGlobal _chatGlobal;

  List<bool> popularPersonalVisibleList = [];
  List<bool> popularCommunityByJobVisibleList = [] ;

  double sizeUnit = 1;
  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  int prevPage = -1;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (currentPage != globalClientBannerList.length-1) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      _PageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    });

    _scrollController = ScrollController(initialScrollOffset: 0.0);

    setState(() {
      Future.microtask(() async {
        await permissionRequest();
        AllNotification = await getNotiByStatus();
      });
    });

    personalVisibleList = List<bool>.filled(MAX_PERSONAL_PROFILE_VIEW, false, growable: true);
    teamVisibleList = List<bool>.filled(MAX_PERSONAL_PROFILE_VIEW, false, growable: true);
    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        lowerBound: 0.0,
        upperBound: 1.0);


  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    new FirebaseNotifications().setUpFirebase(context);
  }

  @override
  void dispose() {
    _PageController.dispose();
    _scrollController.dispose();
    extendedController.dispose();
    timer.cancel();
    super.dispose();
  }

  final String svgBellButton ='assets/images/DashBoard/BellButton.svg';

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    var tmp = false;
    if(GlobalProfile.popularCommunityList != null){
      for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
        popularPersonalVisibleList.add(tmp);
      }
    }

    if(GlobalProfile.popularCommunityListByJob != null){
      for (int i = 0; i < GlobalProfile.popularCommunityListByJob.length; i++) {
        popularCommunityByJobVisibleList.add(tmp);
      }
    }

    if(navigationNum == null){
      navigationNum = Provider.of<NavigationNum>(context);
      prevPage = navigationNum.getPastNum();
    }

    if(navigationNum.getNum() == navigationNum.getPastNum()){
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        navigationNum.setNormalPastNum(prevPage);
      }
    }

    _chatGlobal = Provider.of<ChatGlobal>(context);

    UserData user = GlobalProfile.loggedInUser;
    ProfileState profileState = Provider.of<ProfileState>(context);

    if(null == _localNotification) _localNotification = Provider.of<LocalNotiProvider>(context).localNotification;

    if(null == _socket) _socket = Provider.of<SocketProvider>(context)
      ..socket.on(SocketProvider.ETC_RECEIVED_EVENT, (data) {
        //if(!mounted) return;
        ChatRecvMessageModel chatRecvMessageModel = ChatRecvMessageModel.fromJson(data);

        for(int i = 0 ; i < ChatGlobal.roomInfoList.length; ++i){
          if( ChatGlobal.roomInfoList[i].roomName == chatRecvMessageModel.roomName){
            chatRecvMessageModel.isRead = 0;
            _chatGlobal.addChatRecvMessage(chatRecvMessageModel, i);
            break;
          }
        }

        String notiMessage = chatRecvMessageModel.isImage == 1 ? "사진을 보냈습니다." : chatRecvMessageModel.message;

        globalNotificationType = "CHATROOM";
        ChatGlobal.socket = _socket;
        Future.microtask(() async => await _localNotification.showNoti(title: GlobalProfile.getUserByUserID(chatRecvMessageModel.from).name, des: notiMessage,payload:  chatRecvMessageModel.roomName));
        return;
      });
    _socket.socket.on(SocketProvider.FORCE_LOGOUT_EVENT, (data) {
      Function func = () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('autoLoginKey',false);
        prefs.setString('autoLoginId', null);
        prefs.setString('autoLoginPw', null);

        navigationNum.setNum(DASHBOARD_MAIN_PAGE);
        Navigator.of(context).pushNamedAndRemoveUntil("/LoginSelectPage", (route) => false);
        return;
      };

      showSheepsDialog(
        context: context,
        title: '로그아웃',
        description: '다른 기기에서 해당 아이디로 접근하여 로그아웃됩니다.\n로그인 페이지로 이동합니다.',
        okFunc: func,
        isCancelButton: false,
        isBarrierDismissible: false,
      );
      return;
    });

    showNotificationBadge = isHaveReadNoti();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Scaffold(
          body: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Column(
              children: [
                Container(
                  width: 360*sizeUnit,
                  height: 60*sizeUnit,
                  child: Row(
                    children: [
                      SizedBox(width: 12*sizeUnit),
                      SvgPicture.asset(
                        svgSheepsGreenWriteLogo,
                        width: 75*sizeUnit,
                        height: 14*sizeUnit,
                      ),
                      Spacer(),
                      InkWell(
                        onTap:() async {

                          for(int i = 0 ; i < notiList.length; ++i){

                            if(notiList[i].isLoad == true) continue;

                            NotificationModel notificationModel = notiList[i];

                            if(isPersonalNotification(notificationModel.type)){
                              await GlobalProfile.getFutureUserByUserID(notificationModel.from);
                            }else{
                              if(notificationModel.teamRoomName != null && notificationModel.teamRoomName != 'null'){
                                await GlobalProfile.getFutureTeamByRoomName(notificationModel.teamRoomName);
                              }
                              else{
                                await GlobalProfile.getFutureTeamByID(notificationModel.from);
                              }
                            }

                            if(notificationModel.type == NOTI_EVENT_POST_LIKE || notificationModel.type == NOTI_EVENT_POST_REPLY || notificationModel.type == NOTI_EVENT_POST_REPLY_LIKE ||
                                notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY || notificationModel.type == NOTI_EVENT_POST_REPLY_REPLY_LIKE){
                              if(notificationModel.teamRoomName == null || notificationModel.teamRoomName == 'null'){
                                var res = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({
                                  "id" : notificationModel.index
                                }));

                                Community community = Community.fromJson(res);

                                if(community.category == "비밀"){
                                  notificationModel.teamRoomName = "비밀";
                                }
                              }
                            }

                            notificationModel.isLoad = true;
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TotalNotificationPage(),
                          ));
                        },
                        child: Badge(
                          showBadge: showNotificationBadge,
                          position: BadgePosition.bottomEnd(bottom: -8*sizeUnit, end: 1*sizeUnit),
                          badgeColor: hexToColor("#F9423A"),
                          badgeContent: Text(''),
                          child: SvgPicture.asset(
                            svgBellButton,
                            width: 28*sizeUnit,
                            height: 28*sizeUnit,
                          ),
                        ),
                      ),
                      SizedBox(width: 8*sizeUnit),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyPage(),
                          )).then((value) {
                            setState(() {

                            });
                          });
                        },
                        child: SvgPicture.asset(
                          svgMyPageButton,
                          width: 28*sizeUnit,
                          height: 28*sizeUnit,
                        ),
                      ),
                      SizedBox(
                        width: 12*sizeUnit,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(height: 20*sizeUnit),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12*sizeUnit),
                          child: Text(
                            '반가워요 ${user.name} 님',
                            style: SheepsTextStyle.h2(context),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 12*sizeUnit, top: 8*sizeUnit),
                          child: Text(
                            '쉽지않은, ${ DateFormat('M월 dd일 ').format(DateTime.now())}${GetWeekDay(DateFormat('EEEE').format(DateTime.now()))}입니다.',
                            style: SheepsTextStyle.b4(context),
                          ),
                        ),
                        SizedBox(height: 20*sizeUnit),
                        SizedBox(
                          height: 200*sizeUnit,
                          child: PageView.builder(
                            pageSnapping: true,
                            controller: _PageController,
                            onPageChanged: (selectedPage) {
                              setState(() {
                                currentPage = selectedPage;
                              });
                            },
                            itemCount: globalClientBannerList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) {
                                        return Scaffold(
                                          // Add 6 lines from here...
                                          body: MyHomePage(url: globalClientBannerList[index].webURL),
                                        ); // ... to here.
                                      },
                                    ),
                                  );

                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 4*sizeUnit),
                                  child: Card(
                                    elevation: 0,
                                    child: Container(
                                        width: 320*sizeUnit,
                                        decoration: new BoxDecoration(
                                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                                          boxShadow: [
                                            new BoxShadow(
                                              color: Color.fromRGBO(166, 125, 130, 0.2),
                                              blurRadius: 4,
                                            ),],
                                        ),
                                        child:
                                        SvgPicture.asset(
                                          globalClientBannerList[index].imgURL,
                                          width: 320*sizeUnit,
                                          height: 200*sizeUnit,
                                        ),
                                        // child: FittedBox(
                                        //   child: getExtendedImage(globalClientBannerList[index].imgURL, 0, extendedController),
                                        // )
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12*sizeUnit, top: 40*sizeUnit, right: 12*sizeUnit),
                          child: Container(
                            height: 22*sizeUnit,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 22*sizeUnit,
                                    child: Text(
                                      '새로운 개인 프로필',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    profileState.setNum(0);
                                    navigationNum.setNum(PROFILE_PAGE);
                                  },
                                  child: Container(
                                    height: 22*sizeUnit,
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        '더보기 >',
                                        style: SheepsTextStyle.s1(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12*sizeUnit),
                        Padding(
                          padding: EdgeInsets.only(left: 12*sizeUnit),
                          child: Container(
                            height: 200*sizeUnit,
                            child: ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: GlobalProfile.personalSampleProfile.length > MAX_PERSONAL_PROFILE_VIEW ? MAX_PERSONAL_PROFILE_VIEW : GlobalProfile.personalSampleProfile.length ,
                              itemBuilder: (BuildContext context, int index) => GestureDetector(
                                onTap: (){
                                  if(GlobalProfile.personalSampleProfile[index].userID == GlobalProfile.loggedInUser.userID){
                                    Navigator.push(
                                        context, // 기본 파라미터, SecondRoute로 전달
                                        MaterialPageRoute(
                                            builder: (context) => MyDetailProfile(index: 0)));
                                  }else{
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => new DetailProfile(
                                                index: 0,
                                                user: GlobalProfile.getUserByUserID(GlobalProfile.personalSampleProfile[index].userID)
                                            )));
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8*sizeUnit),
                                  child: Column(
                                    children: [
                                      GlobalProfile.personalSampleProfile[index].profileURL == 'BasicImage'
                                        ? Container(
                                        width: 132*sizeUnit,
                                        height: 132*sizeUnit,
                                        decoration: BoxDecoration(
                                          color: hexToColor('#F8F8F8'),
                                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                                          boxShadow: [
                                            new BoxShadow(
                                              color: Color.fromRGBO(116,125,130,0.1),
                                              blurRadius: 3*sizeUnit,
                                              offset: Offset(1*sizeUnit,1*sizeUnit),
                                            ),
                                          ],
                                        ),
                                        child:  Center(
                                            child: SvgPicture.asset(svgPersonalProfileBasicImage,
                                              width: 87*sizeUnit,
                                              height: 63*sizeUnit,
                                            )
                                        ),
                                      )
                                        : Container(
                                          width: 132*sizeUnit,
                                          height: 132*sizeUnit,
                                          decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.circular(8*sizeUnit),
                                            boxShadow: [
                                              new BoxShadow(
                                                color: Color.fromRGBO(116,125,130,0.1),
                                                blurRadius: 3*sizeUnit,
                                                offset: Offset(1*sizeUnit,1*sizeUnit),
                                              ),
                                            ],
                                          ),
                                          child: FittedBox(
                                            child: getExtendedImage(GlobalProfile.personalSampleProfile[index].profileURL, 120, extendedController),
                                            fit: BoxFit.cover,
                                          )
                                      ),
                                      SizedBox(height: 8*sizeUnit),
                                      Container(
                                        width: 132*sizeUnit,
                                        height: 16*sizeUnit,
                                        child: Text(
                                          GlobalProfile.personalSampleProfile[index].name,
                                          style: SheepsTextStyle.h4(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 4*sizeUnit),
                                      Container(
                                        width: 132*sizeUnit,
                                        child: Wrap(
                                          runSpacing: 4*sizeUnit,
                                          spacing: 4*sizeUnit,
                                          children: [
                                            GlobalProfile.personalSampleProfile[index].part == "" ? SizedBox.shrink()
                                                : Container(
                                              height: 18*sizeUnit,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      GlobalProfile.personalSampleProfile[index].part,
                                                      style: SheepsTextStyle.cat1(context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: new BorderRadius.circular(4*sizeUnit),
                                                color: hexToColor("#E5E5E5"),
                                              ),
                                            ),
                                            GlobalProfile.personalSampleProfile[index].location == "" ? SizedBox.shrink()
                                                : Container(
                                              height: 18*sizeUnit,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      GlobalProfile.personalSampleProfile[index].location,
                                                      style: SheepsTextStyle.cat1(context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: new BorderRadius.circular(4*sizeUnit),
                                                color: hexToColor("#E5E5E5"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12*sizeUnit, right: 12*sizeUnit, top: 24*sizeUnit),
                          child: Container(
                            height: 22*sizeUnit,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 22*sizeUnit,
                                    child: Text(
                                      '새로운 팀 프로필',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    profileState.setNum(1);
                                    navigationNum.setNum(PROFILE_PAGE);
                                  },
                                  child: Container(
                                    height: 22*sizeUnit,
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        '더보기 >',
                                        style: SheepsTextStyle.s1(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12*sizeUnit),
                        Padding(
                          padding: EdgeInsets.only(left: 12*sizeUnit),
                          child: Container(
                            height: 200*sizeUnit,
                            child: ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: GlobalProfile.teamSampleProfile.length > MAX_TEAM_PROFILE_VIEW ? MAX_TEAM_PROFILE_VIEW : GlobalProfile.teamSampleProfile.length,
                              itemBuilder: (BuildContext context, int index) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => new DetailTeamProfile(
                                              index: index,
                                              team: GlobalProfile.getTeamByID(GlobalProfile.teamSampleProfile[index].id))));
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8*sizeUnit),
                                  child: Column(
                                    children: [
                                      GlobalProfile.teamSampleProfile[index].profileURL == 'BasicImage'
                                          ? Container(
                                        width: 132*sizeUnit,
                                        height: 132*sizeUnit,
                                        decoration: BoxDecoration(
                                          color: hexToColor('#F8F8F8'),
                                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                                          boxShadow: [
                                            new BoxShadow(
                                              color: Color.fromRGBO(116,125,130,0.1),
                                              blurRadius: 3*sizeUnit,
                                              offset: Offset(1*sizeUnit,1*sizeUnit),
                                            ),
                                          ],
                                        ),
                                        child:  Center(
                                            child: SvgPicture.asset(svgPersonalProfileBasicImage,
                                              width: 87*sizeUnit,
                                              height: 63*sizeUnit,
                                            )
                                        ),
                                      )
                                          : Container(
                                          width: 132*sizeUnit,
                                          height: 132*sizeUnit,
                                          decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.circular(8*sizeUnit),
                                            boxShadow: [
                                              new BoxShadow(
                                                color: Color.fromRGBO(116,125,130,0.1),
                                                blurRadius: 3*sizeUnit,
                                                offset: Offset(1*sizeUnit,1*sizeUnit),
                                              ),
                                            ],
                                          ),
                                          child: FittedBox(
                                            child: getExtendedImage(GlobalProfile.teamSampleProfile[index].profileURL, 120, extendedController),
                                            fit: BoxFit.cover,
                                          )
                                      ),
                                      SizedBox(height: 8*sizeUnit),
                                      Container(
                                        width: 132*sizeUnit,
                                        height: 16*sizeUnit,
                                        child: Text(
                                          GlobalProfile.teamSampleProfile[index].name,
                                          style: SheepsTextStyle.h4(context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 4*sizeUnit),
                                      Container(
                                        width: 132*sizeUnit,
                                        child: Wrap(
                                          runSpacing: 4*sizeUnit,
                                          spacing: 4*sizeUnit,
                                          children: [
                                            GlobalProfile.teamSampleProfile[index].part == "" ? SizedBox.shrink()
                                                : Container(
                                              height: 18*sizeUnit,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      GlobalProfile.teamSampleProfile[index].part,
                                                      style: SheepsTextStyle.cat1(context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: new BorderRadius.circular(4*sizeUnit),
                                                color: hexToColor("#E5E5E5"),
                                              ),
                                            ),
                                            GlobalProfile.teamSampleProfile[index].location == "" ? SizedBox.shrink()
                                                : Container(
                                              height: 18*sizeUnit,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      GlobalProfile.teamSampleProfile[index].location,
                                                      style: SheepsTextStyle.cat1(context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: new BorderRadius.circular(4*sizeUnit),
                                                color: hexToColor("#E5E5E5"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12*sizeUnit, right: 12*sizeUnit, top: 24*sizeUnit, bottom: 8*sizeUnit),
                          child: Container(
                            height: 22*sizeUnit,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 22*sizeUnit,
                                    child: Text(
                                      '커뮤니티 인기 게시글',
                                      style: SheepsTextStyle.h3(context),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    navigationNum.setNum( COMMUNITY_MAIN_PAGE);
                                  },
                                  child: Container(
                                    height: 22*sizeUnit,
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        '더보기 >',
                                        style: SheepsTextStyle.s1(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                            padding: EdgeInsets.all(0),
                            controller: _scrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: GlobalProfile.popularCommunityList.length ,
                            itemBuilder: (BuildContext context, int index) {
                              return SheepsCommunityItem(
                                context: context,
                                community: GlobalProfile.popularCommunityList[index],
                                index: index,
                                extendedController: extendedController,
                                isMorePhoto: popularPersonalVisibleList [index],
                                tapPhotoFunc: () {
                                  setState(() {
                                    if ( popularPersonalVisibleList[
                                    index] ==
                                        false) {
                                      popularPersonalVisibleList[
                                      index] = true;
                                    } else {
                                      popularPersonalVisibleList[
                                      index] = false;
                                    }
                                  });
                                },
                                isLike: popularCommunityInsertCheck(GlobalProfile.loggedInUser.userID,index),
                                tapLikeFunc: () async {
                                  if(isCanTapLike){
                                    isCanTapLike = false;
                                    if (popularCommunityInsertCheck( GlobalProfile .loggedInUser.userID, index) == false) {
                                      var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode(
                                          {
                                            "userID": GlobalProfile.loggedInUser.userID,
                                            // "userID": GlobalProfile .loggedInUser .userID,
                                            "postID":  GlobalProfile.popularCommunityList[index].id
                                          }
                                      ));

                                      CommunityLike user = InsertLike.fromJson(result).item;
                                      GlobalProfile.popularCommunityList[index].communityLike.add(user);
                                    }
                                    else {
                                      await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode(
                                          {
                                            "userID": GlobalProfile.loggedInUser.userID,
                                            "postID":  GlobalProfile.popularCommunityList[index].id
                                          }
                                      ));

                                      int idx;

                                      for (int i = 0; i <  GlobalProfile.popularCommunityList[index].communityLike.length; i++) {
                                        if ( GlobalProfile.popularCommunityList[index].communityLike[i].userID ==
                                            GlobalProfile.loggedInUser.userID)
                                        {
                                          idx = i;
                                          break;
                                        }
                                      }

                                      GlobalProfile.popularCommunityList[index].communityLike.removeAt(idx);
                                    }
                                    setState((){
                                      Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                        isCanTapLike = true;
                                      });
                                    });
                                  }
                                },
                              );
                            }),
                        ListView.builder(
                            padding: EdgeInsets.all(0),
                            controller: _scrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: GlobalProfile.popularCommunityListByJob.length ,
                            itemBuilder: (BuildContext context, int index) {
                              return SheepsCommunityItem(
                                context: context,
                                community: GlobalProfile.popularCommunityListByJob[index],
                                index: index,
                                extendedController: extendedController,
                                isMorePhoto: popularCommunityByJobVisibleList [index],
                                tapPhotoFunc: () {
                                  setState(() {
                                    if (popularCommunityByJobVisibleList[
                                    index] ==
                                        false) {
                                      popularCommunityByJobVisibleList[
                                      index] = true;
                                    } else {
                                      popularCommunityByJobVisibleList[
                                      index] = false;
                                    }
                                  });
                                },
                                isLike: popularCommunityInsertCheck(GlobalProfile.loggedInUser.userID,index),
                                tapLikeFunc: () async {
                                  if(isCanTapLike){
                                    isCanTapLike = false;
                                    if (popularCommunityInsertCheck( GlobalProfile .loggedInUser.userID, index) == false) {
                                      var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode(
                                          {
                                            "userID": GlobalProfile.loggedInUser.userID,
                                            // "userID": GlobalProfile .loggedInUser .userID,
                                            "postID":  GlobalProfile.popularCommunityListByJob[index].id
                                          }
                                      ));

                                      CommunityLike user = InsertLike.fromJson(result).item;
                                      GlobalProfile.popularCommunityListByJob[index].communityLike.add(user);
                                    }
                                    else {
                                      await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode(
                                          {
                                            "userID": GlobalProfile.loggedInUser.userID,
                                            "postID":  GlobalProfile.popularCommunityListByJob[index].id
                                          }
                                      ));

                                      int idx;

                                      for (int i = 0; i <  GlobalProfile.popularCommunityListByJob[index].communityLike.length; i++) {
                                        if ( GlobalProfile.popularCommunityListByJob[index].communityLike[i].userID ==
                                            GlobalProfile.loggedInUser.userID)
                                        {
                                          idx = i;
                                          break;
                                        }
                                      }

                                      GlobalProfile.popularCommunityListByJob[index].communityLike.removeAt(idx);
                                    }
                                    setState((){
                                      Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                        isCanTapLike = true;
                                      });
                                    });
                                  }
                                },
                              );
                            }),
                        SizedBox(height: 60*sizeUnit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
