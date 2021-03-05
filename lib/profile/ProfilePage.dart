import 'dart:convert';
import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/profile/models/FilterState.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

//https://www.youtube.com/watch?v=gZDrGdR39JM
//https://github.com/TechieBlossom/flutter-samples/blob/master/custom_dropdown.dart
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  double sizeUnit = 1;
  int duration = 300;
  bool filterActive = false;
  TextEditingController _controller = new TextEditingController();
  AnimationController extendedController;
  ScrollController scrollController;
  NavigationNum navigationNum;

  GlobalKey<RefreshIndicatorState> refreshKey;

  GlobalKey actionKey;

  ProfileState profileState;
  int prevPage = -1;

  final svgGreyFilterIcon = 'assets/images/Profile/GreyFilterIcon.svg';
  final svgGreyMyPageButton = 'assets/images/Public/GreyMyPageButton.svg';
  final svgBlackFilterIcon = 'assets/images/Profile/BlackFilterIcon.svg';

  @override
  void initState() {
    super.initState();

    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        lowerBound: 0.0,
        upperBound: 1.0);

    refreshKey = GlobalKey<RefreshIndicatorState>();

    scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    extendedController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });


  }

  _getMoreData() async {
    List<dynamic> list = new List<dynamic>();

    //개인프로필상태
    if(profileState.getNum() == 0){
      list = await ApiProvider().post(
          '/Profile/Personal/UserListOffset',
          jsonEncode({
            'userID' : GlobalProfile.loggedInUser.userID,
            "index": GlobalProfile.personalProfile.length,
          }));

      if(null == list || 0 == list.length) return;

      for (int i = 0; i < list.length; i++) {
        GlobalProfile.personalProfile.add(UserData.fromJson(list[i]));
      }
    }else{
      list = await ApiProvider().post(
          '/Team/Profile/SelectOffset',
          jsonEncode({
            "index": GlobalProfile.teamProfile.length,
          }));

      if(null == list || 0 == list.length) return;

      for (int i = 0; i < list.length; i++) {
        GlobalProfile.teamProfile.add(Team.fromJson(list[i]));
      }
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    if(navigationNum == null) {
      navigationNum = Provider.of<NavigationNum>(context);
      prevPage = navigationNum.getPastNum();
    }

    if(navigationNum.getNum() == navigationNum.getPastNum()){
      if (scrollController.hasClients) {
        scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        navigationNum.setNormalPastNum(prevPage);
      }
    }

    if(profileState == null) profileState = Provider.of<ProfileState>(context);

    FilterStateForPersonal _FilterStateForPersonal = Provider.of<FilterStateForPersonal>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                if (!currentFocus.hasPrimaryFocus) {
                  if (Platform.isIOS) {
                    FocusManager.instance.primaryFocus.unfocus();
                  } else {
                    currentFocus.unfocus();
                  }
                }
              },
              child: new Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    profilePageTopBar(context, profileState, navigationNum),
                    AnimatedContainer(
                      margin: EdgeInsets.only(bottom: 4*sizeUnit),
                      height: filterActive && profileState.getNum() == 0 ? 412*sizeUnit : 0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8*sizeUnit),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(116, 125, 130, 0.1),
                            offset: Offset(0, 2*sizeUnit), //(x,y)
                            blurRadius: 1*sizeUnit,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: ListView(
                        children: [
                          SizedBox(height: 12*sizeUnit),
                          Material(
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8*sizeUnit),
                                      color: Color(0xffEEEEEE)),
                                  width: 336*sizeUnit,
                                  height: 40*sizeUnit,
                                  child: Center(
                                    child: Row(
                                      children: [
                                        SizedBox(width: 4*sizeUnit),
                                        Stack(
                                          children: [
                                            AnimatedContainer(
                                              alignment: _FilterStateForPersonal.tabAlignForPerson,
                                              duration: Duration(milliseconds: duration),
                                              curve: Curves.easeInOut,
                                              color: Colors.transparent,
                                              width: 328*sizeUnit,
                                              height:40*sizeUnit,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8*sizeUnit),
                                                    color: Color(0xffffffff)),
                                                width: 108*sizeUnit,
                                                height: 32*sizeUnit,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    _FilterStateForPersonal.tabAlignForPerson = Alignment.centerLeft ;
                                                    setState(() {

                                                    });
                                                  },
                                                  child: Container(
                                                    width: 108*sizeUnit,
                                                    height: 36*sizeUnit,
                                                    child: Center(
                                                      child: Text(
                                                        "최근 접속 순",
                                                        style: SheepsTextStyle.b3(context).copyWith(
                                                            fontWeight: _FilterStateForPersonal.tabAlignForPerson == Alignment.centerLeft?FontWeight.bold:FontWeight.normal
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2*sizeUnit),
                                                InkWell(
                                                  onTap: () {
                                                    _FilterStateForPersonal.tabAlignForPerson = Alignment.center ;
                                                    setState(() {

                                                    });
                                                  },
                                                  child: Container(
                                                    width: 108*sizeUnit,
                                                    height: 36*sizeUnit,
                                                    child: Center(
                                                        child: Text(
                                                          "보유 뱃지 순",
                                                          style: SheepsTextStyle.b3(context).copyWith(
                                                              fontWeight:  _FilterStateForPersonal.tabAlignForPerson == Alignment.center?FontWeight.bold:FontWeight.normal
                                                          ),
                                                        )
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2*sizeUnit),
                                                InkWell(
                                                  onTap: () {
                                                    _FilterStateForPersonal.tabAlignForPerson = Alignment.centerRight;
                                                    setState(() {

                                                    });
                                                  },
                                                  child: Container(
                                                    width: 108*sizeUnit,
                                                    height: 36*sizeUnit,
                                                    child: Center(
                                                        child: Text(
                                                          "신규 가입 순",
                                                          style: SheepsTextStyle.b3(context).copyWith(
                                                            fontWeight: _FilterStateForPersonal.tabAlignForPerson == Alignment.centerRight?FontWeight.bold:FontWeight.normal,
                                                          ),
                                                        )
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 2*sizeUnit),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                          Row(
                            children: [
                              SizedBox(width: 12*sizeUnit),
                              Text(
                                "분야 필터링",
                                style: SheepsTextStyle.h3(context),
                              )
                            ],
                          ),
                          SizedBox(height: 12*sizeUnit),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10*sizeUnit),
                            child: Wrap(
                              runSpacing: 4*sizeUnit,
                              spacing: 4*sizeUnit,
                              children: _FilterStateForPersonal.catNameForPerson.asMap().map(
                                      (index, item) => MapEntry(index,
                                      GestureDetector(
                                          onTap: (){
                                            if( _FilterStateForPersonal.cataForPerson[index] == true){
                                              _FilterStateForPersonal.cataForPerson[index] = false;
                                            }
                                            else{
                                              _FilterStateForPersonal.cataForPerson[index] = true;
                                            }
                                            setState(() {

                                            });
                                          },
                                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.cataForPerson[index])
                                      )
                                  )
                              ).values.toList().cast<Widget>(),
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                          Row(
                            children: [
                              SizedBox(width: 12*sizeUnit),
                              Text(
                                "지역 필터링",
                                style: SheepsTextStyle.h3(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 12*sizeUnit),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10*sizeUnit),
                            child: Wrap(
                              runSpacing: 4*sizeUnit,
                              spacing: 4*sizeUnit,
                              children: _FilterStateForPersonal.locationNameForPerson.asMap().map(
                                      (index, item) => MapEntry(index,
                                      GestureDetector(
                                          onTap: (){
                                            if( _FilterStateForPersonal.locaForPerson[index] == true){
                                              _FilterStateForPersonal.locaForPerson[index] = false;
                                            }
                                            else{
                                              _FilterStateForPersonal.locaForPerson[index] = true;
                                            }
                                            setState(() {

                                            });
                                          },
                                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.locaForPerson[index])
                                      )
                                  )
                              ).values.toList().cast<Widget>(),
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                          GestureDetector(
                            onTap: ()async{

                              List<String> tmp = ["개발","게임","경영/비즈니스","서비스/리테일","금융","디자인","마케팅/광고","물류/무역","미디어","법률 관련","영업","인사/교육","정부/비영리","제조/생산" ];
                              String orderrule = _FilterStateForPersonal.tabAlignForPerson ==  Alignment.centerLeft?"0": _FilterStateForPersonal.tabAlignForPerson ==  Alignment.center? "1":"2";
                              String partcheckall = "1";
                              String partSearch = "";
                              bool firstpart = false;
                              for(int i =0; i<tmp.length;i++){
                                if(_FilterStateForPersonal.cataForPerson[i] == true){
                                  firstpart == false? partSearch += tmp[i] : partSearch = partSearch+"|^"+tmp[i];
                                  firstpart = true;
                                  partcheckall = "0";
                                }
                              }

                              List<String> tmp2 = ["서울","부산","대구","인천","광주","대전","울산","세종","경기","강원","충청북도","충청남도","전라북도","전라남도","경상북도","경상남도","제주"];
                              String locationcheckall = "1";
                              String locationSearch = "";
                              bool firstpart2 = false;
                              for(int i =0; i<tmp2.length;i++){
                                if(_FilterStateForPersonal.locaForPerson[i] == true){
                                  firstpart2 == false? locationSearch += tmp2[i] : locationSearch = locationSearch+"|^"+tmp2[i];
                                  firstpart2 = true;
                                  locationcheckall = "0";
                                }
                              }


                              if(partcheckall == "1" && locationcheckall == "1"){
                                GlobalProfile.personalProfile.clear();

                                var tmp3 = await ApiProvider().post('/Search/ProfileFilter', jsonEncode(
                                    {
                                      "orderrule": orderrule,
                                      "partcheckall" : partcheckall,
                                      "partSearch" : partSearch,
                                      "locationcheckall": locationcheckall,
                                      "locationSearch": locationSearch,
                                      "userID" : GlobalProfile.loggedInUser.userID
                                    }
                                ));
                                if(tmp3 != null) {
                                  for (int i = 0; i < tmp3.length; i++) {
                                    UserData _userTmp = UserData.fromJson(tmp3[i]);
                                    GlobalProfile.personalProfile.add(_userTmp);
                                  }
                                }
                                GlobalProfile.personalFiltered = false;
                              }
                              else{
                                GlobalProfile.personalProfileFiltered.clear();

                                var tmp3 = await ApiProvider().post('/Search/ProfileFilter', jsonEncode(
                                    {
                                      "orderrule": orderrule,
                                      "partcheckall" : partcheckall,
                                      "partSearch" : partSearch,
                                      "locationcheckall": locationcheckall,
                                      "locationSearch": locationSearch,
                                      "userID" : GlobalProfile.loggedInUser.userID
                                    }
                                ));
                                if(tmp3 != null) {
                                  for (int i = 0; i < tmp3.length; i++) {
                                    UserData _userTmp = UserData.fromJson(tmp3[i]);
                                    GlobalProfile.personalProfileFiltered.add(_userTmp);
                                  }
                                }
                                GlobalProfile.personalFiltered = true;
                              }

                              filterActive = false;
                              setState(() {
                              });
                            },
                            child: Center(
                              child: Container(
                                width: 320*sizeUnit,
                                height: 48*sizeUnit,
                                decoration: BoxDecoration(
                                  color: Color(0xff61C680),
                                  // set border width
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(8*sizeUnit)), // set rounded corner radius
                                ),
                                child: Center(
                                  child: Text(
                                    "필터 적용",
                                    style: SheepsTextStyle.button1(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      margin: EdgeInsets.only(bottom: 4*sizeUnit),
                      height: filterActive && profileState.getNum() != 0 ? 518*sizeUnit : 0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8*sizeUnit),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(116, 125, 130, 0.1),
                            offset: Offset(0, 2*sizeUnit), //(x,y)
                            blurRadius: 1*sizeUnit,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: ListView(
                        children: [
                          SizedBox(height: 12*sizeUnit),
                          Material(
                            color: Colors.white,
                            child: Row(
                              children: [
                                Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xffEEEEEE)),
                                  width: 336*sizeUnit,
                                  height: 40*sizeUnit,
                                  child: Center(
                                    child: Row(
                                      children: [
                                        SizedBox(width: 4*sizeUnit),
                                        Stack(
                                          children: [
                                            AnimatedContainer(
                                              alignment: _FilterStateForPersonal.tabAlignForTeam,
                                              duration: Duration(milliseconds: duration),
                                              curve: Curves.easeInOut,
                                              color: Colors.transparent,
                                              width: 328*sizeUnit,
                                              height:40*sizeUnit,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8*sizeUnit),
                                                    color: Color(0xffffffff)),
                                                width: 108*sizeUnit,
                                                height: 32*sizeUnit,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    _FilterStateForPersonal.tabAlignForTeam=Alignment.centerLeft;
                                                    setState(() {

                                                    });
                                                  },
                                                  child: Container(
                                                    width: 108*sizeUnit,
                                                    height: 36*sizeUnit,
                                                    child: Center(
                                                      child: Text(
                                                        "최근 접속 순",
                                                        style: SheepsTextStyle.b3(context).copyWith(
                                                            fontWeight: _FilterStateForPersonal.tabAlignForTeam == Alignment.centerLeft ? FontWeight.bold : FontWeight.normal
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2*sizeUnit),
                                                InkWell(
                                                  onTap: () {
                                                    _FilterStateForPersonal.tabAlignForTeam=Alignment.center;
                                                    setState(() {

                                                    });
                                                  },
                                                  child: Container(
                                                    width: 108*sizeUnit,
                                                    height: 36*sizeUnit,
                                                    child: Center(
                                                        child: Text(
                                                          "보유 뱃지 순",
                                                          style: SheepsTextStyle.b3(context).copyWith(
                                                              fontWeight: _FilterStateForPersonal.tabAlignForTeam == Alignment.center ? FontWeight.bold : FontWeight.normal
                                                          ),
                                                        )
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2*sizeUnit),
                                                InkWell(
                                                  onTap: () {
                                                    _FilterStateForPersonal.tabAlignForTeam=Alignment.centerRight;
                                                    setState(() {

                                                    });
                                                  },
                                                  child: Container(
                                                    width: 108*sizeUnit,
                                                    height: 36*sizeUnit,
                                                    child: Center(
                                                      child: Text(
                                                        "신규 가입 순",
                                                        style: SheepsTextStyle.b3(context).copyWith(
                                                            fontWeight: _FilterStateForPersonal.tabAlignForTeam == Alignment.centerRight ? FontWeight.bold : FontWeight.normal
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 2*sizeUnit),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                          Row(
                            children: [
                              SizedBox(width: 12*sizeUnit),
                              Text(
                                "분야 필터링",
                                style: SheepsTextStyle.h3(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 12*sizeUnit),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10*sizeUnit),
                            child: Wrap(
                              runSpacing: 4*sizeUnit,
                              spacing: 4*sizeUnit,
                              children: _FilterStateForPersonal.catNameForTeam.asMap().map(
                                      (index, item) => MapEntry(index,
                                      GestureDetector(
                                          onTap: (){
                                            if( _FilterStateForPersonal.cataForTeam[index] == true){
                                              _FilterStateForPersonal.cataForTeam[index] = false;
                                            }
                                            else{
                                              _FilterStateForPersonal.cataForTeam[index] = true;
                                            }
                                            setState(() {

                                            });
                                          },
                                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.cataForTeam[index])
                                      )
                                  )
                              ).values.toList().cast<Widget>(),
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                          Row(
                            children: [
                              SizedBox(width: 12*sizeUnit),
                              Text(
                                "지역 필터링",
                                style: SheepsTextStyle.h3(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 12*sizeUnit),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10*sizeUnit),
                            child: Wrap(
                              runSpacing: 4*sizeUnit,
                              spacing: 4*sizeUnit,
                              children: _FilterStateForPersonal.locationNameForTeam.asMap().map(
                                      (index, item) => MapEntry(index,
                                      GestureDetector(
                                          onTap: (){
                                            if( _FilterStateForPersonal.locaForTeam[index] == true){
                                              _FilterStateForPersonal.locaForTeam[index] = false;
                                            }
                                            else{
                                              _FilterStateForPersonal.locaForTeam[index] = true;
                                            }
                                            setState(() {

                                            });
                                          },
                                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.locaForTeam[index])
                                      )
                                  )
                              ).values.toList().cast<Widget>(),
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                          Material(
                            color: Colors.white,
                            child: Row(
                              children: [
                                SizedBox(width: 12*sizeUnit),
                                Text(
                                  "팀 구분 필터링",
                                  style: SheepsTextStyle.h3(context),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12*sizeUnit),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10*sizeUnit),
                            child: Wrap(
                              runSpacing: 4*sizeUnit,
                              spacing: 4*sizeUnit,
                              children: _FilterStateForPersonal.distingNameForTeam.asMap().map(
                                      (index, item) => MapEntry(index,
                                      GestureDetector(
                                          onTap: (){
                                            if( _FilterStateForPersonal.distingForTeam[index] == true){
                                              _FilterStateForPersonal.distingForTeam[index] = false;
                                            }
                                            else{
                                              _FilterStateForPersonal.distingForTeam[index] = true;
                                            }
                                            setState(() {

                                            });
                                          },
                                          child: SheepsFilterItem(context, item, _FilterStateForPersonal.distingForTeam[index])
                                      )
                                  )
                              ).values.toList().cast<Widget>(),
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                          GestureDetector(
                            onTap: ()async{
                              List<String> tmp = ["IT","제조","건설","물류/유통","농·축·수산","부동산","요식업","에너지","교육","연규·기술·전문서비스","문화/여가","해외기관/법인","시설/기타 지원","기타"];
                              String orderrule = _FilterStateForPersonal.tabAlignForTeam ==  Alignment.centerLeft?"0": _FilterStateForPersonal.tabAlignForTeam ==  Alignment.center? "1":"2";


                              String partcheckall = "1";
                              String partSearch = "";
                              bool firstpart = false;
                              for(int i =0; i<tmp.length;i++){
                                if(_FilterStateForPersonal.cataForTeam[i] == true){
                                  partcheckall = "0";
                                  firstpart == false? partSearch += tmp[i] : partSearch = partSearch+"|^"+tmp[i];
                                  firstpart = true;
                                  partcheckall = "0";
                                }
                              }


                              List<String> tmp2 = ["서울","부산","대구","인천","광주","대전","울산","세종","경기","강원","충청북도","충청남도","전라북도","전라남도","경상북도","경상남도","제주"];
                              String locationcheckall = "1";
                              String locationSearch = "";
                              bool firstpart2 = false;
                              for(int i =0; i<tmp2.length;i++){
                                if(_FilterStateForPersonal.locaForTeam[i] == true){
                                  locationcheckall = "0";
                                  firstpart2 == false? locationSearch += tmp2[i] : locationSearch = locationSearch+"|^"+tmp2[i];
                                  firstpart2 = true;
                                  locationcheckall = "0";
                                }
                              }



                              List<String> tmp3 = ["예비창업팀","프로젝트팀","소모임","개인기업","법인기업","사회적기업","협동조합","기관"];
                              String teamcheckall = "1";
                              String teamSearch = "";
                              bool firstpart3 = false;
                              for(int i =0; i<tmp3.length;i++){
                                if(_FilterStateForPersonal.distingForTeam[i] == true){
                                  teamcheckall = "0";
                                  firstpart3 == false? teamSearch += tmp3[i] : teamSearch = teamSearch+"|^"+tmp3[i];
                                  firstpart3 = true;
                                  teamcheckall = "0";
                                }
                              }



                              if(partcheckall == "1" && locationcheckall == "1" && teamcheckall == "1"){
                                GlobalProfile.teamProfile.clear();

                                var tmp = await ApiProvider().post('/Search/TeamFilter', jsonEncode(
                                    {
                                      "orderrule": orderrule,
                                      "partcheckall" : partcheckall,
                                      "partSearch" : partSearch,
                                      "locationcheckall": locationcheckall,
                                      "locationSearch": locationSearch,
                                      "teamcheckall": teamcheckall,
                                      "teamSearch":teamSearch,
                                    }
                                ));
                                if( tmp != null){
                                  for(int i =0 ; i<tmp.length; i++){
                                    Team _team  = Team.fromJson(tmp[i]);
                                    GlobalProfile.teamProfile.add(_team);
                                  }
                                }
                                GlobalProfile.teamFiltered = false;
                              }
                              else{
                                GlobalProfile.teamProfileFiltered.clear();

                                var tmp = await ApiProvider().post('/Search/TeamFilter', jsonEncode(
                                    {
                                      "orderrule": orderrule,
                                      "partcheckall" : partcheckall,
                                      "partSearch" : partSearch,
                                      "locationcheckall": locationcheckall,
                                      "locationSearch": locationSearch,
                                      "teamcheckall": teamcheckall,
                                      "teamSearch":teamSearch,
                                    }
                                ));
                                if( tmp != null){
                                  for(int i =0 ; i<tmp.length; i++){
                                    Team _team  = Team.fromJson(tmp[i]);
                                    GlobalProfile.teamProfileFiltered.add(_team);
                                  }
                                }
                                GlobalProfile.teamFiltered = true;
                              }
                              filterActive = false;
                              setState(() {
                              });

                            },
                            child: Center(
                              child: Container(
                                width: 320*sizeUnit,
                                height: 48*sizeUnit,
                                decoration: BoxDecoration(
                                  color: Color(0xff61C680),
                                  // set border width
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(8*sizeUnit)), // set rounded corner radius
                                ),
                                child: Center(
                                  child: Text(
                                    "필터 적용",
                                    style: SheepsTextStyle.button1(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20*sizeUnit),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomRefreshIndicator(
                        onRefresh: ()async {

                          //개인프로필상태
                          if(profileState.getNum() == 0){
                            GlobalProfile.personalProfile.clear();
                            var tmp = await ApiProvider().post('/Profile/Personal/UserList', jsonEncode(
                                {
                                  "userID" : GlobalProfile.loggedInUser.userID
                                }
                            ));
                            if( tmp != null){
                              for(int i =0 ; i<tmp.length; i++){
                                UserData _user  = UserData.fromJson(tmp[i]);
                                GlobalProfile.personalProfile.add(_user);
                              }
                            }
                          }else{
                            GlobalProfile.teamProfile.clear();
                            var tmp = await ApiProvider().get('/Team/Profile/Select');
                            if( tmp != null){
                              for(int i =0 ; i<tmp.length; i++){
                                Team _team  = Team.fromJson(tmp[i]);
                                GlobalProfile.teamProfile.add(_team);
                              }
                            }
                          }
                          //데이터 세팅 초기화
                          setState(() {});
                          return Future.delayed(const Duration(milliseconds: 500));
                        },
                        builder: (
                            BuildContext context,
                            Widget child,
                            IndicatorController controller,
                            ) {
                          return AnimatedBuilder(
                            animation: controller,
                            builder: (BuildContext context, _) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: <Widget>[
                                  !controller.isIdle?
                                  Positioned(
                                    top: 10*sizeUnit* controller.value,
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        //  backgroundColor: Colors.red,
                                        valueColor: new AlwaysStoppedAnimation<Color>( hexToColor("#61C680")),

                                        /*   value: !controller.isLoading
                                      ? controller.value.clamp(0.0, 1.0)
                                      : null,*/
                                      ),
                                    ),
                                  ):Container(),
                                  Transform.translate(
                                    offset: Offset(0, 55*sizeUnit* controller.value),
                                    child: child,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: profileState.getNum() == 0
                            ? personalProfilePage(context) //개인프로필
                            : teamProfilePage(context), //팀프로필
                      ),

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

  Widget profilePageTopBar(BuildContext context, ProfileState profileState,
      NavigationNum navigationNum) {
    FilterStateForPersonal _FilterStateForPersonal = Provider.of<FilterStateForPersonal>(context);
    ProfileState profileState = Provider.of<ProfileState>(context);
    return Column(
      children: [
        Container(
          color: Colors.white,
          width: 360*sizeUnit,
          height: 60*sizeUnit,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                child: Container(
                  width: 256*sizeUnit,
                  height: 32*sizeUnit,
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular(8*sizeUnit),
                    color: hexToColor("#eeeeee"),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8*sizeUnit),
                        child: SvgPicture.asset(
                          svgGreyMagnifyingGlass,
                          width: 16*sizeUnit,
                          height: 16*sizeUnit,
                        ),
                      ),
                      Container(
                        width: 210*sizeUnit,
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (val)async{
                            if(profileState.getNum() == 0){
                              GlobalProfile.personalProfileFiltered.clear();

                              List<dynamic> tmp = new List<dynamic>();
                              tmp = await ApiProvider().post('/Profile/Personal/SearchName',jsonEncode({
                                "searchWord" : val,
                              }));

                              if(tmp != null){
                                for (int i = 0; i < tmp.length; i++) {
                                  UserData _user = UserData.fromJson(tmp[i]);
                                  GlobalProfile.personalProfileFiltered.add(_user);
                                }
                                GlobalProfile.personalFiltered = true;
                                setState(() {});
                              }
                            }
                            else{
                              GlobalProfile.teamProfileFiltered.clear();

                              List<dynamic> tmp = new List<dynamic>();
                              tmp = await ApiProvider().post('/Team/Profile/SearchName',jsonEncode({
                                "searchWord" : val,
                              }));
                              if(tmp != null){
                                for (int i = 0; i < tmp.length; i++) {
                                  Team _team = Team.fromJson(tmp[i]);
                                  GlobalProfile.teamProfileFiltered.add(_team);
                                }
                                GlobalProfile.teamFiltered = true;
                                setState(() {});
                              }
                            }
                          },
                          decoration: new InputDecoration(
                            hintText: profileState.getNum() == 0?"개인 프로필 검색":"팀 프로필 검색",
                            border: InputBorder.none,
                            hintStyle: SheepsTextStyle.info1(context),
                          ),
                          style: SheepsTextStyle.b3(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    filterActive = !filterActive;
                  });
                },
                child: filterActive
                    ? SvgPicture.asset(
                      svgBlackFilterIcon,
                      width: 28*sizeUnit,
                      height: 28*sizeUnit,
                    )
                    : SvgPicture.asset(
                      svgGreyFilterIcon,
                      width: 28*sizeUnit,
                      height: 28*sizeUnit,
                    ),
              ),
              SizedBox(
                width: 12*sizeUnit,
              ),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MyPage(),
                  )).then((value) {
                    setState(() {

                    });
                  });
                },
                child: SvgPicture.asset(
                  svgGreyMyPageButton,
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
        Container(
          width: 360*sizeUnit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      filterActive = false;
                      setState(() {
                        for(int i =0;i<  _FilterStateForPersonal.cataForTeam.length;i++){
                          _FilterStateForPersonal.cataForTeam[i] = false;
                        }
                        for(int i =0;i<  _FilterStateForPersonal.locaForTeam.length;i++){
                          _FilterStateForPersonal.locaForTeam[i] = false;
                        }
                        for(int i =0;i<  _FilterStateForPersonal.distingForTeam.length;i++){
                          _FilterStateForPersonal.distingForTeam[i] = false;
                        }
                        GlobalProfile.personalFiltered = false;
                        _FilterStateForPersonal.tabAlignForTeam=Alignment.centerLeft;
                        if (profileState.getNum() == 1) {
                          profileState.setNum(0);
                        }
                      });
                    },
                    child: Container(
                      width: 160*sizeUnit,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            '개인 프로필',
                            style:SheepsTextStyle.h4(context).copyWith(
                              color: profileState.getNum() == 0
                                  ? Color(0xFF61C680)
                                  : Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2*sizeUnit),
                    child: Container(
                      width: 72*sizeUnit,
                      height: 2*sizeUnit,
                      color: profileState.getNum() == 0
                          ? Color(0xFF61C680)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      filterActive = false;
                      setState(() {
                        for(int i =0;i<  _FilterStateForPersonal.locaForPerson.length;i++){
                          _FilterStateForPersonal.locaForPerson[i] = false;
                        }
                        for(int i =0;i<  _FilterStateForPersonal.cataForPerson.length;i++){
                          _FilterStateForPersonal.cataForPerson[i] = false;
                        }
                        GlobalProfile.teamFiltered = false;
                        _FilterStateForPersonal.tabAlignForPerson=Alignment.centerLeft;
                        if (profileState.getNum() == 0) {
                          profileState.setNum(1);
                        }
                      });
                    },
                    child: Container(
                      width: 160*sizeUnit,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            '팀 프로필',
                            style:SheepsTextStyle.h4(context).copyWith(
                              color: profileState.getNum() == 1
                                  ? Color(0xFF61C680)
                                  : Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2*sizeUnit),
                    child: Container(
                      width: 60*sizeUnit,
                      height: 2*sizeUnit,
                      color: profileState.getNum() == 1
                          ? Color(0xFF61C680)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 360*sizeUnit,
          height: 1,
          color: Color(0xFFEEEEEE),
        ),
      ],
    );
  }

  Container teamProfilePage(BuildContext context) {
    return
      GlobalProfile.teamFiltered == false?
      GlobalProfile.teamProfile.length==0?Container(width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
            SizedBox(height: 40*sizeUnit),
            Text("아쉽게도 검색 결과가 없습니다.\n다시 시도해주세요.",style: SheepsTextStyle.b2(context),textAlign: TextAlign.center,)
          ],
        ),):
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
        child: GridView.count(
          //primary: false,
          controller: scrollController,
          mainAxisSpacing: 8*sizeUnit,
          crossAxisSpacing: 8*sizeUnit,
          crossAxisCount: 2,
          childAspectRatio: 160 / 284,//각 그리드뷰 비율 조정
          children:  GlobalProfile.teamFiltered == false?
          List.generate(GlobalProfile.teamProfile.length, (index) {
            if(index == GlobalProfile.teamProfile.length){
              return CupertinoActivityIndicator();
            }
            return SheepsTeamProfileCard(context,GlobalProfile.teamProfile[index],index,extendedController);
          }):

          List.generate(GlobalProfile.teamProfileFiltered.length, (index) {
            if(index == GlobalProfile.teamProfileFiltered.length){
              return CupertinoActivityIndicator();
            }
            return SheepsTeamProfileCard(context,GlobalProfile.teamProfileFiltered[index],index,extendedController);
          }),
        ),
      ):
      GlobalProfile.teamProfileFiltered.length==0?
      Container(width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
            SizedBox(height: 40*sizeUnit),
            Text("아쉽게도 검색 결과가 없습니다.\n다시 시도해주세요.",style: SheepsTextStyle.b2(context),textAlign: TextAlign.center,)
          ],
        ),):
      Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
        child: GridView.count(
          //primary: false,
          controller: scrollController,
          mainAxisSpacing: 8*sizeUnit,
          crossAxisSpacing: 8*sizeUnit,
          crossAxisCount: 2,
          childAspectRatio: 160 / 284,//각 그리드뷰 비율 조정
          children:  GlobalProfile.teamFiltered == false?

          List.generate(GlobalProfile.teamProfile.length, (index) {
            if(index == GlobalProfile.teamProfile.length){
              return CupertinoActivityIndicator();
            }
            return SheepsTeamProfileCard(context,GlobalProfile.teamProfile[index],index,extendedController);
          }):

          List.generate(GlobalProfile.teamProfileFiltered.length, (index) {
            if(index == GlobalProfile.teamProfileFiltered.length){
              return CupertinoActivityIndicator();
            }
            return SheepsTeamProfileCard(context,GlobalProfile.teamProfileFiltered[index],index,extendedController);
          }),
        ),
      );
  }



  Container personalProfilePage(BuildContext context) {
    return GlobalProfile.personalFiltered == false?
    GlobalProfile.personalProfile.length==0 ?
    Container(width: 360*sizeUnit,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgGreySheepEyeX, width: 192*sizeUnit, height: 138*sizeUnit),
          SizedBox(height: 40*sizeUnit),
          Text(
            "아쉽게도 검색 결과가 없습니다.\n다시 시도해주세요.",
            style: SheepsTextStyle.b2(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ):
    Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
      child: GridView.count(
        primary: false,
        controller: scrollController,
        mainAxisSpacing: 8*sizeUnit,
        crossAxisSpacing: 8*sizeUnit,
        crossAxisCount: 2,
        childAspectRatio: 160 / 284,//각 그리드뷰 비율 조정
        children:
        GlobalProfile.personalFiltered == false?
        List.generate(GlobalProfile.personalProfile.length, (index) {
          if(index == GlobalProfile.personalProfile.length){
            return CupertinoActivityIndicator();
          }
          return SheepsPersonalProfileCard(context, GlobalProfile.personalProfile[index], index, extendedController);
        }):
        List.generate(GlobalProfile.personalProfileFiltered.length, (index) {
          if(index == GlobalProfile.personalProfileFiltered.length){
            return CupertinoActivityIndicator();
          }
          return SheepsPersonalProfileCard(context, GlobalProfile.personalProfileFiltered[index], index, extendedController);
        }),
      ),
    ):
    GlobalProfile.personalProfileFiltered.length==0?
    Container(width: 360*sizeUnit,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
          SizedBox(height: 40*sizeUnit),
          Text(
            "아쉽게도 검색 결과가 없습니다.\n다시 시도해주세요.",
            style: SheepsTextStyle.b2(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ) :
    Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
      child: GridView.count(
        primary: false,
        //physics:  NeverScrollableScrollPhysics(),
        controller: scrollController,
        mainAxisSpacing: 8*sizeUnit,
        crossAxisSpacing: 8*sizeUnit,
        crossAxisCount: 2,
        childAspectRatio: 160 / 284,//각 그리드뷰 비율 조정
        children:
        GlobalProfile.personalFiltered == false?
        List.generate(GlobalProfile.personalProfile.length, (index) {
          if(index == GlobalProfile.personalProfile.length){
            return CupertinoActivityIndicator();
          }
          return SheepsPersonalProfileCard(context, GlobalProfile.personalProfile[index], index, extendedController);
        }):
        List.generate(GlobalProfile.personalProfileFiltered.length, (index) {
          if(index == GlobalProfile.personalProfileFiltered.length){
            return CupertinoActivityIndicator();
          }
          return SheepsPersonalProfileCard(context, GlobalProfile.personalProfileFiltered[index], index, extendedController);
        }),
      ),
    );
  }
}
