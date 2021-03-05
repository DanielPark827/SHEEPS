import 'dart:async';
import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/Community/CommunityWrite.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/Community/CommunityListItem.dart';
import 'package:sheeps_app/dashboard/MyPage.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class CommunutyMain extends StatefulWidget {
  @override
  _CommunutyMainState createState() => _CommunutyMainState();
}

class _CommunutyMainState extends State<CommunutyMain>
    with SingleTickerProviderStateMixin {
  double sizeUnit = 1;
  final String GreenPencilWriteIcon = 'assets/images/Community/GreenPencilWriteIcon.svg';

  final SearchCommunityController = TextEditingController();
  GlobalKey<RefreshIndicatorState> refreshKey;
  AnimationController extendedController;
  ScrollController _scrollController3 = ScrollController();
  NavigationNum navigationNum;
  int prevPage = -1;

  bool bLoading;
  bool bLoadMoreData = false;
  String CurrentFilter = "전체";
  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  @override
  void initState() {
    super.initState();
    ProfileState profileState = Provider.of<ProfileState>(context,listen: false);
    int num =  profileState.getNum();
    refreshKey = GlobalKey<RefreshIndicatorState>();

    _scrollController3.addListener(() async{
      bLoadMoreData = true;
      if (_scrollController3.position.pixels == _scrollController3.position.maxScrollExtent) {
        num == 0 ?
        Timer(Duration(milliseconds: 500), () async {
          debugPrint("Yeah, this line is printed after 3 seconds");
          var tmp = await ApiProvider().post(
              '/CommunityPost/SelectBasicOffset',
              jsonEncode({
                "index": GlobalProfile.newCommunityList.length,
              }));

          if(tmp != null){
            for (int i = 0; i < tmp.length; i++) {
              Community community = Community.fromJson(tmp[i]);
              GlobalProfile.newCommunityList.add(community);
              await GlobalProfile.getFutureUserByUserID(community.userID);
            }

            setState(() {
              bLoadMoreData = false;
            });
          }
        })
        :Timer(Duration(milliseconds: 500), () async {
          debugPrint("Yeah, this line is printed after 3 seconds");
          var tmp = await ApiProvider().post(
              '/CommunityPost/SelectJobGroupOffset',
              jsonEncode({
                "index": GlobalProfile.newCommunityListByJob.length,
              }));

          if(tmp != null){
            for (int i = 0; i < tmp.length; i++) {
              Community community = Community.fromJson(tmp[i]);
              GlobalProfile.newCommunityListByJob.add(community);
              await GlobalProfile.getFutureUserByUserID(community.userID);
            }

            setState(() {
              bLoadMoreData = false;
            });
          }
        });
      }
    });
    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        lowerBound: 0.0,
        upperBound: 1.0);
    bLoading = false;
  }



  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    extendedController.dispose();
    _scrollController3.dispose();
    SearchCommunityController.dispose();
    super.dispose();
  }

  List<String> Category = ['전체', '스타트업', '비밀', '홍보', '자유', '소모임'];
  List<String> Field = [
    "전체",
    "개발",
    "경영",
    "디자인",
    "마케팅",
    "자영업",
  ];
  List<String> RouteForCommunity = [
    '',
    '/Company',
    '/Secret',
    '/Promotion',
    '/Free',
    '/Small'
  ];

  //일반 커뮤니티 신규게시글
  List<bool> newCommunityVisibleList = [];
  //일반 커뮤니티 인기게시글
  List<bool> popularCommunityVisibleList = [];
  //직군별 커뮤니티 신규게시글
  List<bool> newCommunityByJobVisibleList = [];
  //직군별 커뮤니티 인기게시글
  List<bool> popularCommunityByJobVisibleList = [] ;
  //필터된게시글
  List<bool> searchWordVisibleList = [];
  List<bool> filterAfterSelectPersonalVisibleList = [];

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    if (navigationNum == null){
      navigationNum = Provider.of<NavigationNum>(context);
      prevPage = navigationNum.getPastNum();
    }


    if (navigationNum.getNum() == navigationNum.getPastNum()) {
      if (_scrollController3.hasClients) {
        _scrollController3.animateTo(0,duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        navigationNum.setNormalPastNum(prevPage);
      }
    }

    ProfileState profileState = Provider.of<ProfileState>(context);

    var tmp = false;
    for (int i = 0; i < GlobalProfile.newCommunityList.length; i++) {
      newCommunityVisibleList.add(tmp);
    }
    for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
      popularCommunityVisibleList.add(tmp);
    }

    for (int i = 0; i < GlobalProfile.newCommunityListByJob.length; i++) {
      newCommunityByJobVisibleList.add(tmp);
    }
    for (int i = 0; i < GlobalProfile.popularCommunityListByJob.length; i++) {
      popularCommunityByJobVisibleList.add(tmp);
    }
    for (int i = 0; i < GlobalProfile.searchWord.length; i++) {
      searchWordVisibleList.add(tmp);
    }
    for (int i = 0; i < GlobalProfile.filteredCommunityList.length; i++) {
      filterAfterSelectPersonalVisibleList.add(tmp);
    }

    final String GreyMyPageButton = 'assets/images/Public/GreyMyPageButton.svg';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
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
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    buildNormalCommunity(context, profileState, svgGreyMagnifyingGlass, GreyMyPageButton),
                    SizedBox(height: 16*sizeUnit),
                    Expanded(
                      child: CustomRefreshIndicator(
                        onRefresh: ()async {
                          //전체일경우 refresh
                          if ((SearchCommunityController.text == null || SearchCommunityController.text == "") && CurrentFilter == "전체") {
                            GlobalProfile.popularCommunityList.clear();

                            List<dynamic> tmp = new List<dynamic>();
                            tmp = await ApiProvider()
                                .get('/CommunityPost/Select/PopularBasicPost');
                            for (int i = 0; i < tmp.length; i++) {
                              Community community = Community.fromJson(tmp[i]);
                              GlobalProfile.popularCommunityList.add(community);
                              await GlobalProfile.getFutureUserByUserID(community.userID);
                            }

                            GlobalProfile.newCommunityList.clear();
                            tmp = new List<dynamic>();
                            tmp = await ApiProvider().get('/CommunityPost/Select/BasicPost');
                            if(tmp != null){
                              for (int i = 0; i < tmp.length; i++) {
                                Community community = Community.fromJson(tmp[i]);
                                GlobalProfile.newCommunityList.add(community);
                                await GlobalProfile.getFutureUserByUserID(community.userID);
                              }
                            }
                          }
                          //나머지 필터일경우 refresh
                          else if (SearchCommunityController.text == null || SearchCommunityController.text == "") {
                            GlobalProfile.filteredCommunityList.clear();

                            var tmp = await ApiProvider().post(
                                "/CommunityPost/SearchCategory",
                                jsonEncode({
                                  "category": CurrentFilter,
                                  "index": 0,
                                }));

                            if(tmp != null){
                              for (int i = 0; i < tmp.length; i++) {
                                Community community = Community.fromJson(tmp[i]);
                                GlobalProfile.filteredCommunityList.add(community);
                                await GlobalProfile.getFutureUserByUserID(community.userID);
                              }
                            }
                          } else {}
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
                                    top: 10*sizeUnit * controller.value,
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        valueColor: new AlwaysStoppedAnimation<Color>( hexToColor("#61C680")),
                                      ),
                                    ),
                                  ):Container(),
                                  Transform.translate(
                                    offset: Offset(0, 55.0 * controller.value),
                                    child: child,
                                  ),
                                ],
                              );

                            },
                          );
                        },
                        child: (SearchCommunityController.text == null || SearchCommunityController.text == "")
                            ? CurrentFilter == "전체"
                              ? Container(
                            width: 360*sizeUnit,
                            child: ListView.builder(
                                controller: _scrollController3,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount:
                                profileState.getNum() == 0 ?
                                (GlobalProfile.newCommunityList.length + 1) : GlobalProfile.newCommunityListByJob.length+1,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  if (index == ( profileState.getNum() == 0 ?GlobalProfile.newCommunityList.length:GlobalProfile.newCommunityListByJob.length)) {
                                    return bLoadMoreData ? CupertinoActivityIndicator() : null;
                                  }
                                  else if (index == 0) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              12*sizeUnit,
                                              0,
                                              12*sizeUnit,
                                              0),
                                          child: Row(
                                            children: [
                                              Container(
                                                child: Text(
                                                  '인기 게시글',
                                                  style: SheepsTextStyle.h3(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8*sizeUnit),

                                        //일반커뮤니티의 경우 인기게시글
                                        profileState.getNum() == 0 ?
                                        ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: GlobalProfile
                                                .popularCommunityList
                                                .length,
                                            itemBuilder:
                                                (BuildContext context,
                                                int index) {
                                              return SheepsCommunityItem(
                                                context: context,
                                                community: GlobalProfile.popularCommunityList[index],
                                                index: index,
                                                extendedController: extendedController,
                                                isMorePhoto: popularCommunityVisibleList[index],
                                                tapPhotoFunc: () {
                                                  setState(() {
                                                    if (popularCommunityVisibleList[index] == false) {
                                                      popularCommunityVisibleList[index] = true;
                                                    } else {
                                                      popularCommunityVisibleList[index] = false;
                                                    }
                                                  });
                                                },
                                                isLike: popularCommunityInsertCheck(GlobalProfile.loggedInUser.userID, index),
                                                tapLikeFunc: () async{
                                                  if(isCanTapLike){
                                                    isCanTapLike = false;
                                                    if (popularCommunityInsertCheck(GlobalProfile.loggedInUser.userID, index) == false) {
                                                      var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                                        "userID": GlobalProfile.loggedInUser.userID,
                                                        "postID": GlobalProfile.popularCommunityList[index].id
                                                      }));

                                                      if(result != null){
                                                        CommunityLike user = InsertLike.fromJson(result)?.item;
                                                        GlobalProfile.popularCommunityList[index].communityLike.add(user);

                                                        for (int i = 0; i < GlobalProfile.newCommunityList.length; i++) {
                                                          if (GlobalProfile.popularCommunityList[index].id ==GlobalProfile.newCommunityList[i].id) {
                                                            GlobalProfile.newCommunityList[index].communityLike.add(user);
                                                            break;
                                                          }
                                                        }
                                                        setState(() {

                                                        });
                                                      }
                                                    } else {
                                                      await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                                        "userID": GlobalProfile.loggedInUser.userID,
                                                        "postID": GlobalProfile.popularCommunityList[index].id
                                                      }));

                                                      int idx = -1;

                                                      for (int i = 0;i < GlobalProfile.popularCommunityList[index].communityLike.length; i++) {
                                                        if (GlobalProfile.popularCommunityList[index].communityLike[i].userID == GlobalProfile.loggedInUser.userID) {
                                                          idx = i;
                                                          break;
                                                        }
                                                      }

                                                      if(idx != -1){
                                                        for(int i =0;i<GlobalProfile.newCommunityList.length;i++){
                                                          if(GlobalProfile.popularCommunityList[index].id == GlobalProfile.newCommunityList[i].id){
                                                            for(int j =0;j< GlobalProfile.newCommunityList[i].communityLike.length;j++){
                                                              if(GlobalProfile.newCommunityList[i].communityLike[j].userID == GlobalProfile.loggedInUser.userID){
                                                                GlobalProfile.newCommunityList[i].communityLike.removeAt(j);
                                                              }
                                                            }
                                                          }
                                                        }
                                                        GlobalProfile.popularCommunityList[index].communityLike.removeAt(idx);
                                                      }
                                                    }
                                                    setState(() {
                                                      Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                                        isCanTapLike = true;
                                                      });
                                                    });
                                                  }
                                                },
                                              );
                                            })
                                        //직군별커뮤니티의 경우 인기게시글
                                            :
                                        ListView.builder(
                                            physics:
                                            NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: GlobalProfile
                                                .popularCommunityListByJob
                                                .length,
                                            itemBuilder:
                                                (BuildContext context,
                                                int index) {
                                              return SheepsCommunityItem(
                                                context: context,
                                                community: GlobalProfile.popularCommunityListByJob[index],
                                                index: index,
                                                extendedController: extendedController,
                                                isMorePhoto: popularCommunityByJobVisibleList[index],
                                                tapPhotoFunc:() {
                                                  setState(() {
                                                    if (popularCommunityByJobVisibleList[index] == false) {
                                                      popularCommunityByJobVisibleList[index] = true;
                                                    } else {
                                                      popularCommunityByJobVisibleList[index] = false;
                                                    }
                                                  });
                                                },
                                                isLike: popularCommunityByJobInsertCheck(GlobalProfile.loggedInUser.userID, index),
                                                tapLikeFunc: () async{
                                                  if(isCanTapLike){
                                                    isCanTapLike = false;
                                                    if (popularCommunityByJobInsertCheck(GlobalProfile.loggedInUser.userID, index) ==
                                                        false) {
                                                      var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                                        "userID": GlobalProfile.loggedInUser.userID,
                                                        "postID": GlobalProfile.popularCommunityListByJob[index].id
                                                      }));

                                                      if(result != null){
                                                        CommunityLike user = InsertLike.fromJson(result)?.item;
                                                        GlobalProfile.popularCommunityListByJob[index].communityLike.add(user);
                                                        for (int i = 0; i < GlobalProfile.newCommunityListByJob.length; i++) {
                                                          if (GlobalProfile.newCommunityListByJob[i].id == GlobalProfile.popularCommunityListByJob[index].id) {
                                                            GlobalProfile.newCommunityListByJob[i].communityLike .add(user);
                                                            break;
                                                          }
                                                        }

                                                      }
                                                    } else {
                                                      await ApiProvider().post(
                                                          '/CommunityPost/InsertLike',
                                                          jsonEncode({
                                                            "userID": GlobalProfile.loggedInUser.userID,
                                                            "postID": GlobalProfile.popularCommunityListByJob[index].id
                                                          }));

                                                      int idx = -1;

                                                      for (int i = 0;i < GlobalProfile.popularCommunityListByJob[index].communityLike.length;i++) {
                                                        if (GlobalProfile.popularCommunityListByJob[index].communityLike[i].userID == GlobalProfile.loggedInUser.userID) {
                                                          idx = i;
                                                          break;
                                                        }
                                                      }

                                                      if(idx != -1){
                                                        for(int i =0;i<GlobalProfile.newCommunityListByJob.length;i++){
                                                          if(GlobalProfile.popularCommunityListByJob[index].id == GlobalProfile.newCommunityList[i].id){
                                                            for(int j =0;j< GlobalProfile.newCommunityListByJob[i].communityLike.length;j++){
                                                              if(GlobalProfile.newCommunityListByJob[i].communityLike[j].userID == GlobalProfile.loggedInUser.userID){
                                                                GlobalProfile.newCommunityListByJob[i].communityLike.removeAt(j);
                                                              }
                                                            }
                                                          }
                                                        }
                                                        GlobalProfile.popularCommunityListByJob[index].communityLike.removeAt(idx);
                                                      }
                                                    }
                                                    setState(() {
                                                      Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                                        isCanTapLike = true;
                                                      });
                                                    });
                                                  }
                                                },
                                              );
                                            }),
                                        ////////////////////////////////////////

                                        SizedBox(height: 40*sizeUnit),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              12*sizeUnit,
                                              0,
                                              12*sizeUnit,
                                              0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  child: Text(
                                                    '신규 게시글',
                                                    style: SheepsTextStyle.h3(context),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 16*sizeUnit),
                                        profileState.getNum() == 0
                                            ? SheepsCommunityItem(
                                          context: context,
                                          community: GlobalProfile.newCommunityList[index],
                                          index: index,
                                          extendedController: extendedController,
                                          isMorePhoto: newCommunityVisibleList[index],
                                          tapPhotoFunc: () {
                                            setState(() {
                                              if (newCommunityVisibleList[index] == false) {
                                                newCommunityVisibleList[index] = true;
                                              } else {
                                                newCommunityVisibleList[index] = false;
                                              }
                                            });
                                          },
                                          isLike: newCommunityInsertCheck(GlobalProfile.loggedInUser.userID, index),
                                          tapLikeFunc: () async{
                                            if(isCanTapLike){
                                              isCanTapLike = false;
                                              if (newCommunityInsertCheck(GlobalProfile.loggedInUser.userID,index) ==false) {
                                                var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                                  "userID": GlobalProfile.loggedInUser.userID,
                                                  "postID": GlobalProfile.newCommunityList[index].id
                                                }));


                                                if(result != null){
                                                  CommunityLike user = InsertLike.fromJson(result)?.item;
                                                  GlobalProfile.newCommunityList[index].communityLike.add(user);
                                                  for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
                                                    if (GlobalProfile.popularCommunityList[i].id ==GlobalProfile.newCommunityList[index].id) {
                                                      GlobalProfile.popularCommunityList[i].communityLike.add(user);
                                                      break;
                                                    }
                                                  }
                                                }
                                              } else {
                                                await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                                  "userID": GlobalProfile.loggedInUser.userID,
                                                  "postID": GlobalProfile.newCommunityList[index].id
                                                }));

                                                int idx = -1;

                                                for (int i = 0; i < GlobalProfile.newCommunityList[index].communityLike.length; i++) {
                                                  if (GlobalProfile.newCommunityList[index].communityLike[i].userID == GlobalProfile.loggedInUser.userID) {
                                                    idx = i;
                                                    break;
                                                  }
                                                }

                                                if(idx != -1){
                                                  GlobalProfile.newCommunityList[index].communityLike.removeAt(idx);

                                                  int idx1 =-1;
                                                  int idx2 =-1;

                                                  for (int i =0; i < GlobalProfile.popularCommunityList.length; i++) {
                                                    if (GlobalProfile.popularCommunityList[i].id == GlobalProfile.newCommunityList[index].id) {
                                                      idx1 = i;
                                                      break;
                                                    }
                                                  }

                                                  if (idx1 != -1) {
                                                    for (int i = 0; i < GlobalProfile.popularCommunityList[idx1].communityLike.length; i++) {
                                                      if ((GlobalProfile.popularCommunityList[idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                        idx2 = i;
                                                        break;
                                                      }
                                                    }
                                                    if (idx2 != -1){
                                                      GlobalProfile.popularCommunityList[idx1].communityLike.removeAt(idx2);
                                                    }
                                                  }
                                                  idx1 = -1;
                                                  idx2 = -1;
                                                }
                                              }
                                              setState(() {
                                                Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                                  isCanTapLike = true;
                                                });
                                              });
                                            }
                                          },
                                        )
                                            : SheepsCommunityItem(
                                          context: context,
                                          community: GlobalProfile.newCommunityListByJob[index],
                                          index: index,
                                          extendedController: extendedController,
                                          isMorePhoto: newCommunityByJobVisibleList[index],
                                          tapPhotoFunc: () {
                                            setState(() {
                                              if (newCommunityByJobVisibleList[index] == false) {
                                                newCommunityByJobVisibleList[index] = true;
                                              } else {
                                                newCommunityByJobVisibleList[index] = false;
                                              }
                                            });
                                          },
                                          isLike: newCommunityByJobInsertCheck(GlobalProfile.loggedInUser.userID, index),
                                          tapLikeFunc: () async{
                                            if(isCanTapLike){
                                              isCanTapLike = false;
                                              if (newCommunityByJobInsertCheck(GlobalProfile.loggedInUser.userID,index) ==false) {
                                                var result = await ApiProvider().post('/CommunityPost/InsertLike',
                                                    jsonEncode({
                                                      "userID":GlobalProfile.loggedInUser.userID,
                                                      "postID":GlobalProfile.newCommunityListByJob[index].id
                                                    }));

                                                if(result != null){
                                                  CommunityLike user = InsertLike.fromJson(result)?.item;
                                                  GlobalProfile.newCommunityListByJob[index].communityLike.add(user);
                                                  for (int i = 0; i < GlobalProfile.popularCommunityListByJob.length; i++) {
                                                    if (GlobalProfile.popularCommunityListByJob[i].id == GlobalProfile.newCommunityListByJob[index].id) {
                                                      GlobalProfile.popularCommunityListByJob[i].communityLike .add(user);
                                                      break;
                                                    }
                                                  }
                                                }
                                              } else {
                                                await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                                  "userID":GlobalProfile.loggedInUser.userID,
                                                  "postID":GlobalProfile.newCommunityListByJob[index].id
                                                }));

                                                int idx = -1;

                                                for (int i = 0; i < GlobalProfile.newCommunityListByJob[index].communityLike.length;i++) {
                                                  if (GlobalProfile.newCommunityListByJob[index].communityLike[i].userID ==GlobalProfile.loggedInUser.userID) {
                                                    idx = i;
                                                    break;
                                                  }
                                                }

                                                if(idx != -1){
                                                  GlobalProfile.newCommunityListByJob[index].communityLike.removeAt(idx);

                                                  int idx1 = -1;
                                                  int idx2 = -1;

                                                  for (int i = 0; i < GlobalProfile.popularCommunityListByJob.length; i++) {
                                                    if (GlobalProfile.popularCommunityListByJob[i].id == GlobalProfile.newCommunityListByJob[index].id) {
                                                      idx1 = i;
                                                      break;
                                                    }
                                                  }

                                                  if (idx1 != -1) {
                                                    for (int i = 0; i < GlobalProfile.popularCommunityListByJob[idx1].communityLike.length; i++) {
                                                      if ((GlobalProfile.popularCommunityListByJob[idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                        idx2 = i;
                                                        break;
                                                      }
                                                    }
                                                    if (idx2 != -1){
                                                      GlobalProfile.popularCommunityListByJob[idx1].communityLike.removeAt(idx2);
                                                    }
                                                  }
                                                  idx1 = -1;
                                                  idx2 = -1;
                                                }
                                              }
                                              setState(() {
                                                Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                                  isCanTapLike = true;
                                                });
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  }

                                  //일반커뮤니티의 경우 신규게시글
                                  return   profileState.getNum() == 0
                                      ? SheepsCommunityItem(
                                    context: context,
                                    community: GlobalProfile.newCommunityList[index],
                                    index: index,
                                    extendedController: extendedController,
                                    isMorePhoto: newCommunityVisibleList[index],
                                    tapPhotoFunc: () {
                                      setState(
                                              () {
                                            if (newCommunityVisibleList[index] ==
                                                false) {
                                              newCommunityVisibleList[index] = true;
                                            } else {
                                              newCommunityVisibleList[index] = false;
                                            }
                                          });
                                    },
                                    isLike: newCommunityInsertCheck(GlobalProfile.loggedInUser.userID,index),
                                    tapLikeFunc: () async{
                                      if(isCanTapLike){
                                        isCanTapLike = false;
                                        if (newCommunityInsertCheck( GlobalProfile.loggedInUser.userID,index) == false) {
                                          var result =await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({"userID": GlobalProfile.loggedInUser.userID,
                                            "postID": GlobalProfile.newCommunityList[index].id
                                          }));

                                          if(result != null){
                                            CommunityLike user =InsertLike.fromJson(result)?.item;
                                            GlobalProfile.newCommunityList[index].communityLike.add(user);
                                          }
                                        } else {
                                          await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                            "userID": GlobalProfile.loggedInUser.userID,
                                            "postID": GlobalProfile.newCommunityList[index].id
                                          }));

                                          int idx = -1;

                                          for (int i = 0; i < GlobalProfile.newCommunityList[index].communityLike.length; i++) {
                                            if (GlobalProfile.newCommunityList[index].communityLike[i].userID ==GlobalProfile.loggedInUser.userID) {
                                              idx = i;
                                              break;
                                            }
                                          }

                                          if(idx != -1){
                                            GlobalProfile.newCommunityList[index].communityLike.removeAt(idx);
                                          }
                                        }
                                        setState(() {
                                          Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                            isCanTapLike = true;
                                          });
                                        });
                                      }
                                    },
                                  )
                                      : SheepsCommunityItem(
                                    context: context,
                                    community: GlobalProfile.newCommunityListByJob[index],
                                    index: index,
                                    extendedController: extendedController,
                                    isMorePhoto: newCommunityByJobVisibleList[index],
                                    tapPhotoFunc: () {
                                      setState(
                                              () {
                                            if (newCommunityByJobVisibleList[index] ==
                                                false) {
                                              newCommunityByJobVisibleList[index] = true;
                                            } else {
                                              newCommunityByJobVisibleList[index] = false;
                                            }
                                          });
                                    },
                                    isLike: newCommunityByJobInsertCheck(GlobalProfile.loggedInUser.userID,index),
                                    tapLikeFunc: () async{
                                      if(isCanTapLike){
                                        isCanTapLike = false;
                                        if (newCommunityByJobInsertCheck(GlobalProfile.loggedInUser.userID, index) == false) {
                                          var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                            "userID": GlobalProfile.loggedInUser.userID,
                                            "postID": GlobalProfile.newCommunityListByJob[index].id
                                          }));

                                          if(result != null){
                                            CommunityLike user = InsertLike.fromJson(result)?.item;
                                            GlobalProfile.newCommunityListByJob[index].communityLike.add(user);
                                          }
                                        } else {
                                          await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                            "userID": GlobalProfile.loggedInUser.userID,
                                            "postID": GlobalProfile.newCommunityListByJob[index]
                                                .id
                                          }));

                                          int idx = -1;

                                          for (int i = 0; i < GlobalProfile.newCommunityListByJob[index].communityLike.length; i++) {
                                            if (GlobalProfile.newCommunityListByJob[index].communityLike[i].userID == GlobalProfile.loggedInUser.userID) {
                                              idx = i;
                                              break;
                                            }
                                          }

                                          if(idx != -1){
                                            GlobalProfile.newCommunityListByJob[index].communityLike.removeAt(idx);
                                          }
                                        }
                                        setState(() {
                                          Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                            isCanTapLike = true;
                                          });
                                        });
                                      }
                                    },
                                  );
                                })
                        )
                              : Container(
                          width: 360*sizeUnit,
                          child: ListView.builder(
                              controller: _scrollController3,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: GlobalProfile
                                  .filteredCommunityList.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                return SheepsCommunityItem(
                                  context: context,
                                  community: GlobalProfile.filteredCommunityList[index],
                                  index: index,
                                  extendedController: extendedController,
                                  isMorePhoto: filterAfterSelectPersonalVisibleList[index],
                                  tapPhotoFunc: () {
                                    setState(
                                            () {
                                          if (filterAfterSelectPersonalVisibleList[index] ==
                                              false) {
                                            filterAfterSelectPersonalVisibleList[index] = true;
                                          } else {
                                            filterAfterSelectPersonalVisibleList[index] = false;
                                          }
                                        });
                                  },
                                  isLike: insertCheckForFilterAfterSelect(GlobalProfile.loggedInUser.userID,index),
                                  tapLikeFunc: () async{
                                    if(isCanTapLike){
                                      isCanTapLike = false;
                                      if (insertCheckForFilterAfterSelect(GlobalProfile.loggedInUser.userID,index) == false) {
                                        var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                          "userID": GlobalProfile.loggedInUser.userID,
                                          "postID": GlobalProfile.filteredCommunityList[index].id
                                        }));

                                        if(result != null){
                                          CommunityLike user = InsertLike.fromJson(result)?.item;
                                          GlobalProfile.filteredCommunityList[index].communityLike.add(user);
                                          for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
                                            if (GlobalProfile.popularCommunityList[i].id == GlobalProfile.filteredCommunityList[index].id) {
                                              GlobalProfile.popularCommunityList[i].communityLike.add(user);
                                              break;
                                            }
                                          }
                                          for (int i = 0; i < GlobalProfile.newCommunityList.length;i++) {
                                            if (GlobalProfile.newCommunityList[i].id == GlobalProfile.filteredCommunityList[index].id) {
                                              GlobalProfile.newCommunityList[i].communityLike.add(user);
                                              break;
                                            }
                                          }
                                        }
                                      } else {
                                        await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                          "userID": GlobalProfile.loggedInUser.userID,
                                          "postID": GlobalProfile.filteredCommunityList[index].id
                                        }));

                                        int idx = -1;
                                        for (int i = 0; i <GlobalProfile.filteredCommunityList[index].communityLike.length;i++) {
                                          if (GlobalProfile.filteredCommunityList[index].communityLike[i].userID == GlobalProfile.loggedInUser.userID) {
                                            idx = i;
                                            break;
                                          }
                                        }

                                        if(idx != null){
                                          //필터된곳에서 찾아서 삭제
                                          GlobalProfile.filteredCommunityList[index].communityLike.removeAt(idx);

                                          int idx1 = -1;
                                          int idx2 = -1;

                                          for (int i = 0;i <GlobalProfile.popularCommunityList.length;i++) {
                                            if (GlobalProfile.popularCommunityList[i].id == GlobalProfile.filteredCommunityList[index].id) {
                                              idx1 = i;
                                              break;
                                            }
                                          }

                                          if (idx1 !=-1) {
                                            for (int i =0; i <GlobalProfile.popularCommunityList[idx1].communityLike.length; i++) {
                                              if ((GlobalProfile.popularCommunityList[idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                idx2 = i;
                                                break;
                                              }
                                            }

                                            if (idx2 !=-1){
                                              //인기 게시글에서 찾아서 삭제
                                              GlobalProfile.popularCommunityList[idx1].communityLike.removeAt(idx2);
                                            }

                                          }
                                          idx1 = -1;
                                          idx2 = -1;

                                          for (int i = 0;i < GlobalProfile.newCommunityList.length; i++) {
                                            if (GlobalProfile.newCommunityList[i].id == GlobalProfile.filteredCommunityList[index].id) {
                                              idx1 = i;
                                              break;
                                            }
                                          }

                                          if (idx1 !=-1) {
                                            for (int i = 0; i < GlobalProfile.newCommunityList[idx1].communityLike.length; i++) {
                                              if ((GlobalProfile.newCommunityList[idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                idx2 = i;
                                                break;
                                              }
                                            }

                                            if (idx2 != -1){
                                              //신규 게시글에서 찾아서 삭제
                                              GlobalProfile.newCommunityList[idx1].communityLike.removeAt(idx2);
                                            }
                                          }
                                          idx1 = -1;
                                          idx2 = -1;
                                        }

                                      }
                                      setState(() {
                                        Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                          isCanTapLike = true;
                                        });
                                      });
                                    }
                                  },
                                );
                              }),
                        )
                            : GlobalProfile.searchWord.length == 0
                              ? Container(
                          width: 360*sizeUnit,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 120*sizeUnit),
                              SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
                              SizedBox(
                                height: 40*sizeUnit,
                              ),
                              Text(
                                "아쉽게도 검색 결과가 없습니다.\n다시 시도해주세요.",
                                style: SheepsTextStyle.b2(context),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                              : true == bLoading
                                ? CupertinoActivityIndicator()
                                : ListView.builder(
                            controller: _scrollController3,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: GlobalProfile.searchWord.length,
                            itemBuilder: (BuildContext context, int index) {
                              return SheepsCommunityItem(
                                context: context,
                                community: GlobalProfile.searchWord[index],
                                index: index,
                                extendedController: extendedController,
                                isLike: searchWordCheck(GlobalProfile.loggedInUser.userID, index),
                                isMorePhoto: searchWordVisibleList[index],
                                tapPhotoFunc: () {
                                  setState(() {
                                    if (searchWordVisibleList[index] == false) {
                                      searchWordVisibleList[index] = true;
                                    } else {
                                      searchWordVisibleList[index] = false;
                                    }
                                  });
                                },
                                tapLikeFunc: () async{
                                  if(isCanTapLike){
                                    isCanTapLike = false;
                                    if (searchWordCheck(GlobalProfile.loggedInUser.userID,index) ==false) {
                                      var result = await ApiProvider().post('/CommunityPost/InsertLike',
                                          jsonEncode({"userID": GlobalProfile.loggedInUser.userID,
                                            // "userID": GlobalProfile .loggedInUser .userID,
                                            "postID": GlobalProfile.searchWord[index].id
                                          }));

                                      if(result != null){
                                        CommunityLike user = InsertLike.fromJson(result)?.item;

                                        if(user != null){
                                          GlobalProfile.searchWord[index].communityLike.add(user);

                                          for (int i = 0; i < GlobalProfile.popularCommunityList.length;i++) {
                                            if (GlobalProfile.popularCommunityList[ i].id == GlobalProfile.searchWord[index].id) {
                                              GlobalProfile.popularCommunityList[i].communityLike.add(user);
                                              break;
                                            }
                                          }
                                          for (int i = 0;i < GlobalProfile.newCommunityList.length; i++) {
                                            if (GlobalProfile.newCommunityList[i].id ==GlobalProfile.searchWord[index] .id) {
                                              GlobalProfile.newCommunityList[i].communityLike.add(user);
                                              break;
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode({
                                        "userID": GlobalProfile.loggedInUser.userID,
                                        "postID": GlobalProfile.newCommunityList[index].id
                                      }));

                                      int idx = -1;

                                      for (int i = 0; i < GlobalProfile.searchWord[index].communityLike.length;i++) {
                                        if (GlobalProfile.searchWord[index].communityLike[i].userID == GlobalProfile.loggedInUser.userID) {
                                          idx = i;
                                          break;
                                        }
                                      }

                                      if(idx != -1){
                                        GlobalProfile.searchWord[index].communityLike.removeAt(idx);

                                        int idx1 = -1;
                                        int idx2 = -1;

                                        for (int i = 0; i < GlobalProfile.popularCommunityList.length; i++) {
                                          if (GlobalProfile.popularCommunityList[i].id == GlobalProfile.searchWord[index].id) {
                                            idx1 =i;
                                            break;
                                          }
                                        }
                                        if (idx1 !=-1) {
                                          for (int i =0;i < GlobalProfile.popularCommunityList[idx1].communityLike.length;i++) {
                                            if ((GlobalProfile.popularCommunityList[idx1].communityLike[i].userID) ==GlobalProfile.loggedInUser.userID) {
                                              idx2 = i;
                                              break;
                                            }
                                          }
                                          if (idx2 != -1){
                                            GlobalProfile.popularCommunityList[idx1].communityLike.removeAt(idx2);
                                          }
                                        }

                                        idx1 = -1;
                                        idx2 = -1;

                                        for (int i = 0; i < GlobalProfile.newCommunityList.length; i++) {
                                          if (GlobalProfile.newCommunityList[i].id == GlobalProfile.searchWord[index].id) {
                                            idx1 = i;
                                            break;
                                          }
                                        }

                                        if (idx1 != -1) {
                                          for (int i = 0; i < GlobalProfile.newCommunityList[idx1].communityLike.length; i++) {
                                            if ((GlobalProfile.newCommunityList[idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                              idx2 =i;
                                              break;
                                            }
                                          }
                                          if (idx2 != -1){
                                            GlobalProfile.newCommunityList[idx1].communityLike.removeAt(idx2);
                                          }

                                        }
                                        idx1 = -1;
                                        idx2 = -1;
                                      }
                                    }
                                    setState(() {
                                      Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                        isCanTapLike = true;
                                      });
                                    });
                                  }
                                },
                              );
                            }),
                      ),
                    )
                  ],
                ),
                floatingActionButton: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context, // 기본 파라미터, SecondRoute로 전달
                        MaterialPageRoute(
                            builder: (context) => CommunityWrite(
                                topic: CurrentFilter)) // SecondRoute를 생성하여 적재
                    );
                  },
                  child: Container(
                    width: 100*sizeUnit,
                    height: 32*sizeUnit,
                    decoration: new BoxDecoration(
                      color: Color(0xffEFF9F2),
                      borderRadius: new BorderRadius.circular(8*sizeUnit),
                      boxShadow: [
                        new BoxShadow(
                          color: Color.fromRGBO(116, 125, 130, 0.2),
                          blurRadius: 4*sizeUnit,
                          offset: Offset(1*sizeUnit,1*sizeUnit),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          GreenPencilWriteIcon,
                          width: 16*sizeUnit,
                          height: 16*sizeUnit,
                        ),
                        SizedBox(width: 8*sizeUnit),
                        Text(
                          '글 쓰기',
                          style: SheepsTextStyle.b3(context),
                        )
                      ],
                    ),
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column buildNormalCommunity(
      BuildContext context,
      ProfileState profileState,
      String svgGreyMagnifyingGlass,
      String GreyMyPageButton) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60*sizeUnit,
          width: 360*sizeUnit,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                child: Container(
                    width: 296*sizeUnit,
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
                          width: 262*sizeUnit,
                          child: TextField(
                            onSubmitted: (val) {
                              bLoading = true;
                              Future.microtask(() async {
                                if (CurrentFilter == "전체") {
                                  GlobalProfile.searchWord.clear();
                                  List<dynamic> tmp = new List<dynamic>();
                                  tmp = await ApiProvider().post(
                                      '/CommunityPost/SearchWord',
                                      jsonEncode({
                                        "index":
                                        GlobalProfile.searchWord.length,
                                        "searchWord": val,
                                      }));

                                  for (int i = 0; i < tmp.length; i++) {
                                    Community community =
                                    Community.fromJson(tmp[i]);
                                    GlobalProfile.searchWord.add(community);
                                    await GlobalProfile.getFutureUserByUserID(
                                        community.userID);
                                  }
                                } else {
                                  GlobalProfile.searchWord.clear();
                                  List<dynamic> tmp = new List<dynamic>();
                                  tmp = await ApiProvider().post(
                                      '/CommunityPost/SearchCategoryWithWord',
                                      jsonEncode({
                                        "index":
                                        GlobalProfile.searchWord.length,
                                        "searchWord": val,
                                        "category": CurrentFilter,
                                      }));
                                  for (int i = 0; i < tmp.length; i++) {
                                    Community community =
                                    Community.fromJson(tmp[i]);
                                    GlobalProfile.searchWord.add(community);
                                  }
                                }
                              }).then((value) {
                                setState(() {
                                  bLoading = false;
                                });
                              });
                            },
                            textAlign: TextAlign.left,
                            controller: SearchCommunityController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '커뮤니티 검색',
                              hintStyle: SheepsTextStyle.info1(context),
                            ),
                            style: SheepsTextStyle.b3(context),
                          ),
                        ),
                      ],
                    )
                ),
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
                  GreyMyPageButton,
                  width: 28*sizeUnit,
                  height:28*sizeUnit,
                ),
              ),
              SizedBox(width:12*sizeUnit),
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
                    onTap: () async{
                      if (profileState.getNum() == 1) {
                        _scrollController3.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                        profileState.setNum(0);

                        var list;
                        if (profileState.getNum() == 0) {
                          list = Category;
                        } else {
                          list = Field;
                        }
                        CurrentFilter = list[0];

                        GlobalProfile.filteredCommunityList.clear();

                        List<dynamic> tmp = new List<dynamic>();
                        tmp = await ApiProvider().post(
                            "/CommunityPost/SearchCategory",
                            jsonEncode({
                              "category": CurrentFilter,
                              "index": 0,
                            }));
                        if (tmp.length != null) {
                          for (int i = 0; i < tmp.length; i++) {
                            Community community = Community.fromJson(tmp[i]);
                            GlobalProfile.filteredCommunityList.add(community);
                            await GlobalProfile.getFutureUserByUserID(
                                community.userID);
                          }
                        }
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: 160*sizeUnit,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            '일반',
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
                      width: 36*sizeUnit,
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
                    onTap: () async{
                      if (profileState.getNum() == 0) {
                        _scrollController3.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                        profileState.setNum(1);

                        var list;
                        if (profileState.getNum() == 0) {
                          list = Category;
                        } else {
                          list = Field;
                        }
                        CurrentFilter = list[0];

                        GlobalProfile.filteredCommunityList.clear();

                        List<dynamic> tmp = new List<dynamic>();
                        tmp = await ApiProvider().post(
                            "/CommunityPost/SearchCategory",
                            jsonEncode({
                              "category": CurrentFilter,
                              "index": 0,
                            }));
                        if (tmp.length != null) {
                          for (int i = 0; i < tmp.length; i++) {
                            Community community = Community.fromJson(tmp[i]);
                            GlobalProfile.filteredCommunityList.add(community);
                            await GlobalProfile.getFutureUserByUserID(
                                community.userID);
                          }
                        }
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: 160*sizeUnit,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            '직군',
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
                      width: 36*sizeUnit,
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
        SizedBox(height: 12*sizeUnit),
        buildFilterForCommunity(profileState),
      ],
    );
  }

  Container buildFilterForCommunity(
      ProfileState profileState) {
    List<String> list;
    if (profileState.getNum() == 0) {
      list = Category;
    } else {
      list = Field;
    }

    return Container(
      height: 28*sizeUnit,
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView.builder(
            primary: true,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index){
              return   GestureDetector(
                  onTap: () async {
                    if (SearchCommunityController.text == null || SearchCommunityController.text == "") {
                      CurrentFilter = list[index];

                      GlobalProfile.filteredCommunityList.clear();

                      List<dynamic> tmp = new List<dynamic>();
                      tmp = await ApiProvider().post(
                          "/CommunityPost/SearchCategory",
                          jsonEncode({
                            "category": CurrentFilter,
                            "index": 0,
                          }));
                      if (tmp.length != null) {
                        for (int i = 0; i < tmp.length; i++) {
                          Community community = Community.fromJson(tmp[i]);
                          GlobalProfile.filteredCommunityList.add(community);
                          await GlobalProfile.getFutureUserByUserID(
                              community.userID);
                        }
                      }
                    } else {
                      if (SearchCommunityController.text != "") {
                        CurrentFilter = list[index];
                        if (index == 0) {
                          GlobalProfile.searchWord.clear();
                          List<dynamic> tmp = new List<dynamic>();
                          tmp = await ApiProvider().post(
                              '/CommunityPost/SearchWord',
                              jsonEncode({
                                "index": GlobalProfile.searchWord.length,
                                "searchWord": SearchCommunityController.text,
                              }));

                          for (int i = 0; i < tmp.length; i++) {
                            Community community = Community.fromJson(tmp[i]);
                            GlobalProfile.searchWord.add(community);
                            await GlobalProfile.getFutureUserByUserID(
                                community.userID);
                          }
                        } else {
                          GlobalProfile.searchWord.clear();
                          List<dynamic> tmp = new List<dynamic>();
                          tmp = await ApiProvider().post(
                              '/CommunityPost/SearchCategoryWithWord',
                              jsonEncode({
                                "index": GlobalProfile.searchWord.length,
                                "searchWord": SearchCommunityController.text,
                                "category": CurrentFilter,
                              }));
                          for (int i = 0; i < tmp.length; i++) {
                            Community community = Community.fromJson(tmp[i]);
                            GlobalProfile.searchWord.add(community);
                          }
                        }
                      } else {
                        CurrentFilter = list[index];
                      }
                    }
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      index == 0?SizedBox(width:8*sizeUnit):Container(),
                      SizedBox(width:4*sizeUnit),
                      Container(
                        height: 28*sizeUnit,
                        padding: EdgeInsets.symmetric(horizontal: 10*sizeUnit),
                        decoration: BoxDecoration(
                          border: Border.all(color: hexToColor("#61C680")),
                          borderRadius: new BorderRadius.circular(4*sizeUnit),
                          color: list[index] == CurrentFilter
                              ? hexToColor("#61C680")
                              : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${list[index]}',
                              style: TextStyle(
                                color: list[index] == CurrentFilter
                                    ? Colors.white
                                    : hexToColor("#61C680"),
                                fontSize: 12*sizeUnit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
            }

        ),
      ),
    );
  }
}
