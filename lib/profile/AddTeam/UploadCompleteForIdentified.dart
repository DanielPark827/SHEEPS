import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadCompleteUI.dart';

class UploadCompleteForIdentified extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    ModelAddTeam _ModifiedTeamProfile = Provider.of<ModelAddTeam>(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context, '인증 증빙 자료'),
        body: UploadCompleteBody(context, file: _ModifiedTeamProfile.IdentifiedFile[_ModifiedTeamProfile.IdentifiedFile.length-1]),
        // Column(
        //   children: [
        //     SizedBox(height: screenHeight*0.10625,),
        //     Align(
        //       alignment: Alignment.topCenter,
        //       child: Container(
        //         width: MediaQuery.of(context).size.height * 0.3125,
        //         height: MediaQuery.of(context).size.height * 0.3125,
        //         decoration: BoxDecoration(
        //             color: hexToColor("#EEEEEE"),
        //             borderRadius: BorderRadius.all(Radius.circular(4)),
        //             image: DecorationImage(
        //                 image: FileImage(_ModifiedTeamProfile.IdentifiedFile[_ModifiedTeamProfile.IdentifiedFile.length-1]),
        //                 fit: BoxFit.cover)),
        //       ),
        //     ),
        //     SizedBox(height: screenHeight*0.0625,),
        //     Align(
        //       alignment: Alignment.topCenter,
        //       child: Text(
        //         '증빙자료 업로드가 완료되었어요.',
        //         style: TextStyle(
        //           fontSize: screenWidth*( 16/360),
        //           color: Colors.black,
        //         ),
        //       ),
        //     ),
        //     Align(
        //       alignment: Alignment.topCenter,
        //       child: Text(
        //         '빠른 시일내에 검토 후 알려드릴게요!',
        //         style: TextStyle(
        //           fontSize:  screenWidth*( 16/360),
        //           color: Colors.black,
        //         ),
        //       ),
        //     ),
        //     SizedBox(height: screenHeight*0.0625,),
        //     GestureDetector(
        //       onTap: (){
        //         Navigator.pop(context);
        //       },
        //       child: Container(
        //         width:screenWidth*0.88888 ,
        //         height: screenHeight*0.075,
        //         decoration: BoxDecoration(
        //           color: hexToColor("#61C680"),
        //           borderRadius: new BorderRadius.circular(8*sizeUnit),
        //         ),
        //         child: Align(
        //           alignment: Alignment.center,
        //           child: Text(
        //             '완료',
        //             style: TextStyle(
        //               fontSize: screenWidth*( 16/360),
        //               color: Colors.white,
        //             ),
        //           ),
        //         ),
        //       ),
        //     )
        //   ],
        // ),
      ),
    );
  }
}
