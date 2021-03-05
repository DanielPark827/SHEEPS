import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/profile/MyDetailProfile.dart';
import 'package:sheeps_app/profileModify/MyProfileModify.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import 'package:sheeps_app/Badge/model/ModelBadge.dart';
import 'package:sheeps_app/TeamProfileModifys/model/Team.dart';
import 'package:sheeps_app/profile/DetailTeamProfile.dart';

double sizeUnit = 1;

class SettingColumn extends StatelessWidget {
  final String str;
  final Function myFunc;

  SettingColumn({Key key, this.str, this.myFunc});

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return InkWell(
      onTap: myFunc,
      child: Container(
        color: Colors.white,
        height: 48 * sizeUnit,
        child: new Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 12 * sizeUnit),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  this.str,
                  style: SheepsTextStyle.b1(context),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 16 * sizeUnit),
              child: SvgPicture.asset(
                svgGreyNextIcon,
                width: 16 * sizeUnit,
                height: 16 * sizeUnit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Container buildGotoNextPage(BuildContext context, String title) {
  sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return Container(
    color: Colors.white,
    height: 48 * sizeUnit,
    child: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12 * sizeUnit),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 22 * sizeUnit,
              child: Text(
                title,
                style: SheepsTextStyle.b1(context),
              ),
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        Padding(
          padding: EdgeInsets.only(right: 16 * sizeUnit),
          child: SvgPicture.asset(
            svgGreyNextIcon,
            width: 16 * sizeUnit,
            height: 16 * sizeUnit,
          ),
        ),
      ],
    ),
  );
}

getExtendedImage(String url, int size, AnimationController controller,
    {bool isRounded = true}) {
  return ExtendedImage.network(
    getOptimizeImageURL(url, size),
    fit: BoxFit.fill,
    borderRadius:
        isRounded == true ? BorderRadius.all(Radius.circular(8.0)) : null,
    shape: BoxShape.rectangle,
    cache: true,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          controller.reset();
          return CupertinoActivityIndicator();
          break;
        case LoadState.completed:
          controller.forward();
          return ExtendedRawImage(
            image: state.extendedImageInfo?.image,
          );
          break;
        case LoadState.failed:
          controller.reset();
          return GestureDetector(
            child: Container(),
            onTap: () {
              state.reLoadImage();
            },
          );
          break;
        default:
          controller.reset();
          return Container();
          break;
      }
    },
  );
}

Widget SheepsAppBar(BuildContext context, String title,
    {bool isBackButton = true, Function backFunc, List<Widget> actions}) {
  double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return AppBar(
    centerTitle: true,
    elevation: 0,
    leading: isBackButton
        ? Padding(
            padding: EdgeInsets.only(left: 12 * sizeUnit),
            child: GestureDetector(
              onTap: backFunc == null
                  ? () {
                      Navigator.pop(context);
                    }
                  : backFunc,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  svgBackArrow,
                  width: 28 * sizeUnit,
                  height: 28 * sizeUnit,
                ),
              ),
            ),
          )
        : Container(),
    title: Text(
      title,
      style: SheepsTextStyle.appBar(context),
    ),
    actions: actions,
  );
}

Widget SheepsSimpleListItemBox(BuildContext context, Widget _child) {
  double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return Container(
    width: 360 * sizeUnit,
    height: 48 * sizeUnit,
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
      child: _child,
    ),
  );
}

showSheepsDialog(
    {@required BuildContext context,
    @required String title,
    bool isLogo = true,
    String imgUrl,
    String description,
    String okText = '확인',
    bool isCancelButton = true,
    String cancelText = '취소',
    Function okFunc,
    Function cancelFunc,
    bool isBarrierDismissible = true}) {
  double sizeUnit = 1;
  return showDialog(
      context: context,
      barrierDismissible: isBarrierDismissible,
      builder: (BuildContext context) {
        sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
        return new AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8 * sizeUnit)),
          actions: <Widget>[
            Container(
              width: 280 * sizeUnit,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 40 * sizeUnit),
                    child: Text(title,
                        style: SheepsTextStyle.dialogTitle(context)),
                  ),
                  isLogo
                      ? Padding(
                          padding: EdgeInsets.only(top: 20 * sizeUnit),
                          child: Container(
                            width: 200 * sizeUnit,
                            height: 140 * sizeUnit,
                            child: Center(
                              child: SvgPicture.asset(
                                svgSheepsGreenImageLogo,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  imgUrl == null
                      ? SizedBox.shrink()
                      : imgUrl == 'BasicImage'
                        ? Padding(
                          padding: EdgeInsets.only(top: 20 * sizeUnit),
                          child: Container(
                              decoration: BoxDecoration(
                              color: hexToColor('#F8F8F8'),
                              borderRadius: new BorderRadius.circular(8*sizeUnit),
                              ),
                              child:  SvgPicture.asset(
                                  svgPersonalProfileBasicImage,
                                  width: 84*sizeUnit,
                                  height: 84*sizeUnit,
                              ),
                          ),
                        )
                        : Padding(
                            padding: EdgeInsets.only(top: 20 * sizeUnit),
                            child: Container(
                              color: Colors.white,
                              width: 120 * sizeUnit,
                              height: 120 * sizeUnit,
                              child: Center(
                                child: FittedBox(
                                  child: ExtendedImage.network(getOptimizeImageURL(imgUrl, 120)),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        ),
                  description == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(
                              top: 20 * sizeUnit,
                              left: 20 * sizeUnit,
                              right: 20 * sizeUnit),
                          child: Text(
                            description,
                            style: SheepsTextStyle.dialogContent(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                  Container(
                    width: 270 * sizeUnit,
                    height: 72 * sizeUnit,
                    padding: EdgeInsets.fromLTRB(
                        20 * sizeUnit, 20 * sizeUnit, 20 * sizeUnit, 0),
                    child: new FlatButton(
                      child: new Text(okText,
                          style: SheepsTextStyle.button1(context)),
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8 * sizeUnit),
                        borderSide: BorderSide(color: hexToColor("#61C680")),
                      ),
                      color: hexToColor('#61C680'),
                      onPressed: okFunc == null
                          ? () {
                              Navigator.pop(context);
                            }
                          : okFunc,
                    ),
                  ),
                  isCancelButton
                      ? GestureDetector(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                20 * sizeUnit, 16 * sizeUnit, 20 * sizeUnit, 0),
                            child: new Text(
                              cancelText,
                              style: SheepsTextStyle.info1(context),
                            ),
                          ),
                          onTap: cancelFunc == null
                              ? () {
                                  Navigator.pop(context);
                                }
                              : cancelFunc,
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 20 * sizeUnit,
                  ),
                ],
              ),
            ),
          ],
        );
      });
}

Future SheepsBottomSheetForImg(BuildContext context,
    {@required Function cameraFunc, @required Function galleryFunc}) {
  sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
          )
      ),
      context: context,
      builder: (BuildContext bc) {
        return SizedBox(
          height: 136 * sizeUnit,
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
              GestureDetector(
                onTap: cameraFunc,
                child: Container(
                  height: 48 * sizeUnit,
                  width: 360 * sizeUnit,
                  child: Center(
                    child: Text(
                      '카메라로 사진 찍기',
                      style: SheepsTextStyle.b1(context),
                    ),
                  ),
                ),
              ),
              Container(color: Color(0xFFF8F8F8), height: 1 * sizeUnit),
              GestureDetector(
                onTap: galleryFunc,
                child: Container(
                  height: 48 * sizeUnit,
                  width: 360 * sizeUnit,
                  child: Center(
                    child: Text(
                      '앨범에서 사진 선택',
                      style: SheepsTextStyle.b1(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget SheepsbuildIdentifiedState(BuildContext context, int value) {
  double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  if (value == 2) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * sizeUnit),
      child: Container(
        width: 60 * sizeUnit,
        height: 40 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(8 * sizeUnit),
          border: Border.all(color: hexToColor("#61C680")),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '검토중',
            style: SheepsTextStyle.b3(context)
                .copyWith(color: Color(0xFF61C680)),
          ),
        ),
      ),
    );
  } else if (value == 1) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * sizeUnit),
      child: Container(
        width: 60 * sizeUnit,
        height: 40 * sizeUnit,
        decoration: BoxDecoration(
          color: Color(0xFF61C680),
          borderRadius: new BorderRadius.circular(8 * sizeUnit),
          border: Border.all(color: hexToColor("#61C680")),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '인증완료',
            style: SheepsTextStyle.b3(context).copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  } else {
    return GestureDetector(
      onTap: () {
        showSheepsDialog(
          context: context,
          title: '반려 사유',
          isLogo: false,
          description: '사진이 제대로 보이지 않습니다.\n다시 찍어서 업로드해주세요.',
          isCancelButton: false,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(left: 8 * sizeUnit),
        child: Container(
          width: 60 * sizeUnit,
          height: 40 * sizeUnit,
          decoration: BoxDecoration(
            color: hexToColor("#CCCCCC"),
            borderRadius: new BorderRadius.circular(8 * sizeUnit),
            border: Border.all(color: hexToColor("#CCCCCC")),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '반려됨',
              style:
                  SheepsTextStyle.b3(context).copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

Widget SheepsProfileVerificationStateIcon(BuildContext context, int state) {//stste 인증상태 받아옴
  sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  final String svgVerificationCompleted = 'assets/images/Profile/VerificationCompleted.svg';
  final String svgVerificationIncomplete = 'assets/images/Profile/VerificationIncomplete.svg';
  return Padding(
    padding: EdgeInsets.only(left: 8 * sizeUnit),
    child: SvgPicture.asset(//인증완료 1 일때 초록아이콘
      state == 1 ? svgVerificationCompleted : svgVerificationIncomplete,
      height: 16 * sizeUnit,
      width: 16 * sizeUnit,
    ),
  );
}

Widget SheepsPersonalProfileCard(BuildContext context, UserData person, int index, AnimationController extendedController){
  sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  switch (person.location) {
    case '서울특별시':
      person.location = '서울'; break;
    case '인천광역시':
      person.location = '인천'; break;
    case '경기도':
      person.location = '경기'; break;
    case '강원도':
      person.location = '강원'; break;
    case '충청남도':
      person.location = '충남'; break;
    case '충청북도':
      person.location = '충북'; break;
    case '세종시':
      person.location = '세종'; break;
    case '대전광역시':
      person.location = '대전'; break;
    case '경상북도':
      person.location = '경북'; break;
    case '경상남도':
      person.location = '경남'; break;
    case '대구광역시':
      person.location = '대구'; break;
    case '부산광역시':
      person.location = '부산'; break;
    case '전라북도':
      person.location = '전북'; break;
    case '전라남도':
      person.location = '전남'; break;
    case '울산광역시':
      person.location = '울산'; break;
    case '제주특별자치도':
      person.location = '제주'; break;
    case '광주광역시':
      person.location = '광주'; break;
  }
  return GestureDetector(
    onTap: () {
      if(person.userID == GlobalProfile.loggedInUser.userID){
        Navigator.push(
            context, // 기본 파라미터, SecondRoute로 전달
            MaterialPageRoute(
                builder: (context) => MyDetailProfile(index: 0)));
      }else{
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new DetailProfile(
                    index: 0,
                    user: person
                )));
      }
    },
    child: Container(
      width: 160*sizeUnit,
      padding: EdgeInsets.only(top: 8*sizeUnit, left: 4*sizeUnit, right: 4*sizeUnit),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: person.userID,
            child: Container(
              width: 160*sizeUnit,
              height: 160*sizeUnit,
              child: Stack(
                children: [
                  person.profileUrlList[0] == 'BasicImage' ?
                  Container(
                    decoration: BoxDecoration(
                      color: hexToColor('#F8F8F8'),
                      borderRadius: new BorderRadius.circular(8*sizeUnit),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(116, 125, 130, 0.1),
                          offset: Offset(1*sizeUnit,1*sizeUnit),
                          blurRadius: 2*sizeUnit,
                        ),
                      ],
                    ),
                    child:  Center(child: SvgPicture.asset(svgPersonalProfileBasicImage,width: 84*sizeUnit,height: 84*sizeUnit)),
                  ) :
                  Container(
                      width: 160*sizeUnit,
                      height: 160*sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(8*sizeUnit),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(116, 125, 130, 0.1),
                            offset: Offset(1*sizeUnit,1*sizeUnit),
                            blurRadius: 2*sizeUnit,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(8*sizeUnit),
                        child: FittedBox(
                          child: getExtendedImage(person.profileUrlList[0], 0, extendedController),
                          fit: BoxFit.cover,
                        ),
                      )
                  ),
                  person.badge1 != 0
                      ? Positioned(
                    right: 8*sizeUnit,
                    bottom: 8*sizeUnit,
                    child: Container(
                      width: 32*sizeUnit,
                      height: 32*sizeUnit,
                      child: ClipRRect(
                        borderRadius:
                        new BorderRadius.circular(8*sizeUnit),
                        child: FittedBox(
                          child: SvgPicture.asset(
                            ReturnPersonalBadgeSVG(person.badge1),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      : Container(),
                  person.badge2 != 0
                      ? Positioned(
                    right: 40*sizeUnit,
                    bottom: 8*sizeUnit,
                    child: Container(
                      width: 32*sizeUnit,
                      height: 32*sizeUnit,
                      child: ClipRRect(
                        borderRadius:
                        new BorderRadius.circular(8*sizeUnit),
                        child: FittedBox(
                          child: SvgPicture.asset(
                              ReturnPersonalBadgeSVG(person.badge2)
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      : Container(),
                  person.badge3 != 0
                      ? Positioned(
                    right: 72*sizeUnit,
                    bottom: 8*sizeUnit,
                    child: Container(
                      width: 32*sizeUnit,
                      height: 32*sizeUnit,
                      child: ClipRRect(
                        borderRadius:
                        new BorderRadius.circular(8*sizeUnit),
                        child: FittedBox(
                          child: SvgPicture.asset(
                              ReturnPersonalBadgeSVG(person.badge3)
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      : Container(),
                ],
              ),
            ),
          ),
          SizedBox(height: 8*sizeUnit),
          Container(
            height: 22*sizeUnit,
            width: 160*sizeUnit,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                person.name,
                style: SheepsTextStyle.h3(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: 4*sizeUnit),
          Wrap(
            runSpacing: 4*sizeUnit,
            spacing: 4*sizeUnit,
            children: [
              person.part == null || person.part.isEmpty ? SizedBox.shrink()
                  : Container(
                height: 18*sizeUnit,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        person.part,
                        style: SheepsTextStyle.cat1(context),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(4*sizeUnit),
                  color: hexToColor("#E5E5E5"),
                ),
              ),
              person.subPart == null || person.subPart.isEmpty ? SizedBox.shrink()
                  : Container(
                height: 18*sizeUnit,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        person.subPart,
                        style: SheepsTextStyle.cat1(context),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(4*sizeUnit),
                  color: hexToColor("#E5E5E5"),
                ),
              ),
              person.location == null || person.location.isEmpty ? SizedBox.shrink()
                  : Container(
                height: 18*sizeUnit,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        person.location,
                        style: SheepsTextStyle.cat1(context),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(4*sizeUnit),
                  color: hexToColor("#E5E5E5"),
                ),
              ),
            ],
          ),
          SizedBox(height: 8*sizeUnit),
          Container(
            height: 48*sizeUnit,
            child: Text(
              person.information == null ? '' : person.information,
              maxLines: 3,
              style: SheepsTextStyle.b4(context).copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget SheepsTeamProfileCard(BuildContext context, Team team, int index, AnimationController extendedController){
  sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  switch (team.location) {
    case '서울특별시':
      team.location = '서울'; break;
    case '인천광역시':
      team.location = '인천'; break;
    case '경기도':
      team.location = '경기'; break;
    case '강원도':
      team.location = '강원'; break;
    case '충청남도':
      team.location = '충남'; break;
    case '충청북도':
      team.location = '충북'; break;
    case '세종시':
      team.location = '세종'; break;
    case '대전광역시':
      team.location = '대전'; break;
    case '경상북도':
      team.location = '경북'; break;
    case '경상남도':
      team.location = '경남'; break;
    case '대구광역시':
      team.location = '대구'; break;
    case '부산광역시':
      team.location = '부산'; break;
    case '전라북도':
      team.location = '전북'; break;
    case '전라남도':
      team.location = '전남'; break;
    case '울산광역시':
      team.location = '울산'; break;
    case '제주특별자치도':
      team.location = '제주'; break;
    case '광주광역시':
      team.location = '광주'; break;
  }
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => new DetailTeamProfile(
                  index: index,
                  team: team)));
    },
    child: Container(
      width: 160*sizeUnit,
      padding: EdgeInsets.only(top: 8*sizeUnit, left: 4*sizeUnit, right: 4*sizeUnit),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: team.id,
            child: Stack(
              children: [
                Container(
                  width: 160*sizeUnit,
                  height: 160*sizeUnit,
                  child: team.profileUrlList[0] == 'BasicImage' ?
                  Container(
                    decoration: BoxDecoration(
                      color: hexToColor('#F8F8F8'),
                      borderRadius: new BorderRadius.circular(8*sizeUnit),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(116, 125, 130, 0.1),
                          offset: Offset(1*sizeUnit,1*sizeUnit),
                          blurRadius: 2*sizeUnit,
                        ),
                      ],
                    ),
                    child:  Center(child: SvgPicture.asset(svgPersonalProfileBasicImage,width: 84*sizeUnit,height: 84*sizeUnit)),
                  ) :
                  Container(
                      width: 160*sizeUnit,
                      height: 160*sizeUnit,
                      decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(8*sizeUnit),
                        boxShadow: [
                          new BoxShadow(
                            color: Color.fromRGBO(116, 125, 130, 0.1),
                            offset: Offset(1*sizeUnit,1*sizeUnit),
                            blurRadius: 2*sizeUnit,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(8*sizeUnit),
                        child: FittedBox(
                          child: getExtendedImage(team.profileUrlList[0], 0, extendedController),
                          fit: BoxFit.cover,
                        ),
                      )
                  ),
                ),
                team.badge1 != 0
                    ? Positioned(
                  right: 8*sizeUnit,
                  bottom: 8*sizeUnit,
                  child: Container(
                    width: 32*sizeUnit,
                    height: 32*sizeUnit,
                    child: ClipRRect(
                      borderRadius:
                      new BorderRadius.circular(8*sizeUnit),
                      child: FittedBox(
                        child: SvgPicture.asset(
                          ReturnTeamBadgeSVG(team.badge1),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                    : Container(),
                team.badge2 != 0
                    ? Positioned(
                  right: 40*sizeUnit,
                  bottom: 8*sizeUnit,
                  child: Container(
                    width: 32*sizeUnit,
                    height: 32*sizeUnit,
                    child: ClipRRect(
                      borderRadius:
                      new BorderRadius.circular(8*sizeUnit),
                      child: FittedBox(
                        child: SvgPicture.asset(
                          ReturnTeamBadgeSVG(team.badge2),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                    : Container(),
                team.badge3 != 0
                    ? Positioned(
                  right: 72*sizeUnit,
                  bottom: 8*sizeUnit,
                  child: Container(
                    width: 32*sizeUnit,
                    height: 32*sizeUnit,
                    child: ClipRRect(
                      borderRadius:
                      new BorderRadius.circular(8*sizeUnit),
                      child: FittedBox(
                        child: SvgPicture.asset(
                          ReturnTeamBadgeSVG(team.badge3),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                    : Container(),
              ],
            ),
          ),
          SizedBox(height: 8*sizeUnit),
          Container(
            height: 22*sizeUnit,
            width: 160*sizeUnit,
            child: Text(
              team.name,
              style: SheepsTextStyle.h3(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 4*sizeUnit),
          Wrap(
            runSpacing:  4*sizeUnit,
            spacing: 4*sizeUnit,
            children: [
              team.category == null || team.category.isEmpty ? SizedBox.shrink()
                  : Container(
                height: 18*sizeUnit,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        team.category,
                        style: SheepsTextStyle.cat1(context),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(4*sizeUnit),
                  color: hexToColor("#E5E5E5"),
                ),
              ),
              team.location.isEmpty ? Container()
                  : Container(
                height: 18*sizeUnit,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        team.location,
                        style: SheepsTextStyle.cat1(context),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(4*sizeUnit),
                  color: hexToColor("#E5E5E5"),
                ),
              ),
            ],
          ),
          SizedBox(height: 8*sizeUnit),
          Container(
            height: 48*sizeUnit,
            child: Text(
              team.information,
              maxLines: 3,
              style: SheepsTextStyle.b4(context).copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget SheepsFilterItem(BuildContext context, String name, bool isCheck){
  double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return Container(
      height: 24*sizeUnit,
      decoration: BoxDecoration(
        border: Border.all(color: isCheck == true? Color(0xff61C680) :Color(0xffEEEEEE), width: 1),
        borderRadius: BorderRadius.circular(8),
        color: isCheck == true? Color(0xff61C680) :Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7*sizeUnit),
            child: Text(
              name,
              style: SheepsTextStyle.b4(context).copyWith(color: isCheck == true?  Colors.white : Color(0xff888888)),
            ),
          ),
        ],
      )
  );
}

Widget SheepsMyPageInfo(BuildContext context, UserData user, AnimationController extendedController){
  double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
  return Container(
    color: Colors.white,
    height: 88*sizeUnit,
    child: Padding(
      padding: EdgeInsets.fromLTRB(12*sizeUnit, 0, 12*sizeUnit, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8*sizeUnit),
            child: user.profileUrlList[0] == 'BasicImage'
                ? Container(
              width: 72*sizeUnit,
              height: 72*sizeUnit,
              decoration: BoxDecoration(
                color: hexToColor('#F8F8F8'),
                borderRadius: new BorderRadius.circular(8*sizeUnit),
                border: Border.all(color: Colors.transparent),
              ),
              child: Center(
                  child: SvgPicture.asset(svgPersonalProfileBasicImage,
                    width: 72*sizeUnit,
                    height: 72*sizeUnit,
                  )
              ),
            )
                : Container(
              width: 72*sizeUnit,
              height: 72*sizeUnit,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(8*sizeUnit),
                border: Border.all(color: Colors.transparent),
              ),
              child: FittedBox(
                child: getExtendedImage(user.profileUrlList[0], 120, extendedController),
              ),
            ),
          ),
          SizedBox(width: 12*sizeUnit),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12*sizeUnit),
                child: Text(
                  user.name,
                  style: SheepsTextStyle.h3(context),
                ),
              ),
              Spacer(),
              Container(
                width: 252*sizeUnit,
                height: 48*sizeUnit,
                padding: EdgeInsets.only(bottom: 8*sizeUnit),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    runSpacing: 4*sizeUnit,
                    spacing: 4*sizeUnit,
                    children: [
                      user.part == null || user.part == ''
                          ? SizedBox.shrink()
                          : Container(
                        height: 18*sizeUnit,
                        decoration: BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(4*sizeUnit)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit, vertical: 2*sizeUnit),
                          child: Text(
                            user.part,
                            style: SheepsTextStyle.cat1(context).copyWith(height: 1.4),
                          ),
                        ),
                      ),
                      user.subPart == null || user.subPart == ''
                          ? SizedBox.shrink()
                          : Container(
                        height: 18*sizeUnit,
                        decoration: BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(4*sizeUnit)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit, vertical: 2*sizeUnit),
                          child: Text(
                            user.subPart,
                            style: SheepsTextStyle.cat1(context).copyWith(height: 1.4),
                          ),
                        ),
                      ),
                      user.location == null || user.location == ''
                          ? SizedBox.shrink()
                          : Container(
                        height: 18*sizeUnit,
                        decoration: BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(4*sizeUnit)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8*sizeUnit, vertical: 2*sizeUnit),
                          child: Text(
                            "${user.location}",
                            style: SheepsTextStyle.cat1(context).copyWith(height: 1.4),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}