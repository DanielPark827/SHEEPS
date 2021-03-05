import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class PasswordCheckPage extends StatefulWidget {
  String password;

  PasswordCheckPage({Key key, @required this.password}) : super(key : key);


  @override
  _PasswordCheckPageState createState() => _PasswordCheckPageState();
}

class _PasswordCheckPageState extends State<PasswordCheckPage> {

  String successIcon = 'assets/images/Public/SuccessIcon.svg';
  String failedIcon = 'assets/images/Public/FailedIcon.svg';

  dynamic result;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask( () async {
      result = await ApiProvider().post('/Profile/Personal/FindID', jsonEncode(
          {
            "id" : globalLoginID,
            "password" : widget.password
          }
      ));

      setState(() {
        print(result);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(result != null ? successIcon : failedIcon, width: 100*sizeUnit, height: 100*sizeUnit),
            Row(
              children: [
                SizedBox(height: 60*sizeUnit),
              ],
            ),
            Text(
              result != null ?  "비밀번호가 정상적으로\n변경되었습니다." : "비밀번호 변경에\n실패하였습니다.",
              textAlign: TextAlign.center,
              style: SheepsTextStyle.h1(context),
            ),
            SizedBox(height: 20*sizeUnit),
            Text(
              result != null ? "쉽스와 즐거운 스타트업 생활이 되세요." : "다시 한 번 시도해 주세요.",
              textAlign: TextAlign.center,
              style: SheepsTextStyle.b3(context),
            ),
          ],
        ),
        bottomNavigationBar: GestureDetector(
          onTap: (){
            Navigator.pop(context);

            if(result != null)
              Navigator.pop(context);
          },
          child: Container(
              height: 60*sizeUnit,
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
          ),
        ),
      ),
    );
  }
}
