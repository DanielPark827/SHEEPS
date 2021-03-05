import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/profile/models/ModelAddTeam.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class SelectAddTeamField extends StatefulWidget {
  SelectAddTeamField({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SelectTeamFieldState createState() => _SelectTeamFieldState();
}

class _SelectTeamFieldState extends State<SelectAddTeamField> {
  double sizeUnit = 1;
  TextEditingController editingController = TextEditingController();

  var items = List<String>();
  List<String> TeamFieldList = ["IT", "제조", "건설","물류/유통","농·축·수산","부동산","요식업","에너지","교육","문화/여가","연구・기술・전문서비스","해외기관/법인","시설/기타 지원","기타"];

  @override
  void initState() {
    items.addAll(TeamFieldList);
    super.initState();
  }

  void filterSearchResults(String query) {

    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(TeamFieldList);

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
        items.addAll(TeamFieldList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    ModelAddTeam _ModifiedTeamProfile = Provider.of<ModelAddTeam>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: hexToColor("#FFFFFF"),
        appBar: SheepsAppBar(context, '분야 선택'),
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
                    hintText: '분야 검색하기',
                    hintStyle: SheepsTextStyle.b4(context),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(top: 8*sizeUnit, bottom: 8*sizeUnit),
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
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(width: 1,color: hexToColor(("#61C680"))),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
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
              child: ListView.separated(
                separatorBuilder: (context,index) => Container(
                    height: 1, width: double.infinity, color: hexToColor('#eeeeee')),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return FlatButton(
                    onPressed: (){
                      _ModifiedTeamProfile.ChangeTeamField(items[index]);
                      Navigator.pop(context);

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
                              )),
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

