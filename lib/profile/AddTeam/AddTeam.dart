import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:sheeps_app/profile/AddTeam/AddIdentifiedForAddTeam.dart';
import 'package:sheeps_app/profile/AddTeam/AddProjectForAddTeam.dart';
import 'package:sheeps_app/profile/AddTeam/AddTeamAwardForAddTeam.dart';
import 'package:sheeps_app/profile/AddTeam/SelectAddTeamArea.dart';
import 'package:sheeps_app/profile/AddTeam/SelectAddTeamCategory.dart';
import 'package:sheeps_app/profile/AddTeam/SelectAddTeamField.dart';
import 'package:sheeps_app/profile/models/ImgProviderForAddTeam.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class AddTeam extends StatefulWidget {
  @override
  _AddTeamState createState() => _AddTeamState();
}

class _AddTeamState extends State<AddTeam> {
  int variableSet = 0;
  ScrollController _scrollController;
  double sizeUnit = 1;
  double width;
  double height;

  ImgProviderForAddTeam _filesProvider;
  ModelAddTeam _AddTeam;
  FormData formData;

  final NameController = TextEditingController();
  final TeamIntroduceController = TextEditingController();

  bool ValidationFlag1 = false;

  String teamNameErrorText = '';

  bool Validation_OnlyString(String value, String target) {
    int utf8Length = utf8.encode(NameController.text).length;
    setState(() {
      if (target == "팀명") {
        ValidationFlag1 = false;
        RegExp regExp = new RegExp(r'[$/!@#<>?":`~;[\]\\|=+)(*&^%\s-]');//허용문자 _.

        if (regExp.hasMatch(value)) {
          ValidationFlag1 = true;
          teamNameErrorText = "특수문자가 들어갈 수 없어요.";
        } else {
          if (value.length < 2) {
            ValidationFlag1 = true;
            teamNameErrorText = "너무 짧아요. 2자 이상 작성해주세요.";
          } else if (value.length > 15 || utf8Length > 30) {
            ValidationFlag1 = true;
            teamNameErrorText = "너무 길어요. 한글 10자 또는 영어 15자 이하로 작성해 주세요.";
          } else {
            teamNameErrorText = '';
          }
        }
      }
    });
    return ValidationFlag1;
  }

  bool _isReady;//서버중복신호방지
  @override
  void initState(){
    _isReady = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(_filesProvider == null)  _filesProvider = Provider.of<ImgProviderForAddTeam>(context);
    if(_AddTeam == null) _AddTeam = Provider.of<ModelAddTeam>(context);
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SheepsAppBar(
              context,
              '팀 만들기',
            backFunc: () {
                Navigator.pop(context, null);
            }
          ),
          body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12*sizeUnit, 0, 12*sizeUnit,0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height:20*sizeUnit),
                    RichText(
                      text: TextSpan(
                        style: SheepsTextStyle.h3(context),
                        children: <TextSpan>[
                          TextSpan(text: '팀명 '),
                          TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680")),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    Container(
                      child: TextField(
                        controller: NameController,
                        style: SheepsTextStyle.b3(context),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '팀명 입력',
                            hintStyle: SheepsTextStyle.hint4Profile(context),
                            isDense: true,
                            contentPadding: EdgeInsets.all(12*sizeUnit),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
                            ),
                            errorText: ValidationFlag1 ? teamNameErrorText : null
                        ),
                        onChanged: (text){
                          if(!Validation_OnlyString(text, "팀명")) {
                            _AddTeam.ChangeTeamName(text);
                            CheckForAddTeam(_AddTeam);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20*sizeUnit),
                    RichText(
                      text: TextSpan(
                        style: SheepsTextStyle.h3(context),
                        children: <TextSpan>[
                          TextSpan(text: '팀 분류 '),
                          TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680")),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectAddTeamCategory()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForAddTeam(_AddTeam);
                        });
                      },
                      child: Container(
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8),
                          border: Border.all(color: hexToColor("#CCCCCC")),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12*sizeUnit),
                                  child: Text(
                                    '${_AddTeam.getTeamCategory()==null?"팀 분류 선택":"${_AddTeam.getTeamCategory()}"}',
                                    style: _AddTeam.getTeamCategory()==null?SheepsTextStyle.hint4Profile(context):SheepsTextStyle.b3(context),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8*sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon2,
                                width: 12*sizeUnit,
                                height: 12*sizeUnit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20*sizeUnit),
                    RichText(
                      text: TextSpan(
                        style: SheepsTextStyle.h3(context),
                        children: <TextSpan>[
                          TextSpan(text: '분야 '),
                          TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
                        ],
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectAddTeamField()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForAddTeam(_AddTeam);
                        });
                      },
                      child: Container(
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8),
                          border: Border.all(color: hexToColor("#CCCCCC")),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12*sizeUnit),
                                  child: Text(
                                    '${_AddTeam.getTeamField()==null?"팀 분야 선택":"${_AddTeam.getTeamField()}"}',
                                    style: _AddTeam.getTeamField()==null?SheepsTextStyle.hint4Profile(context):SheepsTextStyle.b3(context),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8*sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon2,
                                width: 12*sizeUnit,
                                height: 12*sizeUnit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20*sizeUnit),
                    RichText(
                      text: TextSpan(
                        style: SheepsTextStyle.h3(context),
                        children: <TextSpan>[
                          TextSpan(text: '지역 '),
                          TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
                        ],
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectAddTeamArea()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForAddTeam(_AddTeam);
                        });
                      },
                      child: Container(
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8),
                          border: Border.all(color: hexToColor("#CCCCCC")),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12*sizeUnit),
                                  child: Text(
                                    '${_AddTeam.getTeamArea()==''?"지역 선택":"${_AddTeam.getTeamArea()}"}',
                                    style: _AddTeam.getTeamArea()==''?SheepsTextStyle.hint4Profile(context):SheepsTextStyle.b3(context),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8*sizeUnit),
                              child: SvgPicture.asset(
                                svgGreyNextIcon2,
                                width: 12*sizeUnit,
                                height: 12*sizeUnit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20*sizeUnit),
                    RichText(
                      text: TextSpan(
                        style: SheepsTextStyle.h3(context),
                        children: <TextSpan>[
                          TextSpan(text: '팀 소개 '),
                          TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
                        ],
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    TextField(
                      controller: TeamIntroduceController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      maxLength: 500,
                      style: SheepsTextStyle.b3(context),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintStyle: SheepsTextStyle.hint4Profile(context),
                        hintText: '팀 소개 입력',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
                        ),
                      ),
                      onChanged: (text){
                        _AddTeam.ChangeTeamIntroduce(text);
                        CheckForAddTeam(_AddTeam);
                      },
                    ),
                    SizedBox(height: 20*sizeUnit),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: SheepsTextStyle.h3(context),
                            children: <TextSpan>[
                              TextSpan(text: '팀 지원 여부 '),
                              TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Transform.scale(
                          scale: 0.7,
                          child: CupertinoSwitch(
                            value:_AddTeam.IfSupportTeam,
                            onChanged: (bool value) {
                              _AddTeam.ChangeIfSupportTeam();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20*sizeUnit),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: SheepsTextStyle.h3(context),
                            children: <TextSpan>[
                              TextSpan(text: '사진 '),
                              TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
                            ],
                          ),
                        ),
                        SizedBox(width: 8*sizeUnit),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '최소 1장, 최대 5장의 프로필 사진을 업로드 해주세요.',
                            style: SheepsTextStyle.info2(context),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8*sizeUnit),
                    DragAndDropGridView(
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 3,
                      ),

                      itemBuilder: (context, index) => Card(
                        elevation: 0.8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8*sizeUnit)
                        ),
                        child: LayoutBuilder(builder: (context, costrains) {
                          if (variableSet == 0) {
                            height = costrains.maxHeight;
                            width = costrains.maxWidth;
                            variableSet++;
                          }
                          if (index == _filesProvider.filesList.length -1 &&
                              _filesProvider.filesList.length != 6) {
                            return GestureDetector(
                                child: Container(
                                  width: 108*sizeUnit,
                                  height: 108*sizeUnit,
                                  decoration: BoxDecoration(
                                    color: hexToColor("#EEEEEE"),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      svgGreyPlusIcon,
                                      width: 16*sizeUnit,
                                      height: 16*sizeUnit,
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                                  //await BottomSheetMoreScreen(context);
                                  await SheepsBottomSheetForImg(
                                    context,
                                    cameraFunc: () async{
                                      PickedFile f = await ImagePicker()
                                          .getImage(source: ImageSource.camera); //camera -> gallery
                                      if (f == null) return;
                                      _filesProvider.addFiles(File(f.path));
                                      setState(() {

                                      });
                                      Navigator.pop(context);
                                      return;
                                    },
                                    galleryFunc: () async{
                                      PickedFile f = await ImagePicker()
                                          .getImage(source: ImageSource.gallery); //camera -> gallery
                                      if (f == null) return;
                                      _filesProvider.addFiles(File(f.path));
                                      setState(() {

                                      });
                                      Navigator.pop(context);
                                      return;
                                    },
                                  );
                                }
                            );
                          }

                          return GestureDetector(
                              child: Container(
                                width: 108*sizeUnit,
                                height: 108*sizeUnit,
                                decoration: BoxDecoration(
                                    color: hexToColor("#EEEEEE"),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    image: DecorationImage(
                                        image: FileImage(_filesProvider.filesList[index]),
                                        fit: BoxFit.cover)),
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 4*sizeUnit,
                                        right: 4*sizeUnit,
                                        child: Container(
                                          width: 16*sizeUnit,
                                          height: 16*sizeUnit,
                                          decoration: BoxDecoration(
                                              color: hexToColor("#61C680"), borderRadius: BorderRadius.circular(8*sizeUnit)),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              svgTrashCan,
                                              color: Colors.white,
                                              height: 10*sizeUnit,
                                              width: 10*sizeUnit,
                                            ),
                                          ),
                                        )
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                                _filesProvider.removeFile(targetFile: _filesProvider.filesList[index]);
                                setState(() {

                                });
                              });
                        }),
                      ),
                      itemCount:  _filesProvider.filesList.length !=6? _filesProvider.filesList.length: _filesProvider.filesList.length-1,

                      onWillAccept: (oldIndex, newIndex) => true,
                      onReorder: (oldIndex, newIndex) {

                        if(oldIndex != _filesProvider.filesList.length-1&&newIndex !=_filesProvider.filesList.length-1) {
                          // You can also implement on your own logic on reorderable
                          final temp = _filesProvider.filesList[oldIndex];
                          _filesProvider.filesList[oldIndex] =
                          _filesProvider.filesList[newIndex];
                          _filesProvider.filesList[newIndex] = temp;
                        }

                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20*sizeUnit),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '인증',
                            style: SheepsTextStyle.h3(context),
                          ),
                        ),
                        SizedBox(width: 8*sizeUnit),
                        Text(
                          '기업 형태, 각종 인증 등',
                          style: SheepsTextStyle.info2(context),
                        )
                      ],
                    ),
                    SizedBox(
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _AddTeam.IdentifiedList.length,
                          itemBuilder: (BuildContext context, int index) => Padding(
                            padding: EdgeInsets.only(top:8*sizeUnit),
                            child: Row(
                              children: [
                                Container(
                                  width: 268*sizeUnit,
                                  height: 40*sizeUnit,
                                  decoration: BoxDecoration(
                                    borderRadius: new BorderRadius.circular(8),
                                    border: Border.all(color: hexToColor("#CCCCCC")),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 12*sizeUnit),
                                            child: Text(
                                              '${_AddTeam.getIdentifiedListComponent(index)}',
                                              style: SheepsTextStyle.b3(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          FocusScopeNode currentFocus = FocusScope.of(context);
                                          if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                                          _AddTeam.RemoveIdentifiedListAndFile(index);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 12*sizeUnit),
                                          child: SvgPicture.asset(
                                            svgGreyCircularCancelIcon,
                                            width: 12*sizeUnit,
                                            height: 12*sizeUnit,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SheepsbuildIdentifiedState(context,_AddTeam.IdentifiedStateList[index]),
                              ],
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    _AddTeam.IdentifiedList.length < 10 ? GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                        _AddTeam.ChangeFlagForIdentifiedOn(true);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddIdentifiedForAddTeam()) // SecondRoute를 생성하여 적재
                        );
                      },
                      child: Container(
                        width: 100*sizeUnit,
                        height: 32*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                          boxShadow: [
                            new BoxShadow(
                              offset: Offset(1*sizeUnit,1*sizeUnit),
                              color: Color.fromRGBO(116, 125, 130, 0.2),
                              blurRadius: 4*sizeUnit,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              svgGreenPlusIcon,
                              width: 12*sizeUnit,
                              height: 12*sizeUnit,
                            ),
                            SizedBox(width: 8*sizeUnit),
                            Text(
                              '인증 추가',
                              style: SheepsTextStyle.b3(context),
                            ),
                          ],
                        ),
                      ),
                    ) :
                    SizedBox(),
                    SizedBox(height: 40*sizeUnit,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '수행 내역',
                            style: SheepsTextStyle.h3(context),
                          ),
                        ),
                        SizedBox(width: 8*sizeUnit),
                        Text(
                          '프로젝트, 과제 용역 등',
                          style: SheepsTextStyle.info2(context),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _AddTeam.ProjectList.length,
                          itemBuilder: (BuildContext context, int index) => Padding(
                            padding: EdgeInsets.only(top:8*sizeUnit),
                            child: Row(
                              children: [
                                Container(
                                  width: 268*sizeUnit,
                                  height: 40*sizeUnit,
                                  decoration: BoxDecoration(
                                    borderRadius: new BorderRadius.circular(8),
                                    border: Border.all(color: hexToColor("#CCCCCC")),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 12*sizeUnit),
                                            child: Text(
                                              '${_AddTeam.getProjectListComponent(index)}',
                                              style: SheepsTextStyle.b3(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          FocusScopeNode currentFocus = FocusScope.of(context);
                                          if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                                          _AddTeam.RemoveProjectListAndFile(index);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 12*sizeUnit),
                                          child: SvgPicture.asset(
                                            svgGreyCircularCancelIcon,
                                            width: 12*sizeUnit,
                                            height: 12*sizeUnit,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SheepsbuildIdentifiedState(context, _AddTeam.ProjectStateList[index]),
                              ],
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    _AddTeam.ProjectList.length < 10 ? GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                        _AddTeam.ChangeFlagForProjectOn(true);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddProjectForAddTeam()) // SecondRoute를 생성하여 적재
                        );
                      },
                      child: Container(
                        width: 125*sizeUnit,
                        height: 32*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                          boxShadow: [
                            new BoxShadow(
                              offset: Offset(1,1),
                              color: Color.fromRGBO(116, 125, 130, 0.2),
                              blurRadius: 4*sizeUnit,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16*sizeUnit),
                            SvgPicture.asset(
                              svgGreenPlusIcon,
                              width: 12*sizeUnit,
                              height: 12*sizeUnit,
                            ),
                            SizedBox(width: 8*sizeUnit),
                            Text(
                              '수행 내역 추가',
                              style: SheepsTextStyle.b3(context),
                            ),
                          ],
                        ),
                      ),
                    ) :
                    SizedBox(),
                    SizedBox(height: 40*sizeUnit,),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '수상 내역',
                        style: SheepsTextStyle.h3(context),
                      ),
                    ),
                    SizedBox(
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _AddTeam.TeamAwardList.length,
                          itemBuilder: (BuildContext context, int index) => Padding(
                            padding: EdgeInsets.only(top:8*sizeUnit),
                            child: Row(
                              children: [
                                Container(
                                  width: 268*sizeUnit,
                                  height: 40*sizeUnit,
                                  decoration: BoxDecoration(
                                    borderRadius: new BorderRadius.circular(8),
                                    border: Border.all(color: hexToColor("#CCCCCC")),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 12*sizeUnit),
                                            child: Text(
                                              '${_AddTeam.getTeamAwardListComponent(index)}',
                                              style: SheepsTextStyle.b3(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          FocusScopeNode currentFocus = FocusScope.of(context);
                                          if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                                          _AddTeam.RemoveTeamAwardListAndFile(index);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 12*sizeUnit),
                                          child: SvgPicture.asset(
                                            svgGreyCircularCancelIcon,
                                            width: 12*sizeUnit,
                                            height: 12*sizeUnit,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SheepsbuildIdentifiedState(context,_AddTeam.TeamAwardStateList[index]),
                              ],
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    _AddTeam.TeamAwardList.length < 10 ? GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
                        _AddTeam.ChangeFlagForTeamAwardOn(true);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddTeamAwardForAddTeam()) // SecondRoute를 생성하여 적재
                        );
                      },
                      child: Container(
                        width: 125*sizeUnit,
                        height: 32*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8*sizeUnit),
                          boxShadow: [
                            new BoxShadow(
                              offset: Offset(1,1),
                              color: Color.fromRGBO(116, 125, 130, 0.2),
                              blurRadius: 4*sizeUnit,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16*sizeUnit),
                            SvgPicture.asset(
                              svgGreenPlusIcon,
                              width: 12*sizeUnit,
                              height: 12*sizeUnit,
                            ),
                            SizedBox(width: 8*sizeUnit),
                            Text(
                              '수상 이력 추가',
                              style: SheepsTextStyle.b3(context),
                            ),
                          ],
                        ),
                      ),
                    ) :
                    SizedBox(),
                    SizedBox(height: 40*sizeUnit,),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: () async {
              if(_isReady){
                if(_AddTeam.AddTeamComplete == true) {
                  _isReady = false;
                  Dio dio = new Dio();
                  dio.options.headers = {
                    'Content-Type' : 'application/json',
                    'user' : GlobalProfile.loggedInUser.userID,
                  };

                  Team addTeam;

                  Future.microtask(() async {
                    formData = new FormData.fromMap({
                      "leaderid" : GlobalProfile.loggedInUser.userID,
                      "name" :  _AddTeam.TeamName,
                      "information": _AddTeam.TeamIntroduce,
                      "category" : _AddTeam.TeamCategory,
                      "part":_AddTeam.TeamField ,
                      "location" : _AddTeam.TeamArea.split(' ')[0],
                      "sublocation" :  _AddTeam.TeamArea.split(' ')[ _AddTeam.TeamArea.split(' ').length-1],
                      "possiblejoin": _AddTeam.IfSupportTeam == false ? 0 : 1,

                    });


                    for(int i = 0 ; i < _filesProvider.filesList.length - 1; ++i){//파일 형식에 대한 처릴 ex) png, jpeg
                      String filePath = _filesProvider.filesList[i].path;
                      formData.files.add(MapEntry("TeamPhoto",MultipartFile.fromFileSync(filePath, filename: getFileName(i, filePath)) ));
                    }

                    for(int i = 0 ; i < _AddTeam.IdentifiedFile.length ; ++i){
                      formData.fields.add(MapEntry("tauthcontents", _AddTeam.IdentifiedList[i]));

                      String filePath = _AddTeam.IdentifiedFile[i].path;
                      formData.files.add(MapEntry("TAuthAuthImg",MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }

                    for(int i = 0 ; i < _AddTeam.ProjectFile.length; ++i){
                      formData.fields.add(MapEntry("tperformancecontents", _AddTeam.ProjectList[i]));

                      String filePath = _AddTeam.ProjectFile[i].path;
                      formData.files.add(MapEntry("TPerformanceAuthImg",MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }

                    for(int i = 0 ; i < _AddTeam.AwardFile.length; ++i){
                      formData.fields.add(MapEntry("twincontents", _AddTeam.TeamAwardList[i]));

                      String filePath = _AddTeam.AwardFile[i].path;
                      formData.files.add(MapEntry("TWinAuthImg",MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }

                    EasyLoading.show(status: "팀 생성 중...");

                    String url = kReleaseMode ? "/Team/Insert" : "/Team/Insert";

                    var res;
                    try{
                      res = await dio.post( ApiProvider().getImgUrl + url, data: formData);
                    } on DioError catch (e) {
                      EasyLoading.dismiss();
                      throw FetchDataException(e.message);
                    }

                    if(res != null){
                      addTeam = Team.fromJson(res.data);
                      GlobalProfile.teamProfile.insert(0, addTeam);
                    }else{
                      addTeam = null;
                    }
                    EasyLoading.dismiss();
                  }).then((value) => _AddTeam.resetAddTeam());

                  showSheepsDialog(
                    context: context,
                    title: '팀 생성 완료!',
                    description: '팀 프로필 추가가 완료되었어요!\n 이제 쉽스에서 팀원들을 모아보세요!',
                    isCancelButton: false,
                    isBarrierDismissible: false,
                  ).then((val){
                    Navigator.pop(context, addTeam);
                  });
                }
              }
            },
            child: Container(
                height: 60*sizeUnit,
                decoration: BoxDecoration(
                  color: _AddTeam.AddTeamComplete == true ? kPrimaryColor : hexToColor('#CCCCCC'),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '입력 완료',
                    style: SheepsTextStyle.button1(context),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  void CheckForAddTeam(ModelAddTeam _AddTeam) {
    if(_AddTeam.TeamName != null && _AddTeam.TeamCategory != null && _AddTeam.TeamField != null && _AddTeam.TeamArea != null && _AddTeam.TeamIntroduce != null &&
        _AddTeam.TeamName != "" && _AddTeam.TeamCategory != "" && _AddTeam.TeamField != "" && _AddTeam.TeamArea != "" && _AddTeam.TeamIntroduce != "") {
      _AddTeam.ChangeAddTeamComplete(true);
    } else {
      _AddTeam.ChangeAddTeamComplete(false);
    }
  }
}
