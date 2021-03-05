import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/dashboard/MyHomePage.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/registration/NameUpdatePage.dart';
import 'package:sheeps_app/registration/PhoneNumberAuthPage.dart';
import 'package:sheeps_app/registration/RegistrationPage.dart';
import 'package:sheeps_app/registration/bloc/UserRepository.dart';
import 'package:sheeps_app/registration/model/RegistrationModel.dart';

import 'bloc/RegistrationBloc.dart';

class PageTermsOfService extends StatefulWidget {
  int loginType;

  PageTermsOfService({Key key, @required this.loginType}) : super(key : key);

  @override
  _PageTermsOfServiceState createState() => _PageTermsOfServiceState();
}

class _PageTermsOfServiceState extends State<PageTermsOfService> {
  double sizeUnit;
  bool isMustAgree;
  bool isServiceAgree;
  bool isPrivacyAgree;
  bool isCommunityAgree;
  bool isMarketingAgree;
  bool isAllAgree;

  @override
  void initState() {
    isMustAgree = false;
    isServiceAgree = false;
    isPrivacyAgree = false;
    isCommunityAgree = false;
    isMarketingAgree = false;
    isAllAgree = false;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    final UserRepository userRepository = UserRepository();

    if(isServiceAgree && isPrivacyAgree && isCommunityAgree){
      isMustAgree = true;
    } else{
      isMustAgree = false;
    }
    if(isServiceAgree && isPrivacyAgree && isCommunityAgree && isMarketingAgree){
      isAllAgree = true;
    } else{
      isAllAgree = false;
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context, '이용약관 동의'),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 20*sizeUnit, right: 16*sizeUnit),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60*sizeUnit),
                    Text(
                      '약관 동의 후\n회원가입을 시작합니다.',
                      style: SheepsTextStyle.h2(context),
                    ),
                    SizedBox(height: 40*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        if(isAllAgree){
                          isServiceAgree = false;
                          isPrivacyAgree = false;
                          isCommunityAgree = false;
                          isMarketingAgree = false;
                        } else{
                          isServiceAgree = true;
                          isPrivacyAgree = true;
                          isCommunityAgree = true;
                          isMarketingAgree = true;
                        }
                        setState(() {

                        });
                      },
                      child: Container(
                        width: 320*sizeUnit,
                        height: 32*sizeUnit,
                        color: Colors.white,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              svgCheck,
                              height: 16 * sizeUnit,
                              width: 16 * sizeUnit,
                              color: isAllAgree ? Color(0xFF61C680) : Color(0xFFCCCCCC),
                            ),
                            SizedBox(width: 8*sizeUnit),
                            Text(
                              '전체 동의하기',
                              style: SheepsTextStyle.h2(context).copyWith(height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4*sizeUnit),
                    Divider(color: Color(0xFFCCCCCC)),
                    SizedBox(height: 24*sizeUnit),
                    Row(
                      children: [
                        SizedBox(width: 24*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            isServiceAgree = !isServiceAgree;
                            setState(() {

                            });
                          },
                          child: Container(
                            width: 280*sizeUnit,
                            height: 32*sizeUnit,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SvgPicture.asset(//인증완료 1 일때 초록아이콘
                                  svgCheck,
                                  height: 16 * sizeUnit,
                                  width: 16 * sizeUnit,
                                  color: isServiceAgree ? Color(0xFF61C680) : Color(0xFFCCCCCC),
                                ),
                                SizedBox(width: 8*sizeUnit),
                                Text(
                                  '서비스 이용약관',
                                  style: SheepsTextStyle.h3(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    // Add 6 lines from here...
                                    body: MyHomePage(
                                        url: 'https://www.notion.so/noteasy/915417f1fd964d1f92ad3bb6429b908a'),
                                  ); // ... to here.
                                },
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            svgGreyNextIcon,
                            width: 16*sizeUnit,
                            height: 16*sizeUnit,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10*sizeUnit),
                    Row(
                      children: [
                        SizedBox(width: 24*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            isPrivacyAgree = !isPrivacyAgree;
                            setState(() {

                            });
                          },
                          child: Container(
                            width: 280*sizeUnit,
                            height: 32*sizeUnit,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SvgPicture.asset(//인증완료 1 일때 초록아이콘
                                  svgCheck,
                                  height: 16 * sizeUnit,
                                  width: 16 * sizeUnit,
                                  color: isPrivacyAgree ? Color(0xFF61C680) : Color(0xFFCCCCCC),
                                ),
                                SizedBox(width: 8*sizeUnit),
                                Text(
                                  '개인정보 처리방침',
                                  style: SheepsTextStyle.h3(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    body: MyHomePage(
                                        url: 'https://www.notion.so/noteasy/71203390476d472a8cafa5081c8116e2'),
                                  ); // ... to here.
                                },
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            svgGreyNextIcon,
                            width: 16*sizeUnit,
                            height: 16*sizeUnit,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10*sizeUnit),
                    Row(
                      children: [
                        SizedBox(width: 24*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            isCommunityAgree = !isCommunityAgree;
                            setState(() {

                            });
                          },
                          child: Container(
                            width: 280*sizeUnit,
                            height: 32*sizeUnit,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SvgPicture.asset(//인증완료 1 일때 초록아이콘
                                  svgCheck,
                                  height: 16 * sizeUnit,
                                  width: 16 * sizeUnit,
                                  color: isCommunityAgree ? Color(0xFF61C680) : Color(0xFFCCCCCC),
                                ),
                                SizedBox(width: 8*sizeUnit),
                                Text(
                                  '커뮤니티 정책',
                                  style: SheepsTextStyle.h3(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    body: MyHomePage(
                                        url: 'https://www.notion.so/noteasy/9fe84478cb2d47c4a029c98a4588a9ce'),
                                  ); // ... to here.
                                },
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            svgGreyNextIcon,
                            width: 16*sizeUnit,
                            height: 16*sizeUnit,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10*sizeUnit),
                    Row(
                      children: [
                        SizedBox(width: 24*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            isMarketingAgree = !isMarketingAgree;
                            setState(() {

                            });
                          },
                          child: Container(
                            width: 280*sizeUnit,
                            height: 32*sizeUnit,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SvgPicture.asset(//인증완료 1 일때 초록아이콘
                                  svgCheck,
                                  height: 16 * sizeUnit,
                                  width: 16 * sizeUnit,
                                  color: isMarketingAgree ? Color(0xFF61C680) : Color(0xFFCCCCCC),
                                ),
                                SizedBox(width: 8*sizeUnit),
                                Text(
                                  '마케팅 수신동의 (선택)',
                                  style: SheepsTextStyle.h3(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4*sizeUnit),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                    body: MyHomePage(
                                        url: 'https://www.notion.so/noteasy/84c7a48d09a749b1986dd09794af9b69'),
                                  ); // ... to here.
                                },
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            svgGreyNextIcon,
                            width: 16*sizeUnit,
                            height: 16*sizeUnit,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 360*sizeUnit,
              height: 60*sizeUnit,
              child: FlatButton(
                  color: isMustAgree
                      ? Color(0xFF61C680)
                      : Color(0xFFCCCCCC),
                  onPressed: isMustAgree
                      ? () {
                    switch(widget.loginType){
                      case 0:
                        {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context){
                                return BlocProvider(
                                  create: (ctx) => RegistrationBloc(userRepository),
                                  child: RegistrationPage(isMarketingAgree: isMarketingAgree,),
                                );
                              }));
                        }
                        break;
                      case 1:
                        {
                          ApiProvider().post('/Profile/Personal/MarketingUpdate', jsonEncode({
                            "id" : globalLoginID,
                            "marketingAgree" : isMarketingAgree
                          }));

                          Navigator.push(
                              context, // 기본 파라미터, SecondRoute로 전달
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PhoneNumberAuthPage()));
                        }
                        break;
                      case 2:
                        {
                          ApiProvider().post('/Profile/Personal/MarketingUpdate', jsonEncode({
                            "id" : globalLoginID,
                            "marketingAgree" : isMarketingAgree
                          }));

                          Navigator.push(
                              context, // 기본 파라미터, SecondRoute로 전달
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NameUpdatePage(email:  globalLoginID,)));
                        }
                        break;
                    }
                  }
                      : () {},
                  child: Text(
                    "다음",
                    style: SheepsTextStyle.button1(context),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}

