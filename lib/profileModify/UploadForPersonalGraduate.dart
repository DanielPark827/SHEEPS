import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/profileModify/UploadCompleteForPersonalGraduate.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadUI.dart';

class UploadForPersonalGraduate extends StatefulWidget {

  @override
  _UploadForIdentifiedState createState() => _UploadForIdentifiedState();
}

class _UploadForIdentifiedState extends State<UploadForPersonalGraduate> {
  @override
  Widget build(BuildContext context) {
    ModifiedProfile _ModifiedTeamProfile = Provider.of<ModifiedProfile>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context, '대학원 증빙 자료'),
        body: UploadBody(
          context,
          file: _ModifiedTeamProfile.GraduateFile,
          cancelFileChangeFunc: () {
            _ModifiedTeamProfile.ChangeGraduateFile(null);
          },
          hintText: '재학증명서, 졸업증명서,\n졸업예정증명서 등',
          cameraFunc: () async {
            PickedFile f = await ImagePicker()
                .getImage(source: ImageSource.camera);
            if (f == null) return;
            _ModifiedTeamProfile.ChangeGraduateFile(File(f.path));


            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForPersonalGraduate()) // SecondRoute를 생성하여 적재
            ).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });

          },
          galleryFunc: () async {
            PickedFile f = await ImagePicker()
                .getImage(source: ImageSource.gallery);
            if (f == null) return;
            _ModifiedTeamProfile.ChangeGraduateFile(File(f.path));


            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForPersonalGraduate()) // SecondRoute를 생성하여 적재
            ).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });

          },
        ),
      ),
    );
  }
}
