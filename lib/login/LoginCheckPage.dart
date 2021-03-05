import 'dart:convert';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class LoginCheckPage extends StatefulWidget {

  @override
  _LoginCheckPageState createState() => _LoginCheckPageState();
}

class _LoginCheckPageState extends State<LoginCheckPage> {

  String succecedIcon = 'assets/images/Public/SuccessIcon.svg';
  String failedIcon = 'assets/images/Public/FailedIcon.svg';
  String findID = '';

  Map<String, String> arguments;
  bool Flag;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask( () async {

     arguments = ModalRoute.of(context).settings.arguments;
     Flag = arguments['success'] == 'true' ? true : false;

      var res = await ApiProvider().post('/Profile/Personal/FindID', jsonEncode(
          {
            "phoneNumber" : globalPhoneNumber,
          }
      ));

      setState(() {
        if(res == null) findID = null;
        else findID = res['ID'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return ConditionalWillPopScope(
      shouldAddCallbacks: true,
      onWillPop: () {
        Navigator.pop(context);

        if(Flag)
          Navigator.pop(context);

        return;
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          appBar: new AppBar(
            backgroundColor: hexToColor("#FFFFFF"),
            elevation: 0.0,
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.only(left: 12*sizeUnit),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);

                  if( Flag)
                    Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    svgBackArrow,
                    width: 28*sizeUnit,
                    height: 28*sizeUnit,
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(Flag && findID != null ? succecedIcon : failedIcon, width: 100*sizeUnit, height: 100*sizeUnit),
                Row(
                  children: [
                    SizedBox(height: 64*sizeUnit),
                  ],
                ),
                Text(
                  !Flag ? "본인인증이\n실패하였습니다." : findID == null ? "가입되지 않은 번호입니다." : "당신의 아이디는\n" + "'" + findID + "'" + "입니다.",
                  textAlign: TextAlign.center,
                  style: SheepsTextStyle.h1(context),
                ),
                SizedBox(height: 20*sizeUnit),
                Text(
                  !Flag ? "다시 한 번 시도해 주세요." : findID == null ? "지금 가입하고, 스타트업을 시작해보세요." : "쉽스와 즐거운 스타트업 생활이 되세요."  ,
                  textAlign: TextAlign.center,
                  style: SheepsTextStyle.b3(context),
                )
              ],
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
                height: screenHeight*0.09375,
                decoration: BoxDecoration(
                  color:  hexToColor("#61C680") ,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '확인',
                    style: SheepsTextStyle.button1(context),
                  ),
                ),
            )
          ),
        ),
      ),
    );
  }
}
