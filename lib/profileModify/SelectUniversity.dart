import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/profileModify/UploadCompleteForPersonalGraduate.dart';
import 'package:sheeps_app/profileModify/UploadForPersonalGraduate.dart';
import 'package:sheeps_app/profileModify/UploadForPersonalUniv.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class SelectUniversity extends StatefulWidget {
  SelectUniversity({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SelectUniversityState createState() => _SelectUniversityState();
}

class _SelectUniversityState extends State<SelectUniversity> {
  TextEditingController editingController = TextEditingController();

  double sizeUnit = 1;
  var items = List<String>();

  @override
  void initState() {
    items.addAll(UniversityCategory);
    super.initState();
  }

  void filterSearchResults(String query) {

    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(UniversityCategory);

    if(query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {

        if(item.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(UniversityCategory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ModifiedProfile _ModifiedProfile = Provider.of<ModifiedProfile>(context);
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: hexToColor("#FFFFFF"),
        appBar: SheepsAppBar(context, '대학교 추가'),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12*sizeUnit),
              child: SizedBox(
                height: 32*sizeUnit,
                child: TextField(
                  textAlign: TextAlign.left,
                  controller: editingController,
                  decoration: InputDecoration(
                    hintText: '대학교 이름 검색하기',
                    hintStyle: SheepsTextStyle.b4(context),
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8*sizeUnit),
                      child: SvgPicture.asset(
                        svgGreyMagnifyingGlass,
                        width: 16*sizeUnit,
                        height: 16*sizeUnit,
                      ),
                    ),
                    fillColor: hexToColor("#EEEEEE"),
                    filled: true,
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8*sizeUnit),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                      borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                      borderSide: BorderSide(width: 1,color: hexToColor(("#EEEEEE"))),
                    ),
                  ),
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return FlatButton(
                    onPressed: (){
                      if(_ModifiedProfile.IfThisGraduateSchool == true) {
                        _ModifiedProfile.ChangeGraduateSchool(items[index]);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    UploadForPersonalGraduate()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          Navigator.pop(context);
                        });
                      } else {
                        _ModifiedProfile.ChangeUniversity(items[index]);
                        _ModifiedProfile.ChangeIfThisGraduateSchool(false);
                        Navigator.push(
                            context, // 기본 파라미터, SecondRoute로 전달
                            MaterialPageRoute(
                                builder: (context) =>
                                    UploadForPersonalUniv()) // SecondRoute를 생성하여 적재
                        ).then((value) {
                          Navigator.pop(context);
                        });
                      }

                    },
                    child: Container(
                      height: 48*sizeUnit,
                      child: Row(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${items[index]}',
                                style: SheepsTextStyle.b1(context),
                              )
                          ),
                          Expanded(child: SizedBox()),
                          SvgPicture.asset(
                            svgGreyNextIcon,
                            width: 16*sizeUnit,
                            height: 16*sizeUnit,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

