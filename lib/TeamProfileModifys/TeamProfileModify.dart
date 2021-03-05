import 'dart:io';
import 'dart:convert';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:dio/dio.dart' as D;
import 'package:dio/dio.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' show get;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/TeamProfileModifys/AddBadgeForTeamProfileModify.dart';
import 'package:sheeps_app/TeamProfileModifys/AddIdentified.dart';
import 'package:sheeps_app/TeamProfileModifys/AddProject.dart';
import 'package:sheeps_app/TeamProfileModifys/AddTeamAward.dart';
import 'package:sheeps_app/TeamProfileModifys/SelectTeamArea.dart';
import 'package:sheeps_app/TeamProfileModifys/SelectTeamCategory.dart';
import 'package:sheeps_app/TeamProfileModifys/SelectTeamField.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/constants.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/TeamProfileModifys/model/DummyForTeamProfileModify.dart';
import 'package:sheeps_app/TeamProfileModifys/model/ImgProviderForTeamProfileModify.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';



class TeamProfileModify extends StatefulWidget {
  final Team team;

  TeamProfileModify({Key key, @required this.team}) : super(key : key);

  @override
  _AddTeamState createState() => _AddTeamState();
}

class _AddTeamState extends State<TeamProfileModify> {
  int variableSet = 0;
  ScrollController _scrollController;
  double sizeUnit = 1;
  double width;
  double height;

  D.FormData formData;
  D.Response dioRes;

  static var NameController;
  static var TeamIntroduceController;

  ModelTeamProfile _AddTeam;
  ImgProviderForTeamProfileModify _filesProvider;

  bool _isReady;//서버중복신호방지

  Team modifyTeam;

  @override
  void initState() {
    _isReady = true;
    // TODO: implement initState
    super.initState();
    _AddTeam = Provider.of<ModelTeamProfile>(context, listen: false);
    _AddTeam.resetModelAddTeam();
    _filesProvider = Provider.of<ImgProviderForTeamProfileModify>(context, listen: false);

    _filesProvider.filesList.clear();
    File f;
    _filesProvider.filesList.add(f);


    Future.microtask(() async {
      if(widget.team.profileUrlList[0] != 'BasicImage') {
        for(int i = 0; i < widget.team.profileUrlList.length; i++) {
          var response = await get(widget.team.profileUrlList[i]);
          var documentDirectory = await getApplicationDocumentsDirectory();
          var firstPath = documentDirectory.path + "/images";
          var filePathAndName = documentDirectory.path + '/images/pic' + i.toString() + getMimeType(widget.team.profileUrlList[i]);
          await Directory(firstPath).create(recursive: true);
          File file2 = new File(filePathAndName);
          file2.writeAsBytesSync(response.bodyBytes);
          _filesProvider.addFiles(File(filePathAndName));
        }
      }
    }).then((value) {
      setState(() {

      });
    });

    String name = widget.team.name;
    NameController = TextEditingController(text: name);
    TeamIntroduceController = widget.team.information != null ? TextEditingController(text: widget.team.information) : TextEditingController();

    _AddTeam.SetData(widget.team);
    _AddTeam.CheckMyTeamModify();
  }

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
      } else {
        ValidationFlag1 = false;
      }
    });
    return ValidationFlag1;
  }



  @override
  Widget build(BuildContext context) {
    _filesProvider = Provider.of<ImgProviderForTeamProfileModify>(context);
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
        if (!currentFocus.hasPrimaryFocus) {
          if(Platform.isIOS){
            FocusManager.instance.primaryFocus.unfocus();
          } else{
            currentFocus.unfocus();
          }
        }
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: SheepsAppBar(context,'팀 프로필 수정',
            backFunc: (){
              Navigator.pop(context, null);
            },
          ),
          body: ConditionalWillPopScope(
            shouldAddCallbacks: true,
            onWillPop: () {
              Navigator.pop(context, null);
              return;
            },
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
                          TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
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
                          if(!Validation_OnlyString(text, "팀명")){
                            _AddTeam.ChangeTeamName(text);
                            CheckForTeamModify(_AddTeam);
                          } else {
                            _AddTeam.ChangeAddTeamComplete(false);
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
                          TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
                        ],
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                        if (!currentFocus.hasPrimaryFocus) {
                          if(Platform.isIOS){
                            FocusManager.instance.primaryFocus.unfocus();
                          } else{
                            currentFocus.unfocus();
                          }
                        }

                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectTeamCategory()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForTeamModify(_AddTeam);
                          setState(() {

                          });
                        });
                      },
                      child: Container(
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8*sizeUnit),
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
                        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                        if (!currentFocus.hasPrimaryFocus) {
                          if(Platform.isIOS){
                            FocusManager.instance.primaryFocus.unfocus();
                          } else{
                            currentFocus.unfocus();
                          }
                        }
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectTeamField()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForTeamModify(_AddTeam);
                          setState(() {

                          });
                        });
                      },
                      child: Container(
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8*sizeUnit),
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
                                    '${_AddTeam.TeamField==null?"팀 분야 선택":"${_AddTeam.TeamField}"}',
                                    style: _AddTeam.TeamField==null?SheepsTextStyle.hint4Profile(context):SheepsTextStyle.b3(context),
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
                        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                        if (!currentFocus.hasPrimaryFocus) {
                          if(Platform.isIOS){
                            FocusManager.instance.primaryFocus.unfocus();
                          } else{
                            currentFocus.unfocus();
                          }
                        }
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectTeamArea()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          CheckForTeamModify(_AddTeam);
                          setState(() {

                          });
                        });
                      },
                      child: Container(
                        height: 40*sizeUnit,
                        decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular(8*sizeUnit),
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
                                    '${_AddTeam.TeamArea==''?"지역 선택":"${_AddTeam.TeamArea}"}',
                                    style: _AddTeam.TeamArea==''?SheepsTextStyle.hint4Profile(context):SheepsTextStyle.b3(context),
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
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: SheepsTextStyle.h3(context),
                            children: <TextSpan>[
                              TextSpan(text: '팀 모집하기 '),
                              TextSpan(text: '*', style: TextStyle(color: hexToColor("#61C680"))),
                            ],
                          ),
                        ),
                        Spacer(),
                        Transform.scale(
                          scale: 0.9,
                          child: CupertinoSwitch(
                            value:_AddTeam.IfSupportTeam,
                            onChanged: (bool value) {
                              _AddTeam.ChangeIfSupportTeam(!_AddTeam.IfSupportTeam);
                              setState(() {

                              });
                            },
                          ),
                        ),
                      ],
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(width: 1,color: hexToColor(("#CCCCCC"))),
                          ),
                          hintText: '팀 소개 입력',
                          hintStyle: SheepsTextStyle.hint4Profile(context),
                      ),
                      onChanged: (text){
                        _AddTeam.ChangeTeamIntroduce(text);
                        CheckForTeamModify(_AddTeam);
                      },
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
                        SizedBox(width: 8*sizeUnit,),
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
                                onTap:() async {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if(!currentFocus.hasPrimaryFocus){currentFocus.unfocus();}//텍스트 포커스 해제
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
                                //     () async {
                                //   await BottomSheetMoreScreen(context, screenWidth, screenHeight);
                                // }
                            );
                          }

                          return GestureDetector(
                              child:
                              Container(
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
                                FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                                if (!currentFocus.hasPrimaryFocus) {
                                  if(Platform.isIOS){
                                    FocusManager.instance.primaryFocus.unfocus();
                                  } else{
                                    currentFocus.unfocus();
                                  }
                                }
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '뱃지',
                        style: SheepsTextStyle.h3(context),
                      ),
                    ),
                    SizedBox(height: 8*sizeUnit),
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                        if (!currentFocus.hasPrimaryFocus) {
                          if(Platform.isIOS){
                            FocusManager.instance.primaryFocus.unfocus();
                          } else{
                            currentFocus.unfocus();
                          }
                        }
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddBadgeForTeamProfileModify(team: widget.team,)) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          setState(() {

                          });
                        });
                      },
                      child: Row(
                        children: [
                          widget.team.badge1 != 0 //test
                              ? Container(
                            width: 108*sizeUnit,
                            height: 108*sizeUnit,
                            child: ClipRRect(
                              borderRadius:
                              new BorderRadius.circular(8*sizeUnit),
                              child: SvgPicture.asset(
                                ReturnTeamBadgeSVG(widget.team.badge1),
                              ),
                            ),
                          )
                              : Container(
                            height: 108*sizeUnit,
                            width: 108*sizeUnit,
                            decoration: BoxDecoration(
                              color: hexToColor('#EEEEEE'),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                svgGreyPlusIcon,
                                width: 16*sizeUnit,
                                height: 16*sizeUnit,
                              ),
                            ),
                          ),
                          SizedBox(width: 6*sizeUnit),
                          widget.team.badge2 != 0 //test
                              ? Container(
                            width: 108*sizeUnit,
                            height: 108*sizeUnit,
                            child: ClipRRect(
                              borderRadius:
                              new BorderRadius.circular(8*sizeUnit),
                              child: SvgPicture.asset(
                                ReturnTeamBadgeSVG(widget.team.badge2),
                              ),
                            ),
                          )
                              : Container(
                            height: 108*sizeUnit,
                            width: 108*sizeUnit,
                            decoration: BoxDecoration(
                              color: hexToColor('#EEEEEE'),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                svgGreyPlusIcon,
                                width: 16*sizeUnit,
                                height: 16*sizeUnit,
                              ),
                            ),
                          ),
                          SizedBox(width: 6*sizeUnit),
                          widget.team.badge3 != 0 //test
                              ? Container(
                            width: 108*sizeUnit,
                            height: 108*sizeUnit,
                            child: ClipRRect(
                              borderRadius:
                              new BorderRadius.circular(8*sizeUnit),
                              child: SvgPicture.asset(
                                ReturnTeamBadgeSVG(widget.team.badge3),
                              ),
                            ),
                          )
                              : Container(
                            height: 108*sizeUnit,
                            width: 108*sizeUnit,
                            decoration: BoxDecoration(
                              color: hexToColor('#EEEEEE'),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                svgLockIconGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                    borderRadius: new BorderRadius.circular(8*sizeUnit),
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
                                          _AddTeam.RemoveIdentifiedListAndFile(index);
                                          setState(() {

                                          });
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
                    _AddTeam.IdentifiedList != null &&  _AddTeam.IdentifiedList.length < 10 ?
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                        if (!currentFocus.hasPrimaryFocus) {
                          if(Platform.isIOS){
                            FocusManager.instance.primaryFocus.unfocus();
                          } else{
                            currentFocus.unfocus();
                          }
                        }
                        _AddTeam.ChangeFlagForIdentifiedOn(true);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddIdentified()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          setState(() {

                          });
                        });
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
                            SizedBox(width: 8*sizeUnit,),
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
                                    borderRadius: new BorderRadius.circular(8*sizeUnit),
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
                                          FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                                          if (!currentFocus.hasPrimaryFocus) {
                                            if(Platform.isIOS){
                                              FocusManager.instance.primaryFocus.unfocus();
                                            } else{
                                              currentFocus.unfocus();
                                            }
                                          }
                                          _AddTeam.RemoveProjectListAndFile(index);
                                          setState(() {

                                          });
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
                    _AddTeam.ProjectList != null && _AddTeam.ProjectList.length < 10 ?
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                        if (!currentFocus.hasPrimaryFocus) {
                          if(Platform.isIOS){
                            FocusManager.instance.primaryFocus.unfocus();
                          } else{
                            currentFocus.unfocus();
                          }
                        }
                        _AddTeam.ChangeFlagForProjectOn(true);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddProject()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          setState(() {

                          });
                        });
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
                            SizedBox(width: 16*sizeUnit,),
                            SvgPicture.asset(
                              svgGreenPlusIcon,
                              width: 12*sizeUnit,
                              height: 12*sizeUnit,
                            ),
                            SizedBox(width: 8*sizeUnit,),
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
                        '수상 경력',
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
                                    borderRadius: new BorderRadius.circular(8*sizeUnit),
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
                                          FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                                          if (!currentFocus.hasPrimaryFocus) {
                                            if(Platform.isIOS){
                                              FocusManager.instance.primaryFocus.unfocus();
                                            } else{
                                              currentFocus.unfocus();
                                            }
                                          }
                                          _AddTeam.RemoveTeamAwardListAndFile(index);
                                          setState(() {

                                          });
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
                    _AddTeam.TeamAwardList != null && _AddTeam.TeamAwardList.length < 10 ?
                    GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                        if (!currentFocus.hasPrimaryFocus) {
                          if(Platform.isIOS){
                            FocusManager.instance.primaryFocus.unfocus();
                          } else{
                            currentFocus.unfocus();
                          }
                        }
                        _AddTeam.ChangeFlagForTeamAwardOn(true);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddTeamAward()) // SecondRoute를 생성하여 적재
                        ).then((value){
                          setState(() {

                          });
                        });
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
                            SizedBox(width: 16*sizeUnit,),
                            SvgPicture.asset(
                              svgGreenPlusIcon,
                              width: 12*sizeUnit,
                              height: 12*sizeUnit,
                            ),
                            SizedBox(width: 8*sizeUnit,),
                            Text(
                              '수상 경력 추가',
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
              FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
              if (!currentFocus.hasPrimaryFocus) {
                if(Platform.isIOS){
                  FocusManager.instance.primaryFocus.unfocus();
                } else{
                  currentFocus.unfocus();
                }
              }
              if(_isReady){
                if(IfModifyOk()) {
                  _isReady = false;//서버중복신호방지
                  D.Dio dio = new D.Dio();
                  dio.options.headers = {
                    'Content-Type' : 'application/json',
                    'user' : GlobalProfile.loggedInUser == null ? 'sheepsToken' : GlobalProfile.loggedInUser.userID.toString()
                  };

                  Future.microtask(() async {
                    formData = new D.FormData.fromMap({
                      "teamid" : widget.team.id,
                      "name" :  _AddTeam.TeamName,
                      "information": _AddTeam.TeamIntroduce,
                      "category" : _AddTeam.TeamCategory,
                      "part":_AddTeam.TeamField ,
                      "location" : _AddTeam.TeamArea.split(' ')[0],
                      "sublocation" : _AddTeam.TeamArea.split(' ').length == 1 ? '' : _AddTeam.TeamArea.split(' ')[1],
                      "possiblejoin": _AddTeam.IfSupportTeam == false ? 0 : 1,
                      "badge1": widget.team.badge1,
                      "badge2": widget.team.badge2,
                      "badge3": widget.team.badge3,
                    });


                    for(int i = 0 ; i < _filesProvider.filesList.length - 1; ++i){//파일 형식에 대한 처릴 ex) png, jpeg
                      String filePath = _filesProvider.filesList[i].path;
                      formData.files.add(MapEntry("TeamPhoto",D.MultipartFile.fromFileSync(filePath, filename: getFileName(i, filePath)) ));
                    }

                    for(int i = 0 ; i < _AddTeam.IdentifiedList.length ; ++i){
                      formData.fields.add(MapEntry("tauthcontents", _AddTeam.IdentifiedList[i]));
                    }
                    for(int i = 0; i < _AddTeam.IdentifiedFile.length; i++) {
                      String filePath = _AddTeam.IdentifiedFile[i].path;
                      formData.files.add(MapEntry("TAuthAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }

                    for(int i = 0 ; i < _AddTeam.ProjectFile.length; ++i){
                      formData.fields.add(MapEntry("tperformancecontents", _AddTeam.ProjectList[i]));
                    }
                    for(int i = 0; i < _AddTeam.ProjectFile.length; i++) {
                      String filePath = _AddTeam.ProjectFile[i].path;
                      formData.files.add(MapEntry("TPerformanceAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }

                    for(int i = 0 ; i < _AddTeam.AwardFile.length; ++i){
                      formData.fields.add(MapEntry("twincontents", _AddTeam.TeamAwardList[i]));
                    }
                    for(int i = 0; i < _AddTeam.AwardFile.length; i++) {
                      String filePath = _AddTeam.AwardFile[i].path;
                      formData.files.add(MapEntry("TWinAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }

                    EasyLoading.show(status: "팀 프로필 수정 중...");

                    var url = !kReleaseMode ? '/Team/ProfileModify' : '/Team/ProfileModify';

                    try{
                      dioRes = await dio.post(ApiProvider().getImgUrl + url, data: formData);
                    } on DioError catch (e) {
                      EasyLoading.dismiss();
                      throw FetchDataException(e.message);
                    }

                    modifyTeam = Team.fromJson(dioRes.data);

                    EasyLoading.dismiss();

                    showSheepsDialog(
                      context: context,
                      title: '팀 프로필 수정 완료!',
                      description: '팀 프로필 수정이 완료되었어요!',
                      isCancelButton: false,
                      isBarrierDismissible: false,
                    ).then((val){
                      Navigator.pop(context, modifyTeam);
                    });
                  });
                }
              }
            },
            child: Container(
                height: 60*sizeUnit,
                decoration: BoxDecoration(
                  color: IfModifyOk() ? kPrimaryColor : hexToColor('#CCCCCC'),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '수정 완료',
                    style: SheepsTextStyle.button1(context),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  bool IfModifyOk() {
    if(!ValidationFlag1 && _AddTeam.AddTeamComplete) {
      return true;
    } else {
      return false;
    }
  }

  // Future BottomSheetMoreScreen(BuildContext context, double screenWidth, double screenHeight) async {
  //   showModalBottomSheet(
  //       backgroundColor: Colors.transparent,
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return Container(
  //           color: Colors.transparent,
  //           width: screenWidth,
  //           height: screenHeight * (173 / 640),
  //           child: Column(
  //             children: [
  //               Container(
  //                 width: screenWidth * (336 / 360),
  //                 height: screenHeight * (97 / 640),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(8),
  //                   boxShadow: [
  //                     new BoxShadow(
  //                       color: Colors.grey.withOpacity(0.5),
  //                       spreadRadius: 0,
  //                       blurRadius: 4,
  //                       offset: Offset(1.5, 1.5),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     FlatButton(
  //                       onPressed: () async{
  //                         PickedFile f = await ImagePicker()
  //                             .getImage(source: ImageSource.gallery); //camera -> gallery
  //                         if (f == null) return;
  //                         _filesProvider.addFiles(File(f.path));
  //                         setState(() {
  //
  //                         });
  //                         Navigator.pop(context);
  //                         return;
  //                       },
  //                       child: Column(
  //                         children: [
  //                           SizedBox(
  //                             height: screenHeight * (8.6667 / 640),
  //                           ),
  //                           Row(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Icon(
  //                                 Icons.image,
  //                                 size: 25,
  //                               ),
  //                               SizedBox(
  //                                 width: screenWidth * (2 / 360),
  //                               ),
  //                               Container(
  //                                 height: screenHeight * (30 / 640),
  //                                 child: Padding(
  //                                   padding: EdgeInsets.only(
  //                                       bottom: screenHeight * (2 / 640)),
  //                                   child: Center(
  //                                     child: Text(
  //                                       "갤러리",
  //                                       textAlign: TextAlign.center,
  //                                       style: TextStyle(
  //                                           fontSize: screenWidth*( 16/360),
  //                                           color: Color(0xff222222)),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           SizedBox(
  //                             height: screenHeight * (8.6667 / 640),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Container(
  //                       width: screenWidth,
  //                       height: 1,
  //                       color: Color(0xfffafafa),
  //                     ),
  //                     FlatButton(
  //                       onPressed: () async{
  //                         PickedFile f = await ImagePicker()
  //                             .getImage(source: ImageSource.camera); //camera -> gallery
  //                         if (f == null) return;
  //                         _filesProvider.addFiles(File(f.path));
  //                         setState(() {
  //
  //                         });
  //                         Navigator.pop(context);
  //                         return;
  //                       },
  //                       child: Column(
  //                         children: [
  //                           SizedBox(
  //                             height: screenHeight * (8.6667 / 640),
  //                           ),
  //                           Row(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Spacer(),
  //                               Icon(
  //                                 Icons.photo_camera,
  //                                 size: 25,
  //                               ),
  //                               SizedBox(
  //                                 width: screenWidth * (2 / 360),
  //                               ),
  //                               Container(
  //                                 height: screenHeight * (30 / 640),
  //                                 child: Padding(
  //                                   padding: EdgeInsets.only(
  //                                       bottom: screenHeight * (2 / 640)),
  //                                   child: Center(
  //                                     child: Text(
  //                                       "카메라",
  //                                       textAlign: TextAlign.center,
  //                                       style: TextStyle(
  //                                           fontSize: screenWidth*( 16/360),
  //                                           color: Color(0xff222222)),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Spacer(),
  //                             ],
  //                           ),
  //                           SizedBox(
  //                             height: screenHeight * (8.6667 / 640),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Container(
  //                       width: screenWidth,
  //                       height: 1,
  //                       color: Color(0xfffafafa),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: screenHeight * (8 / 640),
  //               ),
  //               GestureDetector(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   width: screenWidth * (336 / 360),
  //                   height: screenHeight * (48 / 640),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(8),
  //                     boxShadow: [
  //                       new BoxShadow(
  //                         color: Colors.grey.withOpacity(0.5),
  //                         spreadRadius: 0,
  //                         blurRadius: 4,
  //                         offset: Offset(1.5, 1.5),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Center(
  //                     child: Text(
  //                       "취소",
  //                       style: TextStyle(
  //                           fontSize: screenWidth*( 16/360),
  //                           color: Color(0xff222222)),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: screenHeight * (20 / 640),
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  void CheckForTeamModify(ModelTeamProfile _AddTeam) {
    if(_AddTeam.TeamName != null && _AddTeam.TeamCategory != null && _AddTeam.TeamField != null && _AddTeam.TeamArea != null && _AddTeam.TeamIntroduce != null &&
        _AddTeam.TeamName != "" && _AddTeam.TeamCategory != "" && _AddTeam.TeamField != "" && _AddTeam.TeamArea != "" && _AddTeam.TeamIntroduce != "") {
      _AddTeam.ChangeAddTeamComplete(true);
    } else {
      _AddTeam.ChangeAddTeamComplete(false);
    }
  }
}

// Widget buildIdentifiedState(int value, double screenWidth, double screenHeight) {
//   if(value == 2) {
//     return Expanded(
//       child: Padding(
//         padding: EdgeInsets.only(left: screenWidth*0.01111),
//         child: Container(
//           width: screenWidth*0.16666,
//           height: 40*sizeUnit,
//           decoration: BoxDecoration(
//             color: hexToColor("#CCCCCC"),
//             borderRadius: new BorderRadius.circular(8*sizeUnit),
//             border: Border.all(color: hexToColor("#CCCCCC")),
//           ),
//           child: Align(
//             alignment: Alignment.center,
//             child: Text(
//               '인증 중',
//               style: TextStyle(
//                   fontSize: screenHeight*0.01875,
//                   color: Colors.white
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   else if(value == 1) {
//     return Expanded(
//       child: Padding(
//         padding: EdgeInsets.only(left: screenWidth*0.01111),
//         child: Container(
//           width: screenWidth*0.16666,
//           height: 40*sizeUnit,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: new BorderRadius.circular(8*sizeUnit),
//             border: Border.all(color: hexToColor("#61C680")),
//           ),
//           child: Align(
//             alignment: Alignment.center,
//             child: Text(
//               '인증 완료',
//               style: TextStyle(
//                 fontSize: screenHeight*0.01875,
//                 color: hexToColor("#61C680"),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   else {
//     return Expanded(
//       child: Padding(
//         padding: EdgeInsets.only(left: screenWidth*0.01111),
//         child: Container(
//           width: screenWidth*0.16666,
//           height: 40*sizeUnit,
//           decoration: BoxDecoration(
//             color: hexToColor("#888888"),
//             borderRadius: new BorderRadius.circular(8*sizeUnit),
//             border: Border.all(color: hexToColor("#888888")),
//           ),
//           child: Align(
//             alignment: Alignment.center,
//             child: Text(
//               '반려됨',
//               style: TextStyle(
//                   fontSize: screenHeight*0.01875,
//                   color: Colors.white
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
