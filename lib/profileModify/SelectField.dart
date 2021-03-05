import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/profileModify/models/DummyForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class SelectField extends StatefulWidget {
  SelectField({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SelectFieldState createState() => _SelectFieldState();
}

class _SelectFieldState extends State<SelectField> {
  TextEditingController editingController = TextEditingController();
  double sizeUnit = 1;

  var items = List<String>();

  @override
  void initState() {
    items.addAll(FieldCategory);
    super.initState();
  }

  void filterSearchResults(String query) {

    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(FieldAllCategory);

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
        items.addAll(FieldCategory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    ModifiedProfile _ModifiedProfile = Provider.of<ModifiedProfile>(context);


    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: hexToColor("#FFFFFF"),
        appBar: SheepsAppBar(
          context,
          '분야 선택',
          backFunc: () {
            Navigator.pop(context, false);
          }
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12*sizeUnit),
              child: Container(
                height: 32*sizeUnit,
                child: TextField(
                  textAlign: TextAlign.left,
                  controller: editingController,
                  decoration: InputDecoration(
                    hintText: '분야 검색하기',
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
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(thickness: 1,height: 1,color: hexToColor("#F8F8F8"),),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return FlatButton(
                    onPressed: (){
                      if(!FieldCategory.contains(items[index])) {
                        if(_ModifiedProfile.IfThisSubField == false) {
                          _ModifiedProfile.ChangePart('${items[index]}');
                          if( _ModifiedProfile.name != null &&
                              _ModifiedProfile.location != null && _ModifiedProfile.Introduce != null) {
                            _ModifiedProfile.ChangeProfileModifyClear(true);
                          } else {
                            _ModifiedProfile.ChangeProfileModifyClear(false);
                          }
                        }
                        else {
                          _ModifiedProfile.ChangeSubPart('${items[index]}');
                        }
                        _ModifiedProfile.ChangeIfThisSubField(false);
                        Navigator.pop(context, true);
                      }
                      else {
                        if(items[index] == '개발') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('개발');
                            } else {
                              _ModifiedProfile.ChangeSubField('개발');
                            }
                            items.addAll(FieldDevelopCategory);
                          });
                        } else if(items[index] == '게임') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('게임');
                            } else {
                              _ModifiedProfile.ChangeSubField('게임');
                            }
                            items.addAll(FieldGameCategory);
                          });
                        } else if(items[index] == '경영/비즈니스') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('경영/비즈니스');
                            } else {
                              _ModifiedProfile.ChangeSubField('경영/비즈니스');
                            }
                            items.addAll(FieldBusinessCategory);
                          });
                        } else if(items[index] == '서비스/리테일') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('서비스/리테일');
                            } else {
                              _ModifiedProfile.ChangeSubField('서비스/리테일');
                            }
                            items.addAll(FieldServiceCategory);
                          });
                        } else if(items[index] == '금융') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('금융');
                            } else {
                              _ModifiedProfile.ChangeSubField('금융');
                            }
                            items.addAll(FieldFianceCategory);
                          });
                        } else if(items[index] == '디자인') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('디자인');
                            } else {
                              _ModifiedProfile.ChangeSubField('디자인');
                            }
                            items.addAll(FieldDesignCategory);
                          });
                        } else if(items[index] == '마케팅/광고') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('마케팅/광고');
                            } else {
                              _ModifiedProfile.ChangeSubField('마케팅/광고');
                            }
                            items.addAll(FieldAdsCategory);
                          });
                        } else if(items[index] == '물류/무역') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('물류/무역');
                            } else {
                              _ModifiedProfile.ChangeSubField('물류/무역');
                            }
                            items.addAll(FieldTradeCategory);
                          });
                        } else if(items[index] == '미디어') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('미디어');
                            } else {
                              _ModifiedProfile.ChangeSubField('미디어');
                            }
                            items.addAll(FieldMediaCategory);
                          });
                        } else if(items[index] == '법률 관련') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('법률 관련');
                            } else {
                              _ModifiedProfile.ChangeSubField('법률 관련');
                            }
                            items.addAll(FieldLawCategory);
                          });
                        } else if(items[index] == '영업') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('영업');
                            } else {
                              _ModifiedProfile.ChangeSubField('영업');
                            }
                            items.addAll(FieldSellCategory);
                          });
                        } else if(items[index] == '인사/교육') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('인사/교육');
                            } else {
                              _ModifiedProfile.ChangeSubField('인사/교육');
                            }
                            items.addAll(FieldEduCategory);
                          });
                        } else if(items[index] == '정부/비영리') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('정부/비영리');
                            } else {
                              _ModifiedProfile.ChangeSubField('정부/비영리');
                            }
                            items.addAll(FieldGovernmentCategory);
                          });
                        } else if(items[index] == '제조/생산') {
                          setState(() {
                            items.clear();
                            if(_ModifiedProfile.IfThisSubField == false) {
                              _ModifiedProfile.ChangeMainField('제조/생산');
                            } else {
                              _ModifiedProfile.ChangeSubField('제조/생산');
                            }
                            items.addAll(FieldFoundaryCategory);
                          });
                        }
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

