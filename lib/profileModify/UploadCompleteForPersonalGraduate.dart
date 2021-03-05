import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadCompleteUI.dart';


class UploadCompleteForPersonalGraduate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ModifiedProfile _ModifiedTeamProfile = Provider.of<ModifiedProfile>(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context, '대학원 증빙 자료', isBackButton: false),
        body: UploadCompleteBody(context,file: _ModifiedTeamProfile.GraduateFile),
      ),
    );
  }
}
