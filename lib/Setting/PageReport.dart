import 'dart:io';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/ApiProvider.dart';


class PageReport extends StatefulWidget {
  int userID;
  String classification;
  var reportedID;

  PageReport({Key key, this.userID, this.classification, this.reportedID}) : super(key : key);

  @override
  _PageReportState createState() => _PageReportState();
}

class _PageReportState extends State<PageReport> {
  int userID;
  String classification;
  var reportedID;

  double sizeUnit;

  bool isContents;

  final contentsController = TextEditingController();

  @override
  void initState() {
    userID = widget.userID;
    classification = widget.classification;
    reportedID = widget.reportedID;
    isContents = false;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    contentsController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시,
      child: GestureDetector(
        onTap: () {
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
          backgroundColor: Colors.white,
          appBar: SheepsAppBar(context, '신고하기'),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 20*sizeUnit, right: 20*sizeUnit),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: contentsController,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              minLines: 5,
                              maxLines: 20,
                              maxLengthEnforced: true,
                              maxLength: 100,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: "신고 내용을 입력해주세요. (최소 5글자)",
                                hintStyle: SheepsTextStyle.hint4Profile(context),
                                contentPadding: EdgeInsets.fromLTRB(12*sizeUnit, 16*sizeUnit, 12*sizeUnit, 16*sizeUnit),
                              ),
                              onChanged: (text){
                                text.length > 4 ? isContents = true : isContents = false;
                                setState(() {

                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 360*sizeUnit,
                height: 60*sizeUnit,
                child: FlatButton(
                    color: isContents
                        ? Color(0xFF61C680)
                        : Color(0xFFCCCCCC),
                    onPressed: isContents
                        ? () async {
                          if(classification == 'ChatRoom'){
                            await ApiProvider().post('/Room/Declare', jsonEncode({
                              "userID" : userID,
                              "roomName" : reportedID,
                              "contents" : contentsController.text
                            }));
                            Fluttertoast.showToast(msg: "신고되었습니다.", toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
                            Navigator.pop(context);
                          } else if(classification == 'Community'){
                            await ApiProvider().post('/CommunityPost/Declare', jsonEncode({
                              "userID" : userID,
                              "targetID" : reportedID,
                              "contents" : contentsController.text
                            }));
                            Fluttertoast.showToast(msg: "신고되었습니다.", toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(msg: "신고 과정에 오류가 발생했습니다.", toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
                          }
                        }
                        : () {},
                    child: Text(
                      "신고하기",
                      style: SheepsTextStyle.button1(context),
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
