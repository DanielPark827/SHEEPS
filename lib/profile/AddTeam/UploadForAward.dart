import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/profile/AddTeam/UploadCompleteForAward.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadUI.dart';

class UploadForAward extends StatefulWidget {

  @override
  _UploadForIdentifiedState createState() => _UploadForIdentifiedState();
}

class _UploadForIdentifiedState extends State<UploadForAward> {
  @override
  Widget build(BuildContext context) {
    ModelAddTeam _ModifiedTeamProfile = Provider.of<ModelAddTeam>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(
          context,
          '수상 증빙 자료',
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
          file: _ModifiedTeamProfile.AwardFile.length == 0 ? null : _ModifiedTeamProfile.AwardFile[_ModifiedTeamProfile.AwardFile.length-1],
          cancelFileChangeFunc: () {
            _ModifiedTeamProfile.removeFile(_ModifiedTeamProfile.AwardFile[_ModifiedTeamProfile.AwardFile.length-1],3);
          },
          cameraFunc:() async {
            PickedFile f = await ImagePicker()
                .getImage(source: ImageSource.camera); //camera -> gallery
            if (f == null) return;
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

            _ModifiedTeamProfile.ChangeIfAddTeamAwardUploadComplete(true);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForAward()) // SecondRoute를 생성하여 적재
            ).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
          galleryFunc: () async {
            PickedFile f = await ImagePicker()
                .getImage(source: ImageSource.gallery); //camera -> gallery
            if (f == null) return;
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

            _ModifiedTeamProfile.ChangeIfAddTeamAwardUploadComplete(true);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForAward()) // SecondRoute를 생성하여 적재
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
