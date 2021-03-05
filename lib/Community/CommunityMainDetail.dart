import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/dashboard/MyHomePage.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/Community.dart';
import 'package:sheeps_app/Setting/PageReport.dart';

class CommunityMainDetail extends StatefulWidget {
  Community a_community;


  CommunityMainDetail(Community community) {
    a_community = community;
  }

  @override
  _CommunityMainDetailState createState() => _CommunityMainDetailState();
}

class _CommunityMainDetailState extends State<CommunityMainDetail> with SingleTickerProviderStateMixin{
  final String grey3dot = 'assets/images/Community/Grey3dot.svg';
  final String grey2dot = 'assets/images/Community/Grey2dot.svg';
  final String GreyThumbIcon = 'assets/images/Public/GreyThumbIcon.svg';
  final String GreySpeechBubble = 'assets/images/Public/GreySpeechBubble.svg';
  final String sheepsGrayImageAndWriteLogo = 'assets/images/Public/sheepsGrayImageAndWriteLogo.svg';
  final String GreenThumb = 'assets/images/Public/GreenThumb.svg';

  double sizeUnit = 1;
  bool replyReplyFlag = false;
  int replyReplyInt = -1;
  bool keyboardState = false;
  Community _community;
  // GlobalKey<ScaffoldState> _key;
  GlobalKey<RefreshIndicatorState> refreshKey;
  AnimationController extendedController;
  FocusNode myFocusNode;//대댓 포커스
  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;

  Widget getImgWidget(){
    return Container(
      padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
      height: 300*sizeUnit,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
          cacheExtent: 3,
          reverse: false,
          shrinkWrap: true,
          itemCount: urlList.length,
          itemBuilder: (context, index){
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 300*sizeUnit,
                    height: 300*sizeUnit,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(8*sizeUnit),
                      child: FittedBox(
                        child: getExtendedImage(urlList[index], 0, extendedController),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  List<String> urlList = new List<String>();

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();//대댓 포커스
    _community = widget.a_community;
    keyboardState = KeyboardVisibility.isVisible;
    KeyboardVisibility.onChange.listen((bool visible) {
      keyboardState = visible;
      if (keyboardState == false) {
        if(replyReplyFlag == true){
          replyReplyFlag = false;
          communityReplyController.text = "";
        }
      }
    });

    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        lowerBound: 0.0,
        upperBound: 1.0);
    if(_community.imageUrl1 != null) urlList.add(_community.imageUrl1);
    if(_community.imageUrl2 != null) urlList.add(_community.imageUrl2);
    if(_community.imageUrl3 != null) urlList.add(_community.imageUrl3);
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    extendedController.dispose();
    super.dispose();
  }

  final communityReplyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;



    return RefreshIndicator(
      backgroundColor: hexToColor("#61C680"),
      color: Colors.white,
      key: refreshKey,
      onRefresh: () async {
        var tmp = await ApiProvider().post(
            '/CommunityPost/PostSelect',
            jsonEncode({
              "id":
              _community.id,
            }));

        if (tmp == null) return;

        GlobalProfile.communityReply = new List<CommunityReply>();
        for (int i = 0; i <tmp.length; i++) {
          Map<String, dynamic> data = tmp[i];
          CommunityReply tmpReply = CommunityReply.fromJson(data);
          GlobalProfile.communityReply.add(tmpReply);
        }
        setState(() {});
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: KeyboardDismissOnTap(
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Scaffold(
                // key: _key,
                backgroundColor: Colors.white,
                appBar: SheepsAppBar(context,'',
                  actions: [
                    GestureDetector(
                      onTap: () {
                        _settingModalBottomSheet(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 12*sizeUnit),
                        child: SvgPicture.asset(
                          grey3dot,
                          width: 28*sizeUnit,
                          height: 28*sizeUnit,
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8*sizeUnit),
                            Row(
                              children: [
                                SizedBox(width: 12*sizeUnit),
                                Container(
                                  height: 18*sizeUnit,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit, vertical: 1.5*sizeUnit),
                                    child: Text(
                                      _community.category,
                                      textAlign: TextAlign.center,
                                      style: SheepsTextStyle.cat1(context),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: new BorderRadius.circular(4*sizeUnit),
                                    color: hexToColor("#E5E5E5"),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8*sizeUnit),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 12*sizeUnit),
                              child: Text(
                                _community.title,
                                style: SheepsTextStyle.h3(context),
                              ),
                            ),
                            SizedBox(height: 12*sizeUnit),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 12*sizeUnit),
                              child: Row(
                                children: [
                                  Container(
                                    child: Text(
                                      _community.category=="비밀"?"익명":"${ GlobalProfile.getUserByUserID(_community.userID).name}" ,
                                      style: SheepsTextStyle.b3(context).copyWith(color:  _community.category=="비밀"?hexToColor("#61C680"):Color(0xFF222222)),
                                    ),
                                  ),
                                  SizedBox(width: 8*sizeUnit),
                                  Text(
                                    timeCheck(_community.updatedAt),
                                    style: SheepsTextStyle.b3(context).copyWith(color: hexToColor("#BEBEBE")),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20*sizeUnit),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                              child: Container(
                                child: Text(
                                  _community.contents,
                                  style: SheepsTextStyle.b4(context),
                                ),
                              ),
                            ),
                            SizedBox(height: 12*sizeUnit),
                            urlList.length > 0
                            ? getImgWidget()
                            : SizedBox.shrink(),
                            SizedBox(height: 12*sizeUnit),
                            Container(
                              height: 40*sizeUnit,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () async{
                                        if(isCanTapLike){
                                          isCanTapLike = false;
                                          if (LikeCheckInDetail(GlobalProfile.loggedInUser.userID) == false) {
                                            var result = await ApiProvider().post(
                                                '/CommunityPost/InsertLike',
                                                jsonEncode({
                                                  "userID":GlobalProfile.loggedInUser.userID,
                                                  // "userID": GlobalProfile .loggedInUser .userID,
                                                  "postID": _community.id
                                                }));

                                            if(result != null){
                                              CommunityLike tmpLike =InsertLike.fromJson(result).item;


                                              for(int i = 0; i< GlobalProfile.popularCommunityList .length;i++){

                                                if(GlobalProfile.popularCommunityList [i].id == _community.id){
                                                  GlobalProfile.popularCommunityList [i].communityLike.add(tmpLike);

                                                  break;
                                                }
                                              }


                                              for(int i = 0; i< GlobalProfile.postedList .length;i++){

                                                if(GlobalProfile.postedList [i].id == _community.id){
                                                  GlobalProfile.postedList[i].communityLike.add(tmpLike);

                                                  break;
                                                }
                                              }


                                              for(int i = 0; i< GlobalProfile.newCommunityList.length;i++){
                                                if(GlobalProfile.newCommunityList[i].id == _community.id){
                                                  GlobalProfile.newCommunityList[i].communityLike.add(tmpLike);
                                                  break;
                                                }
                                              }


                                              for(int i = 0; i< GlobalProfile.searchWord.length;i++){
                                                if(GlobalProfile.searchWord[i].id  == _community.id){
                                                  GlobalProfile.searchWord[i].communityLike.add(tmpLike);
                                                  break;
                                                }
                                              }


                                              for(int i = 0; i< GlobalProfile.filteredCommunityList.length;i++){
                                                if(GlobalProfile.filteredCommunityList[i].id == _community.id){
                                                  GlobalProfile.filteredCommunityList[i].communityLike.add(tmpLike);
                                                  break;
                                                }
                                              }
                                            }
                                          }
                                          else {
                                            await ApiProvider().post(
                                                '/CommunityPost/InsertLike',
                                                jsonEncode({
                                                  "userID": GlobalProfile
                                                      .loggedInUser.userID,
                                                  "postID": _community.id
                                                }));

                                            int idx1 = -1;
                                            int idx2 = -1;
                                            for (int i = 0; i < _community.communityLike.length; i++) {
                                              if (( _community.communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                idx2 = i;
                                                break;
                                              }
                                            }
                                            _community.communityLike.removeAt(idx2);
                                            idx1 =-1;
                                            idx2 = -1;


                                            for(int i = 0; i< GlobalProfile.popularCommunityList .length;i++){
                                              if(GlobalProfile.popularCommunityList [i].id == _community.id){
                                                idx1 = i;
                                                break;
                                              }
                                            }
                                            if(idx1 != -1) {
                                              for (int i = 0; i < GlobalProfile.popularCommunityList [idx1].communityLike.length; i++) {
                                                if ((GlobalProfile .popularCommunityList [idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                  idx2 = i;
                                                  break;
                                                }
                                              }
                                              if (idx2 != -1) GlobalProfile .popularCommunityList [idx1].communityLike.removeAt(idx2);
                                            }
                                            idx1 =-1;
                                            idx2 = -1;

                                            for(int i = 0; i< GlobalProfile. newCommunityList .length;i++){
                                              if(GlobalProfile. newCommunityList [i].id == _community.id){
                                                idx1 = i;
                                                break;
                                              }
                                            }
                                            if(idx1 != -1){
                                              for(int i =0 ;i<GlobalProfile. newCommunityList [idx1].communityLike.length;i++){
                                                if (( GlobalProfile. newCommunityList [idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                  idx2 = i;
                                                  break;
                                                }
                                              }
                                              if(idx2 != -1) GlobalProfile. newCommunityList [idx1].communityLike.removeAt(idx2);
                                            }
                                            idx1 =-1;
                                            idx2 = -1;




                                            for(int i = 0; i< GlobalProfile. searchWord .length;i++){
                                              if(GlobalProfile. searchWord [i].id == _community.id){
                                                idx1 = i;
                                                break;
                                              }
                                            }
                                            if(idx1 != -1){
                                              for(int i =0 ;i<GlobalProfile. searchWord [idx1].communityLike.length;i++){
                                                if (( GlobalProfile. searchWord [idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                  idx2 = i;
                                                  break;
                                                }
                                              }
                                              if(idx2 != -1) GlobalProfile. searchWord [idx1].communityLike.removeAt(idx2);
                                            }
                                            idx1 =-1;
                                            idx2 = -1;
                                            for(int i = 0; i< GlobalProfile.filteredCommunityList.length;i++){
                                              if(GlobalProfile.filteredCommunityList[i].id == _community.id){
                                                idx1 = i;
                                                break;
                                              }
                                            }
                                            if(idx1 != -1){
                                              for(int i =0 ;i<GlobalProfile.filteredCommunityList[idx1].communityLike.length;i++){
                                                if (( GlobalProfile.filteredCommunityList[idx1].communityLike[i].userID) == GlobalProfile.loggedInUser.userID) {
                                                  idx2 = i;
                                                  break;
                                                }
                                              }
                                              if(idx2 != -1) GlobalProfile.filteredCommunityList[idx1].communityLike.removeAt(idx2);
                                            }
                                            idx1 =-1;
                                            idx2 = -1;
                                          }
                                          setState(() {
                                            Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                              isCanTapLike = true;
                                            });
                                          });
                                        }
                                      },
                                      child: Container(
                                        color: Colors.white,
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 30*sizeUnit,
                                              width: 30*sizeUnit,
                                              child: Center(
                                                child: Container(
                                                  child: SvgPicture.asset(
                                                    GreyThumbIcon,
                                                    width: 20*sizeUnit,
                                                    height: 20*sizeUnit,
                                                    color: LikeCheckInDetail(GlobalProfile.loggedInUser.userID)? hexToColor("#61C680") : Color(0xff888888),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6*sizeUnit),
                                            Text(
                                              ((_community.communityLike.length) >99)
                                                  ? "99+" : '${_community.communityLike.length}',
                                              style: SheepsTextStyle.b4(context).copyWith(color: LikeCheckInDetail(GlobalProfile.loggedInUser.userID)? hexToColor("#61C680"): Color(0xff888888)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        GreySpeechBubble,
                                        width: 20*sizeUnit,
                                        height: 20*sizeUnit,
                                      ),
                                      SizedBox(width: 12*sizeUnit),
                                      Text(
                                        (_community.communityReply.length) >
                                            99
                                            ? "99+"
                                            : '${_community.communityReply.length}',
                                        style: SheepsTextStyle.b4(context),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        svgShareBox,
                                        width: 20*sizeUnit,
                                        height: 20*sizeUnit,
                                      ),
                                      SizedBox(width: 12*sizeUnit),
                                      Text(
                                        '공유',
                                        style: SheepsTextStyle.b4(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16*sizeUnit),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) {
                                      return Scaffold(
                                        body: MyHomePage(
                                            url: 'https://sheeps.kr'),
                                      ); // ... to here.
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                height: 80*sizeUnit,
                                decoration: BoxDecoration(
                                  color: hexToColor("#61C680"),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 12*sizeUnit),
                                          Text(
                                            '쉽스와 함께하는 스타트업',
                                            style: SheepsTextStyle.h3(context).copyWith(color: Colors.white),
                                          ),
                                          SizedBox(height: 4*sizeUnit),
                                          Text(
                                            '쉽스 사용법 강좌 바로가기',
                                            style: SheepsTextStyle.s3(context).copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: SvgPicture.asset(
                                          sheepsGrayImageAndWriteLogo,
                                          width: 52*sizeUnit,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: GlobalProfile.communityReply.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit, vertical: 8*sizeUnit),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if(_community.category=="비밀"||GlobalProfile.communityReply[index].userID==GlobalProfile.loggedInUser.userID) return;
                                                      UserData _user = GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].userID);

                                                      Navigator.push(
                                                          context,
                                                          PageRouteBuilder(transitionDuration:Duration(milliseconds:300),
                                                              pageBuilder: (_,__,___) =>
                                                                  DetailProfile(index: index, user: _user)));
                                                    },
                                                    child:
                                                    GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].userID).profileUrlList[0] == 'BasicImage' ?
                                                     Container(
                                                       width: 56*sizeUnit,
                                                       height: 56*sizeUnit,
                                                       child:    _community.category=="비밀"?
                                                       Random().nextInt(3)==0?SvgPicture.asset('assets/images/Public/1.svg'):Random().nextInt(3)==1?SvgPicture.asset('assets/images/Public/2.svg'):SvgPicture.asset('assets/images/Public/3.svg')
                                                           : SvgPicture.asset(
                                                              svgPersonalProfileBasicImage ,
                                                              width: 56*sizeUnit,
                                                              height: 56*sizeUnit,
                                                           )
                                                        )
                                                      : Container(
                                                          width: 56*sizeUnit,
                                                          height: 56*sizeUnit,
                                                          decoration: BoxDecoration(
                                                            boxShadow: [
                                                              new BoxShadow(
                                                                color:_community.category=="비밀"?Color.fromRGBO(0, 0, 0, 0): Color.fromRGBO( 166, 125, 130, 0.2),
                                                                blurRadius: 4,
                                                                ),
                                                            ],
                                                        ),
                                                        child:     _community.category=="비밀"?
                                                        Random().nextInt(3)==0?SvgPicture.asset('assets/images/Public/1.svg'):Random().nextInt(3)==1?SvgPicture.asset('assets/images/Public/2.svg'):SvgPicture.asset('assets/images/Public/3.svg')
                                                            :
                                                        ClipRRect(
                                                        borderRadius: new BorderRadius.circular(8*sizeUnit),
                                                        child: FittedBox(
                                                            child: getExtendedImage(GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].userID).profileUrlList[0], 120, extendedController),
                                                          //cancelToken: cancellationToken,
                                                        )
                                                            //  fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8*sizeUnit),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          _community.category=="비밀"?"익명":  "${ GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].userID).name}",
                                                          style: SheepsTextStyle.b3(context).copyWith(color: (_community.category=="비밀"&&_community.userID==GlobalProfile.communityReply[index].userID)?hexToColor("#61C680"):Color(0xFF222222)),
                                                        ),
                                                        SizedBox(height: 4*sizeUnit),
                                                        Container(
                                                          width: 272*sizeUnit,
                                                          child: Text(GlobalProfile.communityReply[index].contents,
                                                            style: SheepsTextStyle.b4(context),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8*sizeUnit),
                                                        Container(
                                                          width: 272*sizeUnit,
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                timeCheck(GlobalProfile.communityReply[index].updatedAt),
                                                                style: SheepsTextStyle.bWriteDate(context),
                                                              ),
                                                              SizedBox(width: 20*sizeUnit),
                                                              Material(
                                                                color: Colors.transparent,
                                                                child: InkWell(
                                                                  splashColor: Colors.transparent,
                                                                  onTap: () async {
                                                                    if(isCanTapLike){
                                                                      isCanTapLike = false;
                                                                      if (insertReplyCheck(
                                                                          GlobalProfile
                                                                              .loggedInUser
                                                                              .userID,
                                                                          index) ==
                                                                          false) {
                                                                        var result =
                                                                        await ApiProvider().post(
                                                                            '/CommunityPost/InsertReplyLike',
                                                                            jsonEncode({
                                                                              "userID":
                                                                              GlobalProfile.loggedInUser.userID,
                                                                              "replyID":
                                                                              GlobalProfile.communityReply[index].id
                                                                            }));

                                                                        CommunityReplyLike
                                                                        user =
                                                                            InsertReplyLike.fromJson(
                                                                                result)
                                                                                .item;
                                                                        GlobalProfile
                                                                            .communityReply[
                                                                        index]
                                                                            .communityReplyLike
                                                                            .add(
                                                                            user);

                                                                      } else {
                                                                        await ApiProvider().post(
                                                                            '/CommunityPost/InsertReplyLike',
                                                                            jsonEncode({
                                                                              "userID":
                                                                              GlobalProfile.loggedInUser.userID,
                                                                              "replyID": GlobalProfile
                                                                                  .communityReply[index]
                                                                                  .id
                                                                            }));

                                                                        int idx;

                                                                        for (int i =
                                                                        0;
                                                                        i <
                                                                            GlobalProfile
                                                                                .communityReply[index]
                                                                                .communityReplyLike
                                                                                .length;
                                                                        i++) {
                                                                          if (GlobalProfile
                                                                              .communityReply[
                                                                          index]
                                                                              .communityReplyLike[
                                                                          i]
                                                                              .userID ==
                                                                              GlobalProfile
                                                                                  .loggedInUser
                                                                                  .userID) {
                                                                            idx = i;
                                                                            break;
                                                                          }
                                                                        }

                                                                        GlobalProfile
                                                                            .communityReply[
                                                                        index]
                                                                            .communityReplyLike
                                                                            .removeAt(
                                                                            idx);
                                                                      }
                                                                      setState(() {
                                                                        Future.delayed(Duration(milliseconds: tapLikeDelayMilliseconds),(){
                                                                          isCanTapLike = true;
                                                                        });
                                                                      });
                                                                    }
                                                                  },
                                                                   child: Container(
                                                                     height: 28*sizeUnit,
                                                                     color: Colors.white,
                                                                     child: Row(
                                                                       children: [
                                                                         SvgPicture
                                                                             .asset(
                                                                           GreenThumb,
                                                                           width: 12*sizeUnit,
                                                                           height: 12*sizeUnit,
                                                                           color: insertReplyCheck(
                                                                                   GlobalProfile
                                                                                       .loggedInUser.userID,
                                                                                   index)
                                                                               ? hexToColor(
                                                                                   "#61C680")
                                                                               : Color(
                                                                                   0xff888888),
                                                                         ),
                                                                         SizedBox(width: 4*sizeUnit),
                                                                         Text(
                                                                         GlobalProfile.communityReply[index].communityReplyLike.length >
                                                                               99
                                                                           ? '99+'
                                                                           : '${GlobalProfile.communityReply[index].communityReplyLike.length}',
                                                                           style: insertReplyCheck(GlobalProfile.loggedInUser.userID, index)
                                                                             ? SheepsTextStyle.s2(context)
                                                                             : SheepsTextStyle.s3(context),
                                                                         ),
                                                                       ],
                                                                     ),
                                                                   ),
                                                                 ),
                                                              ),
                                                              SizedBox(width: 8*sizeUnit),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    showSheepsDialog(
                                                                      context: context,
                                                                      title: "대댓글 남기기",
                                                                      isLogo: false,
                                                                      description: "대댓글을 작성하시겠습니까?",
                                                                      okText: '작성하기',
                                                                      okFunc: () {
                                                                        replyReplyInt = GlobalProfile.communityReply[index].id;
                                                                        replyReplyFlag = true;
                                                                        setState(() {

                                                                        });
                                                                        Navigator.pop(context);
                                                                        myFocusNode.requestFocus();//대댓 포커스
                                                                      },
                                                                      cancelText: "좀 더 생각해볼게요",
                                                                      cancelFunc: () {
                                                                        replyReplyFlag = false;
                                                                        setState(() {

                                                                        });
                                                                        Navigator.pop(context);
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    height: 28*sizeUnit,
                                                                    color: Colors.white,
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture.asset(
                                                                          GreySpeechBubble,
                                                                          width: 12*sizeUnit,
                                                                          height: 12*sizeUnit,
                                                                        ),
                                                                        SizedBox(width: 4*sizeUnit),
                                                                        Text(
                                                                          '대댓글',
                                                                          style:SheepsTextStyle.s3(context)
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),

                                                              Spacer(),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _settingModalBottomSheet(
                                                                      context);
                                                                },
                                                                child: SvgPicture.asset(
                                                                  grey3dot,
                                                                  width: 28*sizeUnit,
                                                                  height: 28*sizeUnit,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 1,
                                            color: Color(0xffF8F8F8),
                                          ),
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: GlobalProfile
                                                .communityReply[index]
                                                .communityReplyReply
                                                .length,
                                            itemBuilder: (BuildContext context, int index2) =>
                                                Container(
                                                  color: Color(0xffF8F8F8),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 32*sizeUnit, right: 12*sizeUnit, top: 8*sizeUnit, bottom: 8*sizeUnit),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: (){
                                                            if(_community.category=="비밀"||GlobalProfile.communityReply[index].userID==GlobalProfile.loggedInUser.userID) return;
                                                            UserData _user = GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].communityReplyReply[index2].userID);
                                                            Navigator.push(
                                                                context,
                                                                PageRouteBuilder(transitionDuration:Duration(milliseconds:300),
                                                                    pageBuilder: (_,__,___) =>
                                                                        DetailProfile(index: index, user: _user)));
                                                          },
                                                          child:    GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].communityReplyReply[index2].userID).profileUrlList[0] == 'BasicImage' ?
                                                          Container(
                                                              width: 56*sizeUnit,
                                                              height: 56*sizeUnit,
                                                              child:   _community.category=="비밀"?
                                                              Random().nextInt(3)==0?SvgPicture.asset('assets/images/Public/1.svg'):Random().nextInt(3)==1?SvgPicture.asset('assets/images/Public/2.svg'):SvgPicture.asset('assets/images/Public/3.svg')
                                                                  :SvgPicture.asset(
                                                                  svgPersonalProfileBasicImage ,
                                                                  width: 56*sizeUnit,
                                                                  height: 56*sizeUnit,
                                                              )
                                                          )
                                                              : Container(
                                                            width: 56*sizeUnit,
                                                            height: 56*sizeUnit,
                                                            decoration: BoxDecoration(
                                                              boxShadow: [
                                                                new BoxShadow(
                                                                  color:_community.category=="비밀"?Color.fromRGBO(0, 0, 0, 0): Color.fromRGBO( 166, 125, 130, 0.2),
                                                                  blurRadius: 4,
                                                                ),
                                                              ],
                                                            ),
                                                            child:
                                                            _community.category=="비밀"?
                                                            Random().nextInt(3)==0?SvgPicture.asset('assets/images/Public/1.svg'):Random().nextInt(3)==1?SvgPicture.asset('assets/images/Public/2.svg'):SvgPicture.asset('assets/images/Public/3.svg')
                                                                :
                                                            ClipRRect(
                                                                borderRadius: new BorderRadius.circular(8*sizeUnit),
                                                                child: FittedBox(
                                                                  child: getExtendedImage(GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].communityReplyReply[index2].userID).profileUrlList[0], 120, extendedController),
                                                                  //cancelToken: cancellationToken,
                                                                )
                                                              //  fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8*sizeUnit),
                                                        Column(
                                                          crossAxisAlignment:CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              _community.category=="비밀"?"익명":GlobalProfile.getUserByUserID(GlobalProfile.communityReply[index].communityReplyReply[index2].userID).name,
                                                              style: SheepsTextStyle.b3(context).copyWith(
                                                                  color: _community.category=="비밀" && _community.userID==GlobalProfile.communityReply[index].communityReplyReply[index2].userID
                                                                      ? hexToColor("#61C680")
                                                                      : Color(0xFF222222)
                                                              ),
                                                            ),
                                                            SizedBox(height: 4*sizeUnit),
                                                            Container(
                                                              width: 252*sizeUnit,
                                                              child: Text(
                                                                GlobalProfile.communityReply[index].communityReplyReply[index2].contents,
                                                                style: SheepsTextStyle.b4(context),
                                                              ),
                                                            ),
                                                            SizedBox(height: 8*sizeUnit),
                                                            Container(
                                                              width: 252*sizeUnit,
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    timeCheck(GlobalProfile
                                                                        .communityReply[index]
                                                                        .communityReplyReply[index2]
                                                                        .updatedAt),
                                                                    style: SheepsTextStyle.bWriteDate(context),
                                                                  ),
                                                                  Spacer(),
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () {
                                                                      _settingModalBottomSheet(
                                                                          context);
                                                                    },
                                                                    child: SvgPicture.asset(
                                                                      grey2dot,
                                                                      width: 28*sizeUnit,
                                                                      height: 28*sizeUnit,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(height: 40*sizeUnit),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 360*sizeUnit ,height: 1, decoration: BoxDecoration( color: hexToColor('#eeeeee'))),
                    Container(
                      width: 360*sizeUnit,
                      height: 60*sizeUnit,
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(width: 12*sizeUnit),
                          Container(
                              width: 336*sizeUnit,
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
                                      focusNode: myFocusNode,
                                      textAlign: TextAlign.left,
                                      textAlignVertical: TextAlignVertical.top,
                                      controller: communityReplyController,
                                      decoration: InputDecoration(
                                        hintText: replyReplyFlag == true
                                            ? '대댓글 내용을 입력해주세요'
                                            : '댓글 내용을 입력해주세요',
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
                                  InkWell(
                                    onTap: () async {
                                      if (communityReplyController.text != "") {
                                        if (replyReplyFlag == false) {
                                          var result = await ApiProvider().post(
                                              '/CommunityPost/InsertReply',
                                              jsonEncode({
                                                "userID": GlobalProfile
                                                    .loggedInUser.userID,
                                                "postID": _community
                                                    .id,
                                                "contents":
                                                communityReplyController.text,
                                              }));

                                          for(int i =0;i<GlobalProfile.newCommunityList.length;i++){
                                            if(GlobalProfile.newCommunityList[i].id == CommunityReplyLight.fromJson(result).postID){
                                              GlobalProfile.newCommunityList[i].communityReply.add( CommunityReplyLight.fromJson(result));
                                            }
                                          }
                                          for(int i =0;i<GlobalProfile.popularCommunityList.length;i++){
                                            if(GlobalProfile.popularCommunityList[i].id == CommunityReplyLight.fromJson(result).postID){
                                              GlobalProfile.popularCommunityList[i].communityReply.add( CommunityReplyLight.fromJson(result));
                                            }
                                          }
                                          for(int i =0;i<GlobalProfile. filteredCommunityList.length;i++){
                                            if(GlobalProfile. filteredCommunityList[i].id == CommunityReplyLight.fromJson(result).postID){
                                              GlobalProfile. filteredCommunityList[i].communityReply.add( CommunityReplyLight.fromJson(result));
                                            }
                                          }
                                          for(int i =0;i<GlobalProfile.searchWord.length;i++){
                                            if(GlobalProfile.searchWord[i].id == CommunityReplyLight.fromJson(result).postID){
                                              GlobalProfile.searchWord[i].communityReply.add( CommunityReplyLight.fromJson(result));
                                            }
                                          }
                                          FocusManager.instance.primaryFocus.unfocus();
                                          SystemChannels.textInput.invokeMethod('TextInput.hide');

                                          setState(() {});
                                        }
                                        else if (replyReplyFlag == true) {
                                          await ApiProvider().post(
                                              '/CommunityPost/InsertReplyReply',
                                              jsonEncode({
                                                "userID": GlobalProfile
                                                    .loggedInUser.userID,
                                                "replyID": replyReplyInt,
                                                "contents":
                                                communityReplyController.text,
                                              }));
                                        }
                                        communityReplyController.clear();
                                        var tmp = await ApiProvider().post(
                                            '/CommunityPost/PostSelect',
                                            jsonEncode({
                                              "id": _community.id,
                                            }));
                                        if (tmp ==null) return;
                                        GlobalProfile.communityReply = new List<CommunityReply>();
                                        for (int i = 0;i <tmp.length;i++) {
                                          Map<String, dynamic> data = tmp[i];
                                          CommunityReply tmpReply =CommunityReply.fromJson(data);
                                          GlobalProfile.communityReply .add(tmpReply);
                                        }
                                        replyReplyFlag = false;
                                        FocusManager.instance.primaryFocus.unfocus();
                                        SystemChannels.textInput.invokeMethod('TextInput.hide');

                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(4*sizeUnit),
                                      width: 24*sizeUnit,
                                      height: 24*sizeUnit,
                                      decoration: BoxDecoration(
                                        color: communityReplyController.text.length > 0
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
                                  )
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  bool LikeCheckInDetail(int userID) {
    bool check = false;
    for (int i = 0;
    i <_community.communityLike.length;
    i++) {
      if (_community.communityLike[i].userID == userID) {
        check = true;
        break;
      }
    }
    return check;
  }

  bool filterLikeCheck(int userID) {
    bool check = false;
    for (int i = 0;
    i <_community.communityLike.length;
    i++) {
      if (_community.communityLike[i].userID == userID) {
        check = true;
        break;
      }
    }
    return check;
  }
  void _settingModalBottomSheet(context) {

    bool isMe = widget.a_community.userID == GlobalProfile.loggedInUser.userID;
    int index = isMe ? 3 : 1;

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
            height: 48 * index * sizeUnit + 40 * sizeUnit,
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
                              classification: 'Community',
                              reportedID: _community.id,
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
                isMe ? GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                    height: 48 * sizeUnit,
                    width: 360 * sizeUnit,
                    child: Center(
                      child: Text(
                        '수정하기',
                        style: SheepsTextStyle.b1(context),
                      ),
                    ),
                  ),
                ) : SizedBox.shrink(),

                isMe ? GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                    height: 48 * sizeUnit,
                    width: 360 * sizeUnit,
                    child: Center(
                      child: Text(
                        '삭제하기',
                        style: SheepsTextStyle.b1(context),
                      ),
                    ),
                  ),
                ) : SizedBox.shrink(),
              ],
            ),
          );
        });
  }
}
class UrlLauncher{
  void launchURL(url) async{
    if(await canLaunch(url)){
      await launch(url);
    }
    else{
      throw 'Could not launch $url';
    }
  }
}

