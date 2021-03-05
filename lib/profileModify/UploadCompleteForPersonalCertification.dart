import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/TeamProfileModifys/model/DummyForTeamProfileModify.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadCompleteUI.dart';

class UploadCompleteForPersonalCertification extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    ModifiedProfile _ModifiedTeamProfile = Provider.of<ModifiedProfile>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context, '자격증증 증빙자료', isBackButton: false),
        body: UploadCompleteBody(context,file: _ModifiedTeamProfile.CertificationFile[_ModifiedTeamProfile.CertificationFile.length-1]),
      ),
    );
  }
}
