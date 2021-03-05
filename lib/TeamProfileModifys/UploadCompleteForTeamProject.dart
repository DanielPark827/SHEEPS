import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/TeamProfileModifys/model/DummyForTeamProfileModify.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadCompleteUI.dart';

class UploadCompleteForTeamProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ModelTeamProfile _ModifiedTeamProfile = Provider.of<ModelTeamProfile>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context, '수행 내역 증빙 자료'),
        body: UploadCompleteBody(context, file: _ModifiedTeamProfile.ProjectFile[_ModifiedTeamProfile.ProjectFile.length-1]),
      ),
    );
  }
}
