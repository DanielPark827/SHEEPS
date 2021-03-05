
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/chat/models/ChatDatabase.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/login/LoginPage.dart';
import 'package:sheeps_app/login/bloc/LoginBloc.dart';
import 'package:sheeps_app/profile/modelsForPersonalImageList/MultipartImgFilesProvider.dart';
import 'package:sheeps_app/registration/LoginSelectPage.dart';

import '../../config/constants.dart';
import 'DefaultButton.dart';
import 'OnboardingContent.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {"text": "진짜 초기\n스타트업들을 위한", 'image': 'assets/images/LoginReg/tutorialRocket.svg'},
    {"text": "도전자에게 필요한\n프로필 관리", "image": 'assets/images/LoginReg/tutorialProfile.svg'},
    {"text": "빠르고 정확한\n팀빌딩", "image": 'assets/images/LoginReg/tutorialTeamFill.svg'},
    {
      "text": "웃고 떠드는\n스타트업 커뮤니티",
      "image": 'assets/images/LoginReg/tutorialTalkBubbles.svg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20*sizeUnit),
          child: Column(
            mainAxisAlignment : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 312*sizeUnit,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => OnboardingContent(
                    image: splashData[index]["image"],
                    text: splashData[index]['text'],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  splashData.length,
                      (index) => buildDot(index: index),
                ),
              ),
              SizedBox(
                height: 20*sizeUnit,
              ),
              DefaultButton(
                text: "시작하기",
                press: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return Scaffold(
                          // Add 6 lines from here...
                          body: LoginSelectPage(),
                        ); // ... to here.
                      },
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20*sizeUnit,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    child: Text("이미 계정을 보유하고 있다면",
                        style: SheepsTextStyle.info1(context)
                    ),
                  ),
                  Align(
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return BlocProvider(
                                  create: (ctx) => LoginBloc(),
                                  child: LoginPage(),
                                );
                              }));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(" 로그인",
                              style: SheepsTextStyle.infoStrong(context)
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 4),
      height: 8,
      width: currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
