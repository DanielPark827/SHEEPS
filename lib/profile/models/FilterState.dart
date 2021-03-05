import 'package:flutter/material.dart';

class FilterStateForPersonal extends ChangeNotifier{
  //개인프로필 필터
  AlignmentGeometry tabAlignForPerson = Alignment.centerLeft;
  //분야야
  List<String> catNameForPerson = ["개발","게임","경영/비즈니스","서비스/리테일","금융","디자인","마케팅/광고","물류/무역","미디어","법률 관련","영업","인사/교육","정부/비영리","제조/생산"];
  List<bool> cataForPerson = List<bool>.filled(14, false, growable: true);
  //지역
  List<String> locationNameForPerson = ["서울","부산","대구","인천","광주","대전","울산","세종","경기","강원","충북","충남","전북","전남","경북","경남","제주"];
  List<bool> locaForPerson = List<bool>.filled(17, false, growable: true);




  AlignmentGeometry tabAlignForTeam = Alignment.centerLeft;
 //분야
  List<String> catNameForTeam = ["IT","제조","건설","물류/유통","농·축·수산","부동산","요식업","에너지","교육","연규·기술·전문서비스","문화/여가","해외기관/법인","시설/기타 지원","기타"];
  List<bool> cataForTeam = List<bool>.filled(14, false, growable: true);
  //지역
  List<String> locationNameForTeam = ["서울","부산","대구","인천","광주","대전","울산","세종","경기","강원","충북","충남","전북","전남","경북","경남","제주"];
  List<bool> locaForTeam = List<bool>.filled(17, false, growable: true);

  List<String> distingNameForTeam = ["예비창업팀","프로젝트팀","소모임","개인기업","법인기업","사회적기업","협동조합","기관"];
  List<bool> distingForTeam = List<bool>.filled(8, false, growable: true);
}
