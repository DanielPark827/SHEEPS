import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/Community/models/DummyForCommunityWrite.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/config/NavigationNum.dart';
import 'package:sheeps_app/main.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:sheeps_app/profile/models/ProfileState.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class CommunityWrite extends StatefulWidget {

  String topic;

  CommunityWrite({Key key, this.topic, }) : super(key : key);

  @override
  _CommunityWriteState createState() => _CommunityWriteState();
}

class _CommunityWriteState extends State<CommunityWrite> {
  final TitleController = TextEditingController();
  final DescriptionController = TextEditingController();

  final String svgTrash = 'assets/images/Community/trash.svg';

  List<File> filesList = [];

  double sizeUnit = 1;

  @override
  void dispose() {
    TitleController.dispose();
    DescriptionController.dispose();
    super.dispose();
  }

  ProviderForCommmunityWrite _CommunityWrite;

  bool isPossiblePost(){
    bool isPossible = false;

    if(_CommunityWrite.Topic != "커뮤니티 선택" && TitleController.text.length >= 5 && DescriptionController.text.length >= 10){
      isPossible = true;
    }

    return isPossible;
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    if(_CommunityWrite == null){
      _CommunityWrite = Provider.of<ProviderForCommmunityWrite>(context);
      _CommunityWrite.Topic = widget.topic;

      if(_CommunityWrite.Topic == null || _CommunityWrite.Topic == "전체"){
        _CommunityWrite.Topic = "커뮤니티 선택";
      }
    }

    ProfileState profileState = Provider.of<ProfileState>(context);
    NavigationNum navigationNum = Provider.of<NavigationNum>(context);

    // _filesProvider = Provider.of<MultipartImgFilesProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
              if (!currentFocus.hasPrimaryFocus) {
                if(Platform.isIOS){
                  FocusManager.instance.primaryFocus.unfocus();
                } else{
                  currentFocus.unfocus();
                }
              }
            },
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                actions: [
                  Container(
                    height: 60*sizeUnit,
                    width: 360*sizeUnit,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: (){
                            _CommunityWrite.ChangeTopic('커뮤니티 선택');
                            _CommunityWrite.ChangeGallery(false);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12*sizeUnit),
                            child: Center(
                              child: SvgPicture.asset(
                                svgBackArrow,
                                width: 28*sizeUnit,
                                height: 28*sizeUnit,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_CommunityWrite.Topic}',
                              style: SheepsTextStyle.appBar(context),
                            ),
                            SizedBox(width: 8*sizeUnit),
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
                                _settingModalBottomSheet(context,_CommunityWrite, profileState);
                              },
                              child:  Container(
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.circular(4*sizeUnit),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[350],
                                        blurRadius: 4.0,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                    color: profileState.getColor2(),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: profileState.getColor(),
                                    size: 20*sizeUnit,
                                  )),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: ()async{
                            if(false == isPossiblePost()) return;
                            Function okFunc = ()async{
                              Dio dio = new Dio();
                              dio.options.headers = {
                                'Content-Type' : 'application/json',
                                'user' : GlobalProfile.loggedInUser.userID
                              };
                              FormData formData = new FormData.fromMap({
                                "userid" : GlobalProfile.loggedInUser.userID,
                                "category": _CommunityWrite.Topic,
                                "title" : TitleController.text,
                                "contents" : DescriptionController.text,
                                "0": filesList.length>=1? await MultipartFile.fromFile(filesList[0].path, filename: getFileName(0, filesList[0].path)):null,
                                "1":  filesList.length>=2?await MultipartFile.fromFile(filesList[1].path, filename:getFileName(1, filesList[1].path)):null,
                                "2": filesList.length>=3? await MultipartFile.fromFile(filesList[2].path, filename:getFileName(2, filesList[2].path)):null,
                              });


                              EasyLoading.show(status: "게시글 등록 중...");

                              var url = kReleaseMode ? '/CommunityPost/Insert' : '/CommunityPost/Insert';

                              var res;
                              try{
                               res = await dio.post( ApiProvider().getImgUrl + url, data: formData);
                              } on DioError catch (e) {
                                EasyLoading.dismiss();
                                throw FetchDataException(e.message);
                              }

                              GlobalProfile.newCommunityList.insert(0,Community.fromJson(json.decode(res.toString())));
                              EasyLoading.dismiss();
                              Fluttertoast.showToast(msg: "게시물 작성이 완료되었습니다.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: hexToColor('#FFFFFF') );
                              navigationNum.setNum(COMMUNITY_MAIN_PAGE);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            };
                            Function cancelFunc = (){
                              Navigator.pop(context);
                            };
                            showSheepsDialog(
                              context: context,
                              title: '게시글 등록',
                              isLogo: false,
                              description: '게시글을 등록하시겠습니까?',
                              okText: '등록할래요',
                              okFunc: okFunc,
                              cancelText: '좀 더 생각해볼게요',
                              cancelFunc: cancelFunc,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(12*sizeUnit),
                            child: Center(
                              child: Text(
                                '완료',
                                style: SheepsTextStyle.infoStrong(context).copyWith(color: isPossiblePost() ? hexToColor("#61C680") : hexToColor("#D2D2D2")),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )],
              ),
              backgroundColor: hexToColor("#FFFFFF"),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 360*sizeUnit,
                      child: TextField(
                        controller: TitleController,
                        maxLength: 15,
                        decoration: InputDecoration(
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          counterText: "",
                          hintText: "제목을 입력해주세요. (최소 5글자)",
                          hintStyle: SheepsTextStyle.hint(context),
                          contentPadding: EdgeInsets.fromLTRB(12*sizeUnit, 16*sizeUnit, 0, 16*sizeUnit),
                        ),
                        onChanged: (text) {
                          setState(() {
                          });
                        },
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      height: 1,
                      color:hexToColor("#F8F8F8"),
                    ),
                    TextField(
                      controller: DescriptionController,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines:filesList.length != 0?17 :25,
                      minLines: 5,
                      maxLengthEnforced: true,
                      maxLength: 500,
                      decoration: InputDecoration(
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: "내용을 입력해주세요. (최소 10글자)",
                        hintStyle: SheepsTextStyle.hint4Profile(context),
                        contentPadding: EdgeInsets.fromLTRB(12*sizeUnit, 16*sizeUnit, 12*sizeUnit, 16*sizeUnit),
                      ),
                      onChanged: (text){
                        setState(() {

                        });
                      },
                    ),

                    SizedBox(height:12*sizeUnit),
                    Row(
                      children: [
                        SizedBox(width: 6*sizeUnit),
                        Container(
                          height: 108*sizeUnit,
                          color: Colors.white,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            cacheExtent: 3,
                            reverse: false,
                            shrinkWrap: true,
                            itemCount:filesList.length + 1,
                            itemBuilder: (context, index) {
                              if (index ==filesList.length &&
                                  filesList.length != 3){
                                return GestureDetector(
                                    child: Row(
                                      children: [
                                        SizedBox(width: 6*sizeUnit),
                                        Container(
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
                                      ],
                                    ),
                                    onTap: () async {
                                      FocusScopeNode currentFocus = FocusScope.of(context); //텍스트 포커스 해제
                                      if (!currentFocus.hasPrimaryFocus) {
                                        if(Platform.isIOS){
                                          FocusManager.instance.primaryFocus.unfocus();
                                        } else{
                                          currentFocus.unfocus();
                                        }
                                      }
                                      //_settingModalBottomSheetForGallery(context);
                                      SheepsBottomSheetForImg(context,
                                        cameraFunc: (){
                                          getImageCamera(context);
                                          Navigator.pop(context);
                                        },
                                        galleryFunc: () async {
                                          getImageGallery(context);
                                          Navigator.pop(context);
                                        },
                                      );
                                    });
                              }

                              return Row(
                                children: [
                                  SizedBox(width:6*sizeUnit),
                                  Container(
                                    width: 108*sizeUnit,
                                    height: 108*sizeUnit,
                                    decoration: BoxDecoration(
                                        color: hexToColor("#EEEEEE"),
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                        image: DecorationImage(
                                            image: FileImage(filesList[index]),
                                            fit: BoxFit.cover)),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 6*sizeUnit,
                                          right: 6*sizeUnit,
                                          child: GestureDetector(
                                            onTap: (){
                                              filesList.removeAt(index);
                                              setState(() {
                                              });
                                            },
                                            child: Container(
                                              width: 16*sizeUnit,
                                              height: 16*sizeUnit,
                                              decoration: BoxDecoration(
                                                  color:hexToColor("#61C680"),
                                                  borderRadius: BorderRadius.circular(8*sizeUnit)),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  svgTrash,
                                                  height: 10*sizeUnit,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _settingModalBottomSheet(context, ProviderForCommmunityWrite _CommunityWrite, ProfileState profileState){
    var list;

    if( profileState.getNum() == 0) {
      list = CategoryForCommunity;
    } else {
      list = CategoryForCommunityByJob;
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
            )
        ),
        context: context,
        builder: (BuildContext bc){
          return SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8*sizeUnit),
                      child: Container(
                        width: 20 * sizeUnit,
                        height: 4 * sizeUnit,
                        decoration: BoxDecoration(
                          color: Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(2 * sizeUnit),
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => Divider(thickness: 1,height: 1,color: hexToColor("#F8F8F8"),),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) => FlatButton(
                      onPressed: (){
                        profileState.getNum() == 0?
                        _CommunityWrite.ChangeTopic(CategoryForCommunity[index%5]):
                        _CommunityWrite.ChangeTopic(CategoryForCommunityByJob[index%5]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 64*sizeUnit,
                        width: 360*sizeUnit,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${list[index]}',
                              style: SheepsTextStyle.h3(context),
                            ),
                            SizedBox(height: 4*sizeUnit),
                            Text(
                              profileState.getNum() == 0 ? '${DescriptionForCategoryForCommunity[index%5]}' : '${DescriptionForCategoryForCommunityByJob[index%5]}',
                              style: SheepsTextStyle.bWriter(context),
                            )
                          ],
                        ),
                      ),
                    )
                ),
                SizedBox(height: 12*sizeUnit),
              ],
            ),
          );
        }
    );
  }

  Future getImageGallery(BuildContext context) async {

    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery); //camera
    print(imageFile);
    if (imageFile == null) return;
    filesList.add(imageFile);
    setState(() {

    });
    return;
  }

  Future getImageCamera(BuildContext context) async {
    // ignore: deprecated_member_use
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imageFile == null) return;
    filesList.add(imageFile);
    setState(() {

    });
    return;
  }
}
