import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iamport_flutter/Iamport_certification.dart';
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

class iamportCertificationPage extends StatefulWidget {
  Widget resultPage;
  CertificationData data;

  iamportCertificationPage({Key key, @required this.resultPage, @required this.data}) : super(key : key);

  @override
  _iamportCertificationPageState createState() => _iamportCertificationPageState();
}

class _iamportCertificationPageState extends State<iamportCertificationPage> {
  String userCode = 'imp99004464';

  @override
  Widget build(BuildContext context) {

    return IamportCertification(


      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/LoninReg/iamport-logo.png'),
              Container(
                padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
              ),
            ],
          ),
        ),
      ),
      userCode: userCode,
      data: widget.data,
      callback: (Map<String, String> result) async {
        if(result['success'] == 'true'){

          var res = await ApiProvider().post('/Profile/PhoneUpdate', jsonEncode(
              {
                "id" : globalLoginID,
                "phonenumber" : globalPhoneNumber
              }
          ));

          if(res['result'] == 'ALREADY'){
            Fluttertoast.showToast(msg: "이미 가입된 번호입니다. 다시 시도 해 주세요.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: hexToColor('#FFFFFF') );
            Navigator.pop(context);
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => widget.resultPage,
            ));
          }
        }else{
          Fluttertoast.showToast(msg: "핸드폰 인증에 실패하셨습니다. 다시 시도 해 주세요.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: hexToColor('#FFFFFF') );
          Navigator.pop(context);
        }

      },
    );
  }
}
