import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart' as D;
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:sheeps_app/profile/modelsForPersonalImageList/MultipartImgFilesProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'AddAward.dart';
import 'AddCareer.dart';
import 'AddCertification.dart';
import 'SelectArea.dart';
import 'package:sheeps_app/profileModify/AddBadge.dart';
import 'package:sheeps_app/profileModify/SelectField.dart';
import 'package:sheeps_app/profileModify/SelectUniversity.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:http/http.dart' show get;
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

//분야 : 최종 분야 선택 시 MyprofileModify로 돌아오면서 데이터 전달되어야함 + 서브 분야 선택도 들어가야함
//지역 : 동일
//학력: 선택 후 1) 데이터가 뜨면서 2) UI rebuild 되어야함 / 우선은 인증 중이라고 떠야겟지
//경력: 버튼 눌렀을 때 -> 선택하는 페이지로 가서 정보 입력 후 정보들이 /로 나뉘어 명시되며 rebuild되어야 함

class MyProfileModify extends StatefulWidget {
  @override
  _MyProfileModifyState createState() => _MyProfileModifyState();
}

class _MyProfileModifyState extends State<MyProfileModify> {
  final NameController = TextEditingController(text: '${GlobalProfile.loggedInUser.name}');
  TextEditingController IntroduceController;

  MultipartImgFilesProvider _filesProvider;
  ModifiedProfile _ModifiedProfile;

  UserData user = GlobalProfile.loggedInUser;

  ScrollController _scrollController = ScrollController();
  String nameErrorText = '';

  bool ValidationFlagForPersonalName = false;
  bool ValidationFlagForPersonalIntroduce = false;

  D.FormData formData;

  D.Response res;

  var resu;

  bool _isReady;//서버중복신호방지

  void initState() {
    _isReady = true;//서버중복신호방지
    debugPrint('${GlobalProfile.loggedInUser}');
    IntroduceController = GlobalProfile.loggedInUser.information != null ? TextEditingController(text: '${GlobalProfile.loggedInUser.information}') : TextEditingController();
    _ModifiedProfile = Provider.of<ModifiedProfile>(context, listen: false);
    _ModifiedProfile.Reset();
    _filesProvider = Provider.of<MultipartImgFilesProvider>(context, listen: false);

    _filesProvider.filesList.clear();
    File f;
    _filesProvider.filesList.add(f);

    Future.microtask(() async {
      if (GlobalProfile.loggedInUser.profileUrlList != null && GlobalProfile.loggedInUser.profileUrlList[0] != 'BasicImage') {
        for (int i = 0; i < GlobalProfile.loggedInUser.profileUrlList.length; i++) {
          var response = await get(GlobalProfile.loggedInUser.profileUrlList[i]);
          var documentDirectory = await getApplicationDocumentsDirectory();
          var firstPath = documentDirectory.path + "/images";
          var filePathAndName = documentDirectory.path + '/images/pict' + i.toString() + getMimeType(GlobalProfile.loggedInUser.profileUrlList[i]);
          await Directory(firstPath).create(recursive: true);
          File file2 = new File(filePathAndName);
          file2.writeAsBytesSync(response.bodyBytes);
          _filesProvider.addFiles(File(filePathAndName));
        }
      }
    }).then((value) {
      setState(() {});
    });

    _ModifiedProfile.SetData(user);
    if( _ModifiedProfile.name != null &&  _ModifiedProfile.major != null &&  _ModifiedProfile.location != null &&  _ModifiedProfile.Introduce != null &&
        _ModifiedProfile.name != "" &&  _ModifiedProfile.major != "" &&   _ModifiedProfile.location != "" &&   _ModifiedProfile.Introduce != "") {
      _ModifiedProfile.ProfileModifyClear = true;
    } else {
      _ModifiedProfile.ProfileModifyClear = false;
    }
    setState(() {

    });
    super.initState();
  }

  void dispose() {
    _scrollController?.dispose();
    NameController?.dispose();
    IntroduceController?.dispose();
    super.dispose();
  }

  double sizeUnit = 1;

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    _filesProvider = Provider.of<MultipartImgFilesProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
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
          appBar: SheepsAppBar(context, '내 프로필 수정'),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12*sizeUnit, 0, 12*sizeUnit, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20*sizeUnit),
                  RichText(
                    text: TextSpan(
                      style: SheepsTextStyle.h3(context),
                      children: <TextSpan>[
                        TextSpan(text: '이름 '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: hexToColor("#61C680"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  buildNameController(_ModifiedProfile, user),
                  RichText(
                    text: TextSpan(
                      style: SheepsTextStyle.h3(context),
                      children: <TextSpan>[
                        TextSpan(text: '분야 '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: hexToColor("#61C680"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8*sizeUnit,
                  ),
                  buildSelectMainField(
                      context, _ModifiedProfile),
                  _ModifiedProfile.major == null || _ModifiedProfile.major == ""
                      ? SizedBox()
                      : buildSelectSubField(
                      context, _ModifiedProfile),
                  SizedBox(
                    height: 20*sizeUnit,
                  ),
                  RichText(
                    text: TextSpan(
                      style: SheepsTextStyle.h3(context),
                      children: <TextSpan>[
                        TextSpan(text: '지역 '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: hexToColor("#61C680"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8*sizeUnit,
                  ),
                  buildSelectArea(context, _ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  RichText(
                    text: TextSpan(
                      style: SheepsTextStyle.h3(context),
                      children: <TextSpan>[
                        TextSpan(text: '자기 소개 '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: hexToColor("#61C680"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  TextField(
                    controller: IntroduceController,
                    keyboardType: TextInputType.multiline,
                    style: SheepsTextStyle.b3(context),
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                          borderSide: BorderSide(
                              width: 1, color: hexToColor(("#61C680"))),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                          borderSide: BorderSide(
                              width: 1, color: hexToColor(("#CCCCCC"))),
                        ),
                        hintText: '프로필 내용을 입력하세요.',
                        hintStyle: SheepsTextStyle.hint4Profile(context)
                    ),
                    onChanged: (text) {
                      _ModifiedProfile.ChangeIntroduce(text);
                      CheckForMyProfile(_ModifiedProfile);
                    },
                  ),
                  SizedBox(height: 8*sizeUnit),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '사진',
                          style: SheepsTextStyle.h3(context),
                        ),
                      ),
                      SizedBox(
                        width: 8*sizeUnit,
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '최소 1장, 최대 5장의 프로필 사진을 업로드 해주세요.',
                          style: SheepsTextStyle.info1(context),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8*sizeUnit,
                  ),
                  DragAndDropGridView(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3 / 3,
                    ),
                    itemCount: _filesProvider.filesList.length != 6
                        ? _filesProvider.filesList.length
                        : _filesProvider.filesList.length - 1,
                    itemBuilder: (context, index) => Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8*sizeUnit)
                      ),
                      elevation: 0.8,
                      child: LayoutBuilder(builder: (context, costrains) {
                        if (index == _filesProvider.filesList.length - 1 &&
                            _filesProvider.filesList.length != 6) {
                          return GestureDetector(
                            onTap: () {
                              FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                              if (!currentFocus.hasPrimaryFocus) {
                                if(Platform.isIOS){
                                  FocusManager.instance.primaryFocus.unfocus();
                                } else{
                                  currentFocus.unfocus();
                                }
                              }
                              //BottomSheetMoreScreen(context);
                              SheepsBottomSheetForImg(
                                context,
                                cameraFunc: () {
                                  getImageCamera(context);
                                  Navigator.pop(context);
                                },
                                galleryFunc: () {
                                  getImageGallery(context);
                                  Navigator.pop(context);
                                },
                              );
                            },
                            child: Container(
                              width: 108*sizeUnit,
                              height: 108*sizeUnit,
                              decoration: BoxDecoration(
                                color: hexToColor("#EEEEEE"),
                                borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  svgGreyPlusIcon,
                                  width: 16*sizeUnit,
                                  height: 16*sizeUnit,
                                ),
                              ),
                            ),
                          );
                        }

                        return GestureDetector(
                          child: Container(
                            width: 108*sizeUnit,
                            height: 108*sizeUnit,
                            decoration: index <= GlobalProfile.loggedInUser.profileUrlList.length
                                ? BoxDecoration(
                                color: hexToColor("#EEEEEE"),
                                borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                                image: DecorationImage(
                                    image: FileImage(
                                        _filesProvider.filesList[index]),
                                    fit: BoxFit.cover
                                )
                            )
                                : BoxDecoration(
                                color: hexToColor("#EEEEEE"),
                                borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                                image: DecorationImage(
                                  image: FileImage(
                                      _filesProvider.filesList[index]),
                                  fit: BoxFit.cover,
                                )
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 4*sizeUnit,
                                  right: 4*sizeUnit,
                                  child: GestureDetector(
                                    onTap: () {
                                      _filesProvider.removeFile(targetFile: _filesProvider.filesList[index]);
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 16*sizeUnit,
                                      height: 16*sizeUnit,
                                      decoration: BoxDecoration(
                                          color: hexToColor("#61C680"),
                                          borderRadius: BorderRadius.circular(8*sizeUnit)),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          svgTrashCan,
                                          color: Colors.white,
                                          height: 10*sizeUnit,
                                          width: 10*sizeUnit,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        );
                      }),
                    ),
                    onWillAccept: (oldIndex, newIndex) => true,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex != _filesProvider.filesList.length - 1 &&
                          newIndex != _filesProvider.filesList.length - 1) {
                        // You can also implement on your own logic on reorderable
                        final temp = _filesProvider.filesList[oldIndex];
                        _filesProvider.filesList[oldIndex] =
                        _filesProvider.filesList[newIndex];
                        _filesProvider.filesList[newIndex] = temp;
                      }
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20*sizeUnit,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '뱃지',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(
                    height: 8*sizeUnit,
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        if(Platform.isIOS){
                          FocusManager.instance.primaryFocus.unfocus();
                        } else{
                          currentFocus.unfocus();
                        }
                      } //텍스트 포커스 해제
                      Navigator.push(
                          context, // 기본 파라미터, SecondRoute로 전달
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddBadge()) // SecondRoute를 생성하여 적재
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    child: Row(
                      children: [
                        user.badge1 != 0 //test
                            ? Container(
                          width: 108*sizeUnit,
                          height: 108*sizeUnit,
                          child: ClipRRect(
                            borderRadius:
                            new BorderRadius.circular(8*sizeUnit),
                            child: SvgPicture.asset(
                              ReturnPersonalBadgeSVG(user.badge1),
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
                        user.badge2 != 0 //test
                            ? Container(
                          width: 108*sizeUnit,
                          height: 108*sizeUnit,
                          child: ClipRRect(
                            borderRadius:
                            new BorderRadius.circular(8*sizeUnit),
                            child: SvgPicture.asset(
                              ReturnPersonalBadgeSVG(user.badge2),
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
                        user.badge3 != 0 //test
                            ? Container(
                          width: 108*sizeUnit,
                          height: 108*sizeUnit,
                          child: ClipRRect(
                            borderRadius:
                            new BorderRadius.circular(8*sizeUnit),
                            child: SvgPicture.asset(
                              ReturnPersonalBadgeSVG(user.badge3),
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
                  SizedBox(height: 20*sizeUnit,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '학력',
                          style: SheepsTextStyle.h3(context),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8*sizeUnit),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '재학, 휴학, 졸업증명서를 업로드 해주세요.',
                            style: SheepsTextStyle.info1(context),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8*sizeUnit,
                  ),
                  buildSelectUniversity(context, _ModifiedProfile),
                  SizedBox(
                    height: 8*sizeUnit,
                  ),
                  buildSelectGraduateSchool(context, _ModifiedProfile),
                  SizedBox(height: 20*sizeUnit),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '경력',
                          style: SheepsTextStyle.h3(context),
                        ),
                      ),
                    ],
                  ),
                  buildsCareerList(_ModifiedProfile),
                  SizedBox(height: 8*sizeUnit),
                  _ModifiedProfile.CareerList != null &&  _ModifiedProfile.CareerList.length < 10
                      ? GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus =
                      FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        if(Platform.isIOS){
                          FocusManager.instance.primaryFocus.unfocus();
                        } else{
                          currentFocus.unfocus();
                        }
                      } //텍스트 포커스 해제
                      _ModifiedProfile.MakeFlagForCareerOn();
                      Navigator.push(
                          context, // 기본 파라미터, SecondRoute로 전달
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddCareer()) // SecondRoute를 생성하여 적재
                      ).then((value) {
                        setState(() {});
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
                        children: [
                          SizedBox(width: 16*sizeUnit),
                          SvgPicture.asset(
                            svgGreenPlusIcon,
                            width: 12*sizeUnit,
                            height: 12*sizeUnit,
                          ),
                          SizedBox(width: 8*sizeUnit),
                          Text(
                            '경력 추가',
                            style: SheepsTextStyle.b3(context),
                          ),
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '자격증',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  buildCertificationList(_ModifiedProfile),
                  SizedBox(height: 8*sizeUnit),
                  _ModifiedProfile.CertificationList != null && _ModifiedProfile.CertificationList.length < 10
                      ? GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus =
                      FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        if(Platform.isIOS){
                          FocusManager.instance.primaryFocus.unfocus();
                        } else{
                          currentFocus.unfocus();
                        }
                      } //텍스트 포커스 해제
                      _ModifiedProfile.MakeFlagForCertificationOn();
                      Navigator.push(
                          context, // 기본 파라미터, SecondRoute로 전달
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddCertification()) // SecondRoute를 생성하여 적재
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    child: Container(
                      width: 112*sizeUnit,
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
                        children: [
                          SizedBox(
                            width: 16*sizeUnit,
                          ),
                          SvgPicture.asset(
                            svgGreenPlusIcon,
                            width: 12*sizeUnit,
                            height: 12*sizeUnit,
                          ),
                          SizedBox(width: 8*sizeUnit),
                          Text(
                            '자격증 추가',
                            style: SheepsTextStyle.b3(context),
                          ),
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
                  SizedBox(height: 20*sizeUnit),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '수상',
                      style: SheepsTextStyle.h3(context),
                    ),
                  ),
                  SizedBox(
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _ModifiedProfile.AwardList.length,
                        itemBuilder: (BuildContext context, int index) =>
                            Padding(
                              padding:
                              EdgeInsets.only(top: 8*sizeUnit),
                              child: Row(
                                children: [
                                  Container(
                                    width: 268*sizeUnit,
                                    height: 40*sizeUnit,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      new BorderRadius.circular(8*sizeUnit),
                                      border: Border.all(
                                          color: hexToColor("#CCCCCC")),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 12*sizeUnit),
                                          child: Container(
                                            width: 220*sizeUnit,
                                            child: Text(
                                              '${_ModifiedProfile.AwardList[index].AwardValue}',
                                              style: SheepsTextStyle.b3(context),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              if(Platform.isIOS){
                                                FocusManager.instance.primaryFocus.unfocus();
                                              } else{
                                                currentFocus.unfocus();
                                              }
                                            } //텍스트 포커스 해제
                                            _ModifiedProfile.RemoveAwardList(
                                                index);
                                            setState(() {});
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
                                  SheepsbuildIdentifiedState(context,_ModifiedProfile.AwardList[index].AwardState),
                                ],
                              ),
                            )),
                  ),
                  SizedBox(height: 8*sizeUnit),
                  _ModifiedProfile.AwardList != null && _ModifiedProfile.AwardList.length < 10
                      ? GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus =
                      FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        if(Platform.isIOS){
                          FocusManager.instance.primaryFocus.unfocus();
                        } else{
                          currentFocus.unfocus();
                        }
                      } //텍스트 포커스 해제
                      _ModifiedProfile.MakeFlagForAwardOn();
                      Navigator.push(
                          context, // 기본 파라미터, SecondRoute로 전달
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddAward()) // SecondRoute를 생성하여 적재
                      ).then((value) {
                        setState(() {});
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
                        children: [
                          SizedBox(width: 16*sizeUnit),
                          SvgPicture.asset(
                            svgGreenPlusIcon,
                            width: 12*sizeUnit,
                            height: 12*sizeUnit,
                          ),
                          SizedBox(
                            width: 8*sizeUnit,
                          ),
                          Text(
                            '수상 추가',
                            style: TextStyle(
                              fontSize: 12*sizeUnit,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
                  SizedBox(height: 20*sizeUnit),
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: () async {
              if(_isReady){
                if (IfModifyOk(context)) {
                  _isReady = false;
                  D.Dio dio = new D.Dio();
                  dio.options.headers = {
                    'Content-Type': 'application/json',
                    'user': GlobalProfile.loggedInUser.userID,
                  };

                  Future.microtask(() async {
                    formData = new D.FormData.fromMap({
                      "userid": GlobalProfile.loggedInUser.userID,
                      "name":  _ModifiedProfile.name,
                      "information": _ModifiedProfile.Introduce,
                      "job" : _ModifiedProfile.major,
                      "part": _ModifiedProfile.part,
                      "subjob" : _ModifiedProfile.subMajor,
                      "subpart": _ModifiedProfile.subPart,
                      "location": _ModifiedProfile.location.split(' ')[0],
                      "sublocation": _ModifiedProfile.location.split(
                          ' ')[_ModifiedProfile.location.split(' ').length - 1],
                      "pfunivname": _ModifiedProfile.University,
                      "pfgraduatename": _ModifiedProfile.GraduateSchool,
                      "badge1": user.badge1,
                      "badge2": user.badge2,
                      "badge3": user.badge3,
                    });

                    int len = _filesProvider.filesList.length;
                    for(int i = 0 ; i < len - 1; ++i){//파일 형식에 대한 처릴 ex) png, jpeg
                      String filePath = _filesProvider.filesList[i].path;
                      formData.files.add(MapEntry("ProfilePhoto",D.MultipartFile.fromFileSync(filePath, filename: getFileName(i, filePath)) ));
                    }

                    //텍스트
                    len = _ModifiedProfile.CareerList.length;
                    for(int i = 0 ; i < len ; ++i){
                      formData.fields.add(MapEntry("pfcareercontents", _ModifiedProfile.CareerList[i].CareerValue));
                      formData.fields.add(MapEntry("PfCareerStart", _ModifiedProfile.CareerStart[i]));
                      formData.fields.add(MapEntry("PfCareerDone", _ModifiedProfile.CareerEnd[i]));
                    }

                    len = _ModifiedProfile.CertificationList.length;
                    for(int i = 0 ; i <  len ; ++i){
                      formData.fields.add(MapEntry("pflicensecontents",_ModifiedProfile.CertificationList[i].CertificationValue));
                    }

                    len = _ModifiedProfile.AwardList.length;
                    for(int i = 0 ; i <  len; ++i){
                      formData.fields.add(MapEntry("pfwincontents",_ModifiedProfile.AwardList[i].AwardValue));
                    }

                    //파일
                    if(_ModifiedProfile.UnivFile != null){
                      String filePath = _ModifiedProfile.UnivFile.path;
                      formData.files.add(MapEntry("PfUnivAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath)) ));
                    }

                    if(_ModifiedProfile.GraduateFile != null){
                      String filePath = _ModifiedProfile.GraduateFile.path;
                      formData.files.add(MapEntry("PfGraduateAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath)) ));
                    }

                    len = _ModifiedProfile.CareerFile.length;
                    for(int i = 0 ; i < len; ++i){//파일 형식에 대한 처릴 ex) png, jpeg
                      String filePath = _ModifiedProfile.CareerFile[i].path;
                      formData.files.add(MapEntry("PfCareerAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(1, filePath)) ));
                    }
                    len = _ModifiedProfile.CertificationFile.length;
                    for(int i = 0 ; i < len; ++i){//파일 형식에 대한 처릴 ex) png, jpeg
                      String filePath = _ModifiedProfile.CertificationFile[i].path;
                      formData.files.add(MapEntry("PfLicenseAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }
                    len = _ModifiedProfile.AwardFile.length;
                    for(int i = 0 ; i < len; ++i){//파일 형식에 대한 처릴 ex) png, jpeg
                      String filePath = _ModifiedProfile.AwardFile[i].path;
                      formData.files.add(MapEntry("PfWinAuthImg",D.MultipartFile.fromFileSync(filePath, filename: getFileName(i+1, filePath)) ));
                    }

                    EasyLoading.show(status: "개인 프로필 수정 중...");

                    String url = kReleaseMode ? '/Personal/ProfileModify' : '/Personal/ProfileModify';

                    try{
                      res = await dio.post(ApiProvider().getImgUrl + url, data: formData);

                    } on D.DioError catch (e) {
                      EasyLoading.dismiss();
                      throw FetchDataException(e.message);
                    }
                    resu = await ApiProvider().post('/Profile/Personal/UserSelect', jsonEncode({
                      "userID" : GlobalProfile.loggedInUser.userID
                    }));

                    GlobalProfile.loggedInUser = UserData.fromJson(resu);

                    EasyLoading.dismiss();

                  }).then((value) {
                    showSheepsDialog(
                      context: context,
                      title: '프로필 수정 완료!',
                      description: '프로필 수정이 완료되었어요!',
                      isBarrierDismissible: false,
                      isCancelButton: false,
                    ).then((val){
                      Navigator.pop(context);
                    });
                  });
                }
              }
            },
            child: Container(
                height: 60*sizeUnit,
                decoration: BoxDecoration(
                  color: IfModifyOk(context) == true
                      ? hexToColor("#61C680")
                      : hexToColor("#CCCCCC"),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '수정 완료',
                    style: SheepsTextStyle.button1(context),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  bool IfModifyOk(BuildContext context) {
    if(_ModifiedProfile.ProfileModifyClear && _ModifiedProfile.part != '' && !ValidationFlagForPersonalName && !ValidationFlagForPersonalIntroduce) {
      return true;
    }
    else {
      return false;
    }
  }

  SizedBox buildCertificationList(ModifiedProfile _ModifiedProfile) {
    return SizedBox(
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: _ModifiedProfile.CertificationList.length,
          itemBuilder: (BuildContext context, int index) => Padding(
            padding: EdgeInsets.only(top: 8*sizeUnit),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 12*sizeUnit),
                        child: Container(
                          width: 220*sizeUnit,
                          child: Text(
                            '${_ModifiedProfile.CertificationList[index].CertificationValue}',
                            style: SheepsTextStyle.b3(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _ModifiedProfile.RemoveCertificationList(index);
                          setState(() {});
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 12*sizeUnit),
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
                SheepsbuildIdentifiedState(context,_ModifiedProfile.CertificationList[index].CertificationState),
              ],
            ),
          )),
    );
  }

  SizedBox buildsCareerList(ModifiedProfile _ModifiedProfile) {
    return SizedBox(
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: _ModifiedProfile.CareerList.length,
          itemBuilder: (BuildContext context, int index) => Padding(
            padding: EdgeInsets.only(top: 8*sizeUnit),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 12*sizeUnit),
                        child: Container(
                          width: 220*sizeUnit,
                          child: Text(
                            '${_ModifiedProfile.CareerList[index].CareerValue}',
                            style: SheepsTextStyle.b3(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _ModifiedProfile.RemoveCareerList(index);
                          setState(() {});
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 12*sizeUnit),
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
                SheepsbuildIdentifiedState(context,_ModifiedProfile.CareerList[index].CareerState),
              ],
            ),
          )),
    );
  }

  Row buildSelectGraduateSchool(BuildContext context, ModifiedProfile _ModifiedProfile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              if(Platform.isIOS){
                FocusManager.instance.primaryFocus.unfocus();
              } else{
                currentFocus.unfocus();
              }
            } //텍스트 포커스 해제
            _ModifiedProfile.ChangeIfThisGraduateSchool(true);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        SelectUniversity()) // SecondRoute를 생성하여 적재
            ).then((value) {
              setState(() {});
            });
          },
          child: Container(
            height: 40*sizeUnit,
            width: _ModifiedProfile.GraduateSchool == null
                ? 336*sizeUnit
                : 268*sizeUnit,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(8*sizeUnit),
              border: Border.all(color: hexToColor("#CCCCCC")),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12*sizeUnit),
                  child: Container(
                    width: 220*sizeUnit,
                    child: Text(
                        '${_ModifiedProfile.GraduateSchool == null ? "대학원 추가" : "${_ModifiedProfile.GraduateSchool}"}',
                        style: SheepsTextStyle.hint4Profile(context).copyWith(
                            color: hexToColor(
                                _ModifiedProfile.GraduateSchool == null
                                    ? "#D2D2D2"
                                    : "#222222")
                        )
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
        _ModifiedProfile.GraduateSchool == null
            ? SizedBox()
            : SheepsbuildIdentifiedState(context,
            _ModifiedProfile.GraduateSchoolState)
      ],
    );
  }

  Row buildSelectUniversity(BuildContext context, ModifiedProfile _ModifiedProfile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              if(Platform.isIOS){
                FocusManager.instance.primaryFocus.unfocus();
              } else{
                currentFocus.unfocus();
              }
            } //텍스트 포커스 해제
            _ModifiedProfile.ChangeIfThisGraduateSchool(false);
            Navigator.push(
                context, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        SelectUniversity()) // SecondRoute를 생성하여 적재
            ).then((value) {
              setState(() {});
            });
          },
          child: Container(
            height: 40*sizeUnit,
            width: _ModifiedProfile.University == null
                ? 336*sizeUnit
                : 268*sizeUnit,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(8*sizeUnit),
              border: Border.all(color: hexToColor("#CCCCCC")),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12*sizeUnit),
                  child: Container(
                    width: 220*sizeUnit,
                    child: Text(
                      '${_ModifiedProfile.University == null ? "대학교 추가" : "${_ModifiedProfile.University}"}',
                      style: SheepsTextStyle.hint4Profile(context).copyWith(
                        color: hexToColor(_ModifiedProfile.University == null
                            ? "#D2D2D2"
                            : "#222222"),
                      ),
                      overflow: TextOverflow.ellipsis,
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
        _ModifiedProfile.University == null
            ? SizedBox()
            : SheepsbuildIdentifiedState(context,
            _ModifiedProfile.UniversityState)
      ],
    );
  }
  GestureDetector buildSelectArea(BuildContext context, ModifiedProfile _ModifiedProfile) {
    return GestureDetector(
      onTap: () {
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
                builder: (context) => SelectArea()) // SecondRoute를 생성하여 적재
        ).then((value) {
          CheckForMyProfile(_ModifiedProfile);
          setState(() {});
        });
      },
      child: Container(
        height: 40*sizeUnit,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(8*sizeUnit),
          border: Border.all(color: hexToColor("#CCCCCC")),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12*sizeUnit),
              child: Text(
                '${_ModifiedProfile.location == ' ' || _ModifiedProfile.location == null ? "지역 선택" : "${_ModifiedProfile.location}"}',
                style: SheepsTextStyle.hint4Profile(context).copyWith(color: hexToColor(_ModifiedProfile.location == ' ' ||
                    _ModifiedProfile.location == null
                    ? "#D2D2D2"
                    : "#222222"),
                ),
                overflow: TextOverflow.ellipsis,
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
    );
  }

  GestureDetector buildSelectSubField(BuildContext context, ModifiedProfile _ModifiedProfile) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          if(Platform.isIOS){
            FocusManager.instance.primaryFocus.unfocus();
          } else{
            currentFocus.unfocus();
          }
        } //텍스트 포커스 해제

        _ModifiedProfile.ChangeIfThisSubField(true);
        String prevSubField = _ModifiedProfile.subMajor;

        Navigator.push(
            context, // 기본 파라미터, SecondRoute로 전달
            MaterialPageRoute(
                builder: (context) => SelectField()) // SecondRoute를 생성하여 적재
        ).then((value) {

          if(value == false){
            _ModifiedProfile.subMajor = prevSubField;
          }

          setState(() {});
        });
      },
      child: Padding(
        padding: EdgeInsets.only(top: 8*sizeUnit),
        child: Container(
          height: 40*sizeUnit,
          width: 336*sizeUnit,
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.circular(8*sizeUnit),
            border: Border.all(color: hexToColor("#CCCCCC")),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12*sizeUnit),
                child: Container(
                  width: 220*sizeUnit,
                  child: Text(
                    '${_ModifiedProfile.subPart == null || _ModifiedProfile.subPart == "" ? "서브 분야 선택 (선택)" : "${_ModifiedProfile.subPart}"}',
                    style: SheepsTextStyle.hint4Profile(context).copyWith(
                      color: hexToColor(_ModifiedProfile.subPart == null ||
                          _ModifiedProfile.subPart == ""
                          ? "#D2D2D2"
                          : "#222222"),
                    ),
                    overflow: TextOverflow.ellipsis,
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
    );
  }

  GestureDetector buildSelectMainField(
      BuildContext context,
      ModifiedProfile _ModifiedProfile) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          if(Platform.isIOS){
            FocusManager.instance.primaryFocus.unfocus();
          } else{
            currentFocus.unfocus();
          }
        } //텍스트 포커스 해제

        String prevMainField = _ModifiedProfile.major;

        Navigator.push(
            context, // 기본 파라미터, SecondRoute로 전달
            MaterialPageRoute(
                builder: (context) => SelectField()) // SecondRoute를 생성하여 적재
        ).then((value) {

          if(value == false){
            _ModifiedProfile.major = prevMainField;
          }

          CheckForMyProfile(_ModifiedProfile);
          setState(() {});
        });
      },
      child: Container(
        height: 40*sizeUnit,
        width: 336*sizeUnit,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(8*sizeUnit),
          border: Border.all(color: hexToColor("#CCCCCC")),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12*sizeUnit),
              child: Container(
                width: 220*sizeUnit,
                child: Text(
                  '${_ModifiedProfile.part == null || _ModifiedProfile.part == "" ? "주 분야 선택" : "${_ModifiedProfile.part}"}',
                  style:SheepsTextStyle.hint4Profile(context).copyWith(
                    color: hexToColor(_ModifiedProfile.part == null ||
                        _ModifiedProfile.part == ""
                        ? "#D2D2D2"
                        : "#222222"),
                  ),
                  overflow: TextOverflow.ellipsis,
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
    );
  }

  bool Validation_OnlyString(String value, String target) {
    int utf8Length = utf8.encode(NameController.text).length;
    setState(() {
      if (target == "이름") {
        ValidationFlagForPersonalName = false;
        RegExp regExp = new RegExp(r'[$/!@#<>?":`~;[\]\\|=+)(*&^%\s-]');//허용문자 _.

        if (regExp.hasMatch(value)) {
          ValidationFlagForPersonalName = true;
          nameErrorText = "특수문자가 들어갈 수 없어요.";
        } else {
          if (value.length < 2) {
            ValidationFlagForPersonalName = true;
            nameErrorText = "너무 짧아요. 2자 이상 작성해주세요.";
          } else if (value.length > 15 || utf8Length > 30) {
            ValidationFlagForPersonalName = true;
            nameErrorText = "너무 길어요. 한글 10자 또는 영어 15자 이하로 작성해 주세요.";
          } else {
            nameErrorText = '';
          }
        }
      } else {
        ValidationFlagForPersonalIntroduce = false;
      }
    });

    return ValidationFlagForPersonalName;
  }

  SizedBox buildNameController(ModifiedProfile _ModifiedProfile, UserData user) {
    return SizedBox(
      height: 68*sizeUnit,
      width: 336*sizeUnit,
      child: TextField(
        controller: NameController,
        style: SheepsTextStyle.b3(context),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.only(left: 12*sizeUnit, top: 12*sizeUnit, right: 12*sizeUnit, bottom: 12*sizeUnit),
          hintText: '이름 입력',
          hintStyle: SheepsTextStyle.hint4Profile(context),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
            borderSide: BorderSide(width: 1, color: hexToColor(("#61C680"))),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
            borderSide: BorderSide(width: 1, color: hexToColor(("#CCCCCC"))),
          ),
          errorText: ValidationFlagForPersonalName ? nameErrorText : null,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
            borderSide: BorderSide(width: 1, color: Colors.red),
          ),
          errorStyle: SheepsTextStyle.error(context),
        ),
        onChanged: (text) {
          if (!Validation_OnlyString(text, "이름")) {
            _ModifiedProfile.ChangeName(text);
            CheckForMyProfile(_ModifiedProfile);
          } else {
            _ModifiedProfile.ChangeProfileModifyClear(false);
          }
        },
      ),
    );
  }

  void CheckForMyProfile(ModifiedProfile _ModifiedProfile) {
    if (_ModifiedProfile.name != null &&
        _ModifiedProfile.part != null &&
        _ModifiedProfile.location != null &&
        _ModifiedProfile.Introduce != null &&
        _ModifiedProfile.name != "" &&
        _ModifiedProfile.part != "" &&
        _ModifiedProfile.location != "" &&
        _ModifiedProfile.Introduce != "") {
      _ModifiedProfile.ChangeProfileModifyClear(true);
    } else {
      _ModifiedProfile.ChangeProfileModifyClear(false);
    }
  }
}

Future getImageGallery(BuildContext context) async {
  MultipartImgFilesProvider _UserProvider = Provider.of<MultipartImgFilesProvider>(context, listen: false);

  var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery); //camera
  if (imageFile == null) return;

  _UserProvider.addFiles(imageFile);


  return;
}

Future getImageCamera(BuildContext context) async {
  MultipartImgFilesProvider _UserProvider = Provider.of<MultipartImgFilesProvider>(context, listen: false);

  var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
  if (imageFile == null) return;

  _UserProvider.addFiles(imageFile);
  return;
}
