import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/main.dart';

Positioned bottomNavi(BuildContext context,double screenWidth, double screenHeight) {
  NavigationNum navigationNum = Provider.of<NavigationNum>(context);

  return Positioned(
    bottom: 0,
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: kBottomNavigationBarHeight,
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width*0.1,),

          InkWell(
            onTap: (){
              //navigationNum.setNum(0);
              print(Provider.of<NavigationNum>(context,listen: false).getNum());
              // Navigator.of(context).popUntil(ModalRoute.withName('/MainPage'));
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainPage()));

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
                    (Route<dynamic> route) => false,
              );
            },
            child: SizedBox(
              width: screenWidth*0.05,
              //height: screenWidth*0.05,
              child: SvgPicture.asset(
                'assets/images/HomeIcon.svg',
                width: screenWidth * 0.8055,
                height: screenHeight * 0.3281,
              ),
            ),
          ),
          Spacer(),
          InkWell(
            onTap: ()async{
              navigationNum.setNum( PROFILE_PAGE );
              print(Provider.of<NavigationNum>(context,listen: false).getNum());
              // Navigator.of(context).popUntil(ModalRoute.withName('/'));
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainPage()));

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
                    (Route<dynamic> route) => false,
              );
            },
            child: SizedBox(
              width: screenWidth*0.05,
              //height: screenWidth*0.05,
              child: SvgPicture.asset(
                'assets/images/NewsIcon.svg',
                width: screenWidth * 0.8055,
                height: screenHeight * 0.3281,
              ),
            ),
          ),
          Spacer(),
          InkWell(
            onTap: (){
              navigationNum.setNum(COMMUNITY_MAIN_PAGE);
              print(Provider.of<NavigationNum>(context,listen: false).getNum());
              // Navigator.of(context).popUntil(ModalRoute.withName('/'));
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainPage()));

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),

              );
            },
            child: SizedBox(
              width: screenWidth*0.05,
             // height: screenWidth*0.05,
              child: SvgPicture.asset(
                'assets/images/NavigationBar/ChatIcon.svg',
                width: screenWidth * 0.8055,
                height: screenHeight * 0.3281,
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
                barrierColor: Colors.black12.withOpacity(0.6),
                transitionDuration: Duration(milliseconds: 150),
                pageBuilder:
                    (BuildContext context, Animation first, Animation second) {
                  return Center(
                    child: Container(
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        new BorderRadius.all(new Radius.circular(8.0)),
                      ),
                      width: MediaQuery.of(context).size.width *
                          0.7777777777777778,
                      height: MediaQuery.of(context).size.height * 0.575,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.0625,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height*0.0515625,
                            child: Material(
                              child: Text(
                                "준비중입니다!",
                                style: TextStyle(
                                  color: Color(0xff222222),
                                  fontSize: screenWidth*( 24/360),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.03125,),
                          Container(
                            child: SvgPicture.asset(
                              'assets/images/dialogForReady.svg',
                              width: MediaQuery.of(context).size.width*0.5555555555555556,
                              height: MediaQuery.of(context).size.height*0.21875,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.0359375,),
                          Material(
                            child: Text(
                              "공모전 / 지원사업등 목적별 팀 모집이 가능한\n기능이 현재 개발 중 이에요 조금만 기다려주세요!",
                              style: TextStyle(
                                  color: Color(0xff222222),
                                  fontSize:screenWidth*(12 /360),),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.03125,),
                          Material(
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.7111111111111111,
                              height: MediaQuery.of(context).size.height*0.0625,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
                                color: Color(0xff61c680),
                              ),
                              child: Center(
                                child: Text("확인",style: TextStyle(color: Colors.white,fontSize:screenWidth*( 16/360),),),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child:
            SizedBox(
              width: screenWidth*0.05,
             // height: screenWidth*0.05,
              child: SvgPicture.asset(
                'assets/images/PeopleIcon.svg',
                width: screenWidth * 0.8055,
                height: screenHeight * 0.3281,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.1,),
        ],
      ),
    ),
  );
}
