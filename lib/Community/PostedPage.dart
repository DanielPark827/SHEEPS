import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/Community/CommunityListItem.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostedPage extends StatefulWidget {
  List<Community> _communityList;
  String _title;

  PostedPage(List<Community> community, String title) {
    _communityList = community;
    _title = title;
  }
  @override
  _PostedPageState createState() => _PostedPageState();
}

class _PostedPageState extends State<PostedPage> with SingleTickerProviderStateMixin  {
  double sizeUnit = 1;
  ScrollController _scrollController = ScrollController();
  AnimationController extendedController;
  List<bool> visibleList = [];
  bool isCanTapLike = true;
  int tapLikeDelayMilliseconds = 500;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    extendedController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
        lowerBound: 0.0,
        upperBound: 1.0);
  }
  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    var tmp = false;
    for (int i = 0; i < widget._communityList.length; i++) {
      visibleList.add(tmp);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SheepsAppBar(context,widget._title),
      body: widget._communityList.length > 0
        ? ListView.separated(
            separatorBuilder: (context, index) => SizedBox.shrink(),
            controller: _scrollController,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: widget._communityList.length,
            itemBuilder: (BuildContext context, int index) {
              return SheepsCommunityItem(
                context: context,
                community: widget._communityList[index],
                index: index,
                extendedController: extendedController,
                isMorePhoto: visibleList[index],
                tapPhotoFunc: () {
                  setState(() {
                    if (visibleList[
                    index] ==
                        false) {
                      visibleList[
                      index] = true;
                    } else {
                      visibleList[
                      index] = false;
                    }
                  });
                },
                isLike: insertCheckFor( GlobalProfile .loggedInUser.userID, index),
                tapLikeFunc: () async {
                  if(isCanTapLike){
                    isCanTapLike = false;
                    if (insertCheckFor( GlobalProfile .loggedInUser.userID, index) == false) {
                      var result = await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode(
                          {
                            "userID":GlobalProfile.loggedInUser.userID,
                            // "userID": GlobalProfile .loggedInUser .userID,
                            "postID": widget._communityList[index].id
                          }
                      ));

                      if(result != null){
                        CommunityLike user = InsertLike.fromJson(result)?.item;
                        widget._communityList[index].communityLike.add(user);
                        for(int i = 0; i< GlobalProfile.popularCommunityList.length;i++){
                          if(GlobalProfile.popularCommunityList [i].id == widget._communityList[index].id){
                            GlobalProfile.popularCommunityList [i].communityLike.add(user);
                            break;
                          }
                        }


                        for(int i = 0; i< GlobalProfile.newCommunityList.length;i++){
                          if(GlobalProfile.newCommunityList[i].id ==widget._communityList[index].id){
                            GlobalProfile.newCommunityList[i].communityLike.add(user);
                            break;
                          }
                        }
                      }
                    }
                    else {
                      await ApiProvider().post('/CommunityPost/InsertLike',jsonEncode(
                          {
                            "userID": GlobalProfile.loggedInUser.userID,
                            "postID":widget._communityList[index].id
                          }
                      ));

                      int idx1= -1;
                      int idx2 = -1;
                      for (int i = 0; i <widget._communityList[index].communityLike.length; i++) {
                        if (widget._communityList[index].communityLike[i].userID ==
                            GlobalProfile.loggedInUser.userID)
                        {
                          idx2 = i;
                          break;
                        }
                      }

                      widget._communityList[index].communityLike.removeAt(idx2);
                      idx1 =-1;
                      idx2 = -1;



                      for(int i = 0; i< GlobalProfile.popularCommunityList .length;i++){
                        if(GlobalProfile.popularCommunityList [i].id == widget._communityList[index].id){
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
                        if(GlobalProfile. newCommunityList [i].id == widget._communityList[index].id){
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
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgGreySheepEyeX,width: 192*sizeUnit ,height: 138*sizeUnit),
              SizedBox(height: 40*sizeUnit),
              Center(
                child: Text(
                  widget._title == '내가 쓴 글'
                  ? '작성한 글이 없습니다.\n커뮤니티에서 글을 작성해 보세요!'
                  : widget._title == '내가 쓴 댓글'
                    ? '댓글을 단 글이 없습니다.\n흥미로운 글에 댓글을 달아보세요!'
                    : widget._title == '좋아요 한 글'
                      ? '좋아요를 한 글이 없습니다.\n흥미로운 글을 \'좋아해\'보세요!'
                      : '',
                  style: SheepsTextStyle.b2(context),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
    );
  }

  bool insertCheckFor(int userID, int index) {
    bool check = false;
    for (int i = 0;
    i <  widget._communityList[index].communityLike.length;
    i++) {
      if (widget._communityList[index].communityLike[i].userID == userID) {
        check = true;
        break;
      }
    }
    return check;
  }
}
