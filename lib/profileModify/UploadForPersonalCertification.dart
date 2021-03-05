import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/profileModify/UploadCompleteForPersonalCertification.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/UploadUI.dart';

class UploadForPersonalCertification extends StatefulWidget {

  @override
  _UploadForIdentifiedState createState() => _UploadForIdentifiedState();
}

class _UploadForIdentifiedState extends State<UploadForPersonalCertification> {
  File dummyFile;
  @override
  Widget build(BuildContext context) {
    ModifiedProfile _ModifiedTeamProfile = Provider.of<ModifiedProfile>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SheepsAppBar(context,'자격증 증빙 자료'),
        body: UploadBody(
          context,
          file: dummyFile,
          cancelFileChangeFunc: (){
            _ModifiedTeamProfile.removeFile(_ModifiedTeamProfile.CertificationFile[_ModifiedTeamProfile.CertificationFile.length-1],1);
          },
          hintText: '자격증 사본, 합격증명서 등',
          cameraFunc: () async {
            PickedFile f = await ImagePicker()
                .getImage(source: ImageSource.camera); //camera -> gallery
            if (f == null) return;
            dummyFile = File(f.path);
            setState(() {

            });
            if(_ModifiedTeamProfile.FlagForCareer == true) {
              if(_ModifiedTeamProfile.CareerList.length < _ModifiedTeamProfile.CareerFile.length) {
                _ModifiedTeamProfile.removeEndFile(1);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),1);
            } else if(_ModifiedTeamProfile.FlagForCertification == true) {
              if(_ModifiedTeamProfile.CertificationList.length < _ModifiedTeamProfile.CertificationFile.length) {
                _ModifiedTeamProfile.removeEndFile(2);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),2);
            } else if(_ModifiedTeamProfile.FlagForAward == true) {
              if(_ModifiedTeamProfile.AwardList.length < _ModifiedTeamProfile.AwardFile.length) {
                _ModifiedTeamProfile.removeEndFile(3);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),3);
            }

            _ModifiedTeamProfile.ChangeCertificationUploadComplete(true);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForPersonalCertification()) // SecondRoute를 생성하여 적재
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
            if(_ModifiedTeamProfile.FlagForCareer == true) {
              if(_ModifiedTeamProfile.CareerList.length < _ModifiedTeamProfile.CareerFile.length) {
                _ModifiedTeamProfile.removeEndFile(1);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),1);
            } else if(_ModifiedTeamProfile.FlagForCertification == true) {
              if(_ModifiedTeamProfile.CertificationList.length < _ModifiedTeamProfile.CertificationFile.length) {
                _ModifiedTeamProfile.removeEndFile(2);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),2);
            } else if(_ModifiedTeamProfile.FlagForAward == true) {
              if(_ModifiedTeamProfile.AwardList.length < _ModifiedTeamProfile.AwardFile.length) {
                _ModifiedTeamProfile.removeEndFile(3);
              }
              _ModifiedTeamProfile.addFiles(File(f.path),3);
            }

            _ModifiedTeamProfile.ChangeCertificationUploadComplete(true);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        UploadCompleteForPersonalCertification()) // SecondRoute를 생성하여 적재
            ).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
        )
      ),
    );
  }
}

