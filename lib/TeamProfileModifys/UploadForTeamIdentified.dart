import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/TeamProfileModifys/UploadCompleteForTeamIdentified.dart';
import 'package:sheeps_app/TeamProfileModifys/model/DummyForTeamProfileModify.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadUI.dart';

class UploadForTeamIdentified extends StatefulWidget {

  @override
  _UploadForIdentifiedState createState() => _UploadForIdentifiedState();
}

class _UploadForIdentifiedState extends State<UploadForTeamIdentified> {

  final String GreyCircularLine = 'assets/images/Public/GreyCircularLine.svg';

  File dummyFile;

  @override
  Widget build(BuildContext context) {
    ModelTeamProfile _ModifiedTeamProfile = Provider.of<ModelTeamProfile>(context);

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context,
          '인증 증빙 자료',
          backFunc: (){
            if(_ModifiedTeamProfile.FlagForIdentified == true) {
              if (_ModifiedTeamProfile.IdentifiedName != null &&
                  _ModifiedTeamProfile.IdentifiedAgency != null) {
                _ModifiedTeamProfile.ChangeIfAddIdentifiedComplete(true);
              } else {
                _ModifiedTeamProfile.ChangeIfAddIdentifiedComplete(false);
              }
            } else if(_ModifiedTeamProfile.FlagForProject == true) {
              if(_ModifiedTeamProfile.ProjectAgency != null && _ModifiedTeamProfile.ProjectStart != null && _ModifiedTeamProfile.ProjectEnd != null && _ModifiedTeamProfile.ProjectName != null) {
                _ModifiedTeamProfile.ChangeIfAddProjectComplete(true);
              } else {
                _ModifiedTeamProfile.ChangeIfAddProjectComplete(false);
              }
            } else if(_ModifiedTeamProfile.FlagForTeamAward == true) {
              if(_ModifiedTeamProfile.TeamAwardGrade != null && _ModifiedTeamProfile.TeamAwardAgency != null && _ModifiedTeamProfile.TeamAwardTime != null && _ModifiedTeamProfile.TeamAwardName != null) {
                _ModifiedTeamProfile.ChangeIfAddTeamAwardComplete(true);
              } else {
                _ModifiedTeamProfile.ChangeIfAddTeamAwardComplete(false);
              }
            }
            Navigator.pop(context);
          },
        ),
        body: UploadBody(
          context,
          file: _ModifiedTeamProfile.IdentifiedFile.length == 0 ? null : _ModifiedTeamProfile.IdentifiedFile[_ModifiedTeamProfile.IdentifiedFile.length-1],
          cancelFileChangeFunc: () {
            _ModifiedTeamProfile.removeFile(_ModifiedTeamProfile.IdentifiedFile[_ModifiedTeamProfile.IdentifiedFile.length-1],1);
          },
          hintText: '인증 서류 사본을 업로드 해주세요.',
          cameraFunc: () async {
            PickedFile f = await ImagePicker()
                .getImage(source: ImageSource.camera); //camera -> gallery
            if (f == null) return;
            dummyFile = File(f.path);
            setState(() {

            });

            if(_ModifiedTeamProfile.FlagForIdentified == true) {
              if(_ModifiedTeamProfile.IdentifiedList.length < _ModifiedTeamProfile.IdentifiedFile.length) {
                _ModifiedTeamProfile.removeEndFile(1);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),1);

            } else if(_ModifiedTeamProfile.FlagForProject == true) {
              if(_ModifiedTeamProfile.ProjectList.length < _ModifiedTeamProfile.ProjectFile.length) {
                _ModifiedTeamProfile.removeEndFile(2);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),2);
            } else if(_ModifiedTeamProfile.FlagForTeamAward == true) {
              if(_ModifiedTeamProfile.TeamAwardList.length < _ModifiedTeamProfile.AwardFile.length) {
                _ModifiedTeamProfile.removeEndFile(3);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),3);
            }

            _ModifiedTeamProfile.ChangeIfAddIdentifiedUploadComplete(true);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForTeamIdentified()) // SecondRoute를 생성하여 적재
            ).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
          galleryFunc: () async {
            PickedFile f = await ImagePicker()
                .getImage(source: ImageSource.gallery); //camera -> gallery
            if (f == null) return;
            dummyFile = File(f.path);
            setState(() {

            });

            if(_ModifiedTeamProfile.FlagForIdentified == true) {
              if(_ModifiedTeamProfile.IdentifiedList.length < _ModifiedTeamProfile.IdentifiedFile.length) {
                _ModifiedTeamProfile.removeEndFile(1);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),1);

            } else if(_ModifiedTeamProfile.FlagForProject == true) {
              if(_ModifiedTeamProfile.ProjectList.length < _ModifiedTeamProfile.ProjectFile.length) {
                _ModifiedTeamProfile.removeEndFile(2);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),2);
            } else if(_ModifiedTeamProfile.FlagForTeamAward == true) {
              if(_ModifiedTeamProfile.TeamAwardList.length < _ModifiedTeamProfile.AwardFile.length) {
                _ModifiedTeamProfile.removeEndFile(3);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),3);
            }

            _ModifiedTeamProfile.ChangeIfAddIdentifiedUploadComplete(true);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForTeamIdentified()) // SecondRoute를 생성하여 적재
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

