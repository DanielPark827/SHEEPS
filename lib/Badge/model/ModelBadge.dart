import 'package:flutter/foundation.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/MyBadge.dart';



class PersonalBadge{
  int id;
  int BadgeID;
  int Category;
  String Part;
  int Condition;
  String createdAt;
  String updatedAt;

  PersonalBadge({this.id,this.createdAt,this.updatedAt,this.Category,this.Part,this.BadgeID,this.Condition});

  factory PersonalBadge.fromJson(Map<String, dynamic> json) {
    return PersonalBadge(
      id : json['id'] as int,
      BadgeID: json['BadgeID'] as int,
      Category: json['Category'] as int,
      Part: json['Part'] as String,
      Condition: json['Condition'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class PersonalBadgeDescription {
  int index;
  String Category;
  String Title;
  String Part;
  String Description;
  bool IsUserCanSelect;

  PersonalBadgeDescription(this.Category,this.Part,this.Title,this.Description);
}



Future initPersonalBadge() async{
  var list =  await ApiProvider().get('/Badge/SelectTable');
  PersonalBadgeTable.clear();
  if(list != null){
    for(int i = 0; i < list.length; ++i){
      Map<String, dynamic> data = list[i];

      PersonalBadge item = PersonalBadge.fromJson(data);
      PersonalBadgeTable.add(item);
      //await NotiDBHelper().createData(noti);
    }
  }

  for(int i = 0; i < PersonalBadgeDescriptionList.length; i++) {
    PersonalBadgeDescriptionList[i].index = i;
  }
}

List<PersonalBadge> PersonalBadgeTable = [];

//byRoy
List<int> PersonalBadge_Activity = [];
List<int> PersonalBadge_Career = [];
List<int> PersonalBadge_Achieve = [];
List<int> PersonalBadge_Award = [];
List<int> PersonalBadge_Licence = [];
List<int> PersonalBadge_Education = [];
List<int> PersonalBadge_Charm = [];

void initBadgePart() {
  bool Flag = false;

  if(GlobalProfile.loggedInUser.badgeList == null) return;

  for(int i = 0; i < GlobalProfile.loggedInUser.badgeList.length; i++) {
    BadgeModel item = GlobalProfile.loggedInUser.badgeList[i];
    for(int j = 0; j < PersonalBadgeTable.length; j++) {
      if(Flag) {
        Flag = false;
        break;
      }
      // if(PersonalBadgeTable[j].id == item.badgeID) {
      //   switch(PersonalBadgeTable[j].Category){
      //     case 1:
      //       PersonalBadge_Activity.add(item.badgeID);
      //       break;
      //     case 2:
      //       PersonalBadge_Career.add(item.badgeID);
      //       break;
      //     case 3:
      //       PersonalBadge_Achieve.add(item.badgeID);
      //       break;
      //     case 4:
      //       PersonalBadge_Award.add(item.badgeID);
      //       break;
      //     case 5:
      //       PersonalBadge_Licence.add(item.badgeID);
      //       break;
      //     case 6:
      //       PersonalBadge_Education.add(item.badgeID);
      //       break;
      //     case 7:
      //       PersonalBadge_Charm.add(item.badgeID);
      //       break;
      //   }
      // }
    }
  }
  debugPrint("Personal initBadgePart Success");
}

String ReturnPersonalBadgeSVG(int id) {
  switch(id) {
    case 1:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Profile1.svg';
      break;
    case 2:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Profile2.svg';
      break;

    case 3:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Community1.svg';
      break;
    case 4:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Community2.svg';
      break;
    case 5:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Community3.svg';
      break;
    case 6:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Community4.svg';
      break;

    case 7:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Badge1.svg';
      break;
    case 8:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Badge2.svg';
      break;
    case 9:
      return 'assets/images/Badge/PersonalBadge/svg_Activity_Badge3.svg';
      break;

    case 10:
      return 'assets/images/Badge/PersonalBadge/svg_Career_Career1.svg';
      break;
    case 11:
      return 'assets/images/Badge/PersonalBadge/svg_Career_Career2.svg';
      break;
    case 12:
      return 'assets/images/Badge/PersonalBadge/svg_Career_Career3.svg';
      break;
    case 13:
      return 'assets/images/Badge/PersonalBadge/svg_Career_Career4.svg';
      break;
    case 14:
      return 'assets/images/Badge/PersonalBadge/svg_Career_Career5.svg';
      break;

    case 15:
      return 'assets/images/Badge/PersonalBadge/svg_School_School1.svg';
      break;
    case 16:
      return 'assets/images/Badge/PersonalBadge/svg_School_School2.svg';
      break;
    case 17:
      return 'assets/images/Badge/PersonalBadge/svg_School_School3.svg';
      break;

    case 18:
      return 'assets/images/Badge/PersonalBadge/svg_Award_KAward1.svg';
      break;
    case 19:
      return 'assets/images/Badge/PersonalBadge/svg_Award_KAward2.svg';
      break;
    case 20:
      return 'assets/images/Badge/PersonalBadge/svg_Award_KAward3.svg';
      break;
    case 21:
      return 'assets/images/Badge/PersonalBadge/svg_Award_KAward4.svg';
      break;

    case 22:
      return 'assets/images/Badge/PersonalBadge/svg_Award_ForeignAward1.svg';
      break;

    case 23:
      return 'assets/images/Badge/PersonalBadge/svg_Award_AwardCount1.svg';
      break;
    case 24:
      return 'assets/images/Badge/PersonalBadge/svg_Award_AwardCount2.svg';
      break;
    case 25:
      return 'assets/images/Badge/PersonalBadge/svg_Award_AwardCount3.svg';
      break;

    case 26:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_Ntech1.svg';
      break;
    case 27:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_Ntech2.svg';
      break;
    case 28:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_Ntech3.svg';
      break;
    case 29:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_Ntech4.svg';
      break;
    case 30:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_Ntech5.svg';
      break;

    case 31:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_NExpert1.svg';
      break;

    case 32:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_Private1.svg';
      break;

    case 33:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_CCount1.svg';
      break;
    case 34:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_CCount2.svg';
      break;
    case 35:
      return 'assets/images/Badge/PersonalBadge/svg_Certification_CCount3.svg';
      break;

    case 36:
      return 'assets/images/Badge/PersonalBadge/svg_Education_Government.svg';
      break;

    case 37:
      return 'assets/images/Badge/PersonalBadge/svg_Education_Private.svg';
      break;

    case 38:
      return 'assets/images/Badge/PersonalBadge/svg_Education_Count1.svg';
      break;
    case 39:
      return 'assets/images/Badge/PersonalBadge/svg_Education_Count2.svg';
      break;
    case 40:
      return 'assets/images/Badge/PersonalBadge/svg_Education_Count3.svg';
      break;

    case 41:
      return 'assets/images/Badge/PersonalBadge/svg_Appeal_Fight1.svg';
      break;
    case 42:
      return 'assets/images/Badge/PersonalBadge/svg_Appeal_Fight2.svg';
      break;
    case 43:
      return 'assets/images/Badge/PersonalBadge/svg_Appeal_Fight3.svg';
      break;
    case 44:
      return 'assets/images/Badge/PersonalBadge/svg_Appeal_Fight4.svg';
      break;
  }
}
class TeamBadge{
  int id;
  int BadgeID;
  int Category;
  String Part;
  int Condition;
  String createdAt;
  String updatedAt;

  TeamBadge({this.id,this.createdAt,this.updatedAt,this.Category,this.Part,this.BadgeID,this.Condition});

  factory TeamBadge.fromJson(Map<String, dynamic> json) {
    return TeamBadge(
      id : json['id'] as int,
      BadgeID: json['BadgeID'] as int,
      Category: json['Category'] as int,
      Part: json['Part'] as String,
      Condition: json['Condition'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

List<TeamBadge> TeamBadgeTable = [];
Future initTeamBadge() async{
  var list =  await ApiProvider().get('/Badge/SelectTeamTable');
  TeamBadgeTable.clear();
  if(list != null){
    for(int i = 0; i < list.length; ++i){
      Map<String, dynamic> data = list[i];

      TeamBadge item = TeamBadge.fromJson(data);
      TeamBadgeTable.add(item);
    }
  }

  for(int i = 0; i < TeamBadgeDescriptionList.length; i++) {
    TeamBadgeDescriptionList[i].index = i;
  }
}
class TeamBadgeDescription {
  int index;
  String Category;
  String Title;
  String Part;
  String Description;
  bool IsTeamCanSelect;

  TeamBadgeDescription(this.Category,this.Part,this.Title,this.Description);
}


String ReturnTeamBadgeSVG(int id) {
  switch(id) {
    case 1:
      return 'assets/images/Badge/TeamBadge/svg_TActivity_TProfile1.svg';
      break;
    case 2:
      return 'assets/images/Badge/TeamBadge/svg_TActivity_TProfile2.svg';
      break;

    case 3:
      return 'assets/images/Badge/TeamBadge/svg_TActivity_TBadge1.svg';
      break;
    case 4:
      return 'assets/images/Badge/TeamBadge/svg_TActivity_TBadge2.svg';
      break;
    case 5:
      return 'assets/images/Badge/TeamBadge/svg_TActivity_TBadge3.svg';
      break;

    case 6:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TCompany1.svg';
      break;
    case 7:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TCompany2.svg';
      break;
    case 8:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TCompany3.svg';
      break;
    case 9:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TCompany4.svg';
      break;

    case 10:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPeopleSize1.svg';
      break;
    case 11:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPeopleSize2.svg';
      break;
    case 12:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPeopleSize3.svg';
      break;
    case 13:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPeopleSize4.svg';
      break;

    case 14:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TMemberSize1.svg';
      break;
    case 15:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TMemberSize2.svg';
      break;
    case 16:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TMemberSize3.svg';
      break;
    case 17:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TMemberSize4.svg';
      break;

    case 18:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSpace.svg';
      break;
    case 19:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSpace.svg';
      break;
    case 20:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSpace.svg';
      break;
    case 21:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSpace.svg';
      break;

    case 22:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_Venture.svg';
      break;
    case 23:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_InoBusiness.svg';
      break;
    case 24:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_CompanyLab.svg';
      break;
    case 25:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_LabPart.svg';
      break;
    case 26:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_Familiar.svg';
      break;
    case 27:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_LabCompnay.svg';
      break;

    case 28:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TAssignment1.svg';
      break;
    case 29:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TAssignment2.svg';
      break;
    case 30:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TAssignment3.svg';
      break;
    case 31:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TAssignment4.svg';
      break;
    case 32:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TAssignment5.svg';
      break;

    case 33:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSaleSize1.svg';
      break;
    case 34:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSaleSize2.svg';
      break;
    case 35:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSaleSize3.svg';
      break;
    case 36:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSaleSize4.svg';
      break;
    case 37:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TSaleSize5.svg';
      break;

    case 38:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TInvestSize1.svg';
      break;
    case 39:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TInvestSize2.svg';
      break;
    case 40:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TInvestSize3.svg';
      break;
    case 41:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TInvestSize4.svg';
      break;
    case 42:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TInvestSize5.svg';
      break;

    case 43:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPatent1.svg';
      break;
    case 44:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPatent2.svg';
      break;
    case 45:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPatent3.svg';
      break;
    case 46:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPatent4.svg';
      break;
    case 47:
      return 'assets/images/Badge/TeamBadge/svg_TCareer_TPatent5.svg';
      break;

    case 48:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TKAward1.svg';
      break;
    case 49:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TKAward2.svg';
      break;
    case 50:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TKAward3.svg';
      break;
    case 51:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TKAward4.svg';
      break;

    case 52:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TforeignAward1.svg';
      break;

    case 53:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TAwardCount1.svg';
      break;
    case 54:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TAwardCount2.svg';
      break;
    case 55:
      return 'assets/images/Badge/TeamBadge/svg_TAward_TAwardCount3.svg';
      break;

    case 56:
      return 'assets/images/Badge/TeamBadge/svg_TAppeal_TSmoking.svg';
      break;
  }
}


void initAllBadge() async {//Badge Table Initialize
  await initPersonalBadge();
  await initTeamBadge();
  if(PersonalBadgeTable.length > 0) {
    initBadgePart();
  }
}


List<PersonalBadgeDescription> PersonalBadgeDescriptionList = [//index와 id와 동기화
  PersonalBadgeDescription("","","",""),
  PersonalBadgeDescription("활동","자랑중..","프로필 완성도 70%","나머지 프로필도 완성해 보세요!"),
  PersonalBadgeDescription("활동","자랑완료","프로필 완성도 100%","프로필을 전부 완성했어요!"),

  PersonalBadgeDescription("활동","음유시인","커뮤니티 게시글 및 댓글 50개","스타트업만을 위한 최초의 앱 커뮤니티!\n활동해주셔서 감사합니다.☺️"),
  PersonalBadgeDescription("활동","수필작가 ","커뮤니티 게시글 및 댓글 100개","항상 당신의 이야기를 공유해줘서\n너무 감사합니다.😚"),
  PersonalBadgeDescription("활동","단편소설가 ","커뮤니티 게시글 및 댓글 200개","당신만을 위한 게시판을 개설하겠습니다.\n(충성충성)"),
  PersonalBadgeDescription("활동","장편소설가 ","커뮤니티 게시글 및 댓글 400개","당신은 혹시 박찬호 인가요?\n그렇다면 홍보모델로..\n-쉽스 홍보팀-"),
  PersonalBadgeDescription("활동","뱃지 수집가","뱃지 개수 10개"," 뱃지를 10개 이상 모으셨어요!"),
  PersonalBadgeDescription("활동","열혈 뱃지 수집가","뱃지 개수 20개"," 뱃지를 20개 이상 모으셨어요!"),
  PersonalBadgeDescription("활동","최고 뱃지 수집가","뱃지 개수 40개","더이상 모을 뱃지가 없는걸요?"),

  PersonalBadgeDescription("경력","중고신입","경력 1년","겸손함과 노련미를 겸비했습니다!"),
  PersonalBadgeDescription("경력","사춘기직딩 ","경력 2년","직딩도 사춘기만 넘으면 성숙해집니다!"),
  PersonalBadgeDescription("경력","한창실세 ","경력 3년","업무는 이제 눈감고 발로도 가능해요!"),
  PersonalBadgeDescription("경력","할거다한 ","경력 5년","마! 내가 느그 팀장이랑! 어!\n프로젝트도 하고! 어! 다했어!"),
  PersonalBadgeDescription("경력","베테랑 ","경력 7년 이상","지금 내 기분이 그래. 어이가 없네?\n-쉽스 채용팀-"),

  PersonalBadgeDescription("학력","학사","최종 학력 학사","양이라는 동물에 대해 공부했어요!"),
  PersonalBadgeDescription("학력","석사","최종 학력 석사","양의 감각기관에 대해 공부했어요!"),
  PersonalBadgeDescription("학력","박사","최종 학력 박사","양의 귀여운 코의 표면에 자라는\n솜털에 대해 공부했어요!"),

  PersonalBadgeDescription("수상","일반수상 ","국내 수상 상장수상 "," 대회에서 수상을 했어요!"),
  PersonalBadgeDescription("수상","기관장  ","국내 수상 기관장상 ","기관장상을 받았어요! 멋지죠!"),
  PersonalBadgeDescription("수상","장관 ","국내 수상 장관상 "," 장관상을 받았어요! 나는 정말 대단해!"),
  PersonalBadgeDescription("수상","대통령","국내 수상 대통령상 ","대한민국 발전에 이바지한 공로가 크므로\n이에 표창합니다.\n-양통령 양쓰-"),

  PersonalBadgeDescription("수상","해외수상파 ","해외 수상","해외에서도 참지 못하고\n실력을 뽐내고 왔습니다!"),

  PersonalBadgeDescription("수상","따놓은당상 ","수상 횟수 3개","어딜가나 수상하는 저는 능력자에요!"),
  PersonalBadgeDescription("수상","상장수집가 ","수상 횟수 5개","이정도면 상 받는게 취미라고 해도 되겠네요!"),
  PersonalBadgeDescription("수상","들숨에 수, 날숨에 상","수상 횟수 10개","숨만 쉬어도 상을 받는 당신! 탐나는군요?\n-쉽스 채용팀-"),

  PersonalBadgeDescription("자격증","기능사","국가 기능사","수준 높은 숙련기능을 보유하고 있습니다!"),
  PersonalBadgeDescription("자격증","산업기사","국가 산업기사","기능사보다 한층 수준 높은\n숙련기능을 보유하고 있습니다!"),
  PersonalBadgeDescription("자격증","기사","국가 기사","중세 서유럽에서의 무장기병전사(?) 입니다!"),
  PersonalBadgeDescription("자격증","기능장","국가 기능장","분야에 대한\n최상급 숙련기능을 보유하고 있습니다!"),
  PersonalBadgeDescription("자격증","기술사","국가 기술사","분야에 대한 고도의 전문지식과 실무경험에\n입각한 응용능력을 보유하고 있습니다!"),

  PersonalBadgeDescription("자격증","국가전문자격증 ","국가 전문 보유"," 정부부처에서 주관하는 자격증이 있습니다!"),
  PersonalBadgeDescription("자격증","민간자격증 ","민간자격증 보유","한국직업능력개발원의\n'민간자격 정보서비스'에 등록되어 있습니다!"),
  PersonalBadgeDescription("자격증","자격증 다수","자격증 3개","나도 어디서 꿀리진 않어, 자격증이 3개니깐."),
  PersonalBadgeDescription("자격증","자격증 부자","자격증 5개","내가 희생한 컴싸와 OMR 카드만 해도\n어느덧 세자리..."),
  PersonalBadgeDescription("자격증","자격증 왕","자격증 7개","너가 정말 그럴 자격이 된다고 생각해?\n응."),

  PersonalBadgeDescription("교육","정부 교육 수료","정부 교육 수료","정부에서 주관하는 교육을 수료했어요!"),
  PersonalBadgeDescription("교육","자랑완료","민간교육 수료","민간에서 주관하는 교육을 수료했어요!"),
  PersonalBadgeDescription("교육","늘새로이","교육 횟수 2회","새로운 걸 배운다는 것, 짜릿하더군요."),
  PersonalBadgeDescription("교육","늘배움이","교육 횟수 4회","저희 어머니가\n배움에는 끝이 없다고 했습니다."),
  PersonalBadgeDescription("교육","늘앞자리","교육 횟수 6회","자, 이제 쉽스에서 강의를 할 차례입니다.\n-쉽스 채용팀-"),

  PersonalBadgeDescription("매력","고려","단증 1단","통나무 잡고, 손날치기, 이단 옆차기! 파박!"),
  PersonalBadgeDescription("매력","금강","단증 3단","강함과 무거움을 의미하는 나의 강한 의지..."),
  PersonalBadgeDescription("매력","태백","단증 5단","홍익인간의 정신을 담고 있는 사람입니다."),
  PersonalBadgeDescription("매력","바람의 파이터","단증 7단","황소의 소뿔은 분필 조각처럼 부러지더군요."),
];

List<TeamBadgeDescription> TeamBadgeDescriptionList = [
  TeamBadgeDescription("","","",""),
  TeamBadgeDescription("활동","팀 소개중","프로필 70%","높은 프로필 완성도로, 팀 모집을 더 쉽게!"),
  TeamBadgeDescription("활동","팀 소개완료","프로필 100%","꾸준히 팀 프로필을 업데이트 해주세요.😀"),

  TeamBadgeDescription("활동","팀 뱃지 10개","뱃지 10개","팀 뱃지 10개를 모았어요!"),
  TeamBadgeDescription("활동","팀 뱃지 20개","뱃지 20개","팀 뱃지 20개를 모았어요!"),
  TeamBadgeDescription("활동","팀 뱃지 50개","뱃지 50개","팀 뱃지 50개를 모았어요!"),

  TeamBadgeDescription("경력","개인사업자","개인 기업","개인사업자 인증이 완료되었습니다."),
  TeamBadgeDescription("경력","법인사업자","법인 기업","법인사업자 인증이 완료되었습니다."),
  TeamBadgeDescription("경력","사회적기업","사회적 기업","사회적기업 인증이 완료되었습니다."),
  TeamBadgeDescription("경력","사업자","기타 기업","사업자 인증이 완료되었습니다."),

  TeamBadgeDescription("경력","임직원 3명","직원규모 3명","임직원 3명 달성!"),
  TeamBadgeDescription("경력","임직원 5명","직원규모 5명","임직원 5명 달성!"),
  TeamBadgeDescription("경력","임직원 7명","직원규모 7명","임직원 7명 달성!"),
  TeamBadgeDescription("경력","임직원 7명","직원규모 10명 이상","임직원 10명 달성!"),

 TeamBadgeDescription("경력","팀원 3명","팀원 3명","팀원 3명 달성!"),
 TeamBadgeDescription("경력","팀원 5명","팀원 5명","팀원 5명 달성!"),
 TeamBadgeDescription("경력","팀원 7명","팀원 7명","팀원 7명 달성!"),
 TeamBadgeDescription("경력","팀원 10명","팀원 10명","팀원 10명 달성!"),

 TeamBadgeDescription("경력","사업장 보유","사업장 보유","팀원들을 위한 사업장이 준비되어있습니다!"),
 TeamBadgeDescription("경력","wework","공유오피스","wework에 입주해 있어요!"),
 TeamBadgeDescription("경력","FASTFIVE","공유오피스","FASTFIVE에 입주해 있어요!"),
 TeamBadgeDescription("경력","보육센터 입주","보육센터","보육센터에 입주해 있어요!"),

 TeamBadgeDescription("경력","벤처기업","벤처기업 인증","벤처기업 인증을 받았어요!"),
 TeamBadgeDescription("경력","이노비즈","이노비즈 인증","이노비즈 인증을 받았어요!"),
 TeamBadgeDescription("경력","기업부설 연구소","기업부설 연구소","기업부설 연구소를 설립했어요!"),
 TeamBadgeDescription("경력","연구전담부서","연구전담부서","연구전담부서를 보유하고 있어요!"),
 TeamBadgeDescription("경력","가족친화형","가족친화형","가족친화형 인증을 받았어요!"),
 TeamBadgeDescription("경력","연구소 기업","연구소 기업","국가에서 인증받은 연구소 기업입니다."),

  TeamBadgeDescription("경력","과제규모 1천만원","1천","1천만원 규모 이상의 과제를 수행했어요!"),
  TeamBadgeDescription("경력","과제규모 5천만원","5천","5천만원 규모 이상의 과제를 수행했어요!"),
  TeamBadgeDescription("경력","과제규모 1억원","1억","1억원 규모 이상의 과제를 수행했어요!"),
  TeamBadgeDescription("경력","과제규모 3억원","3억","3억원 규모 이상의 과제를 수행했어요!"),
  TeamBadgeDescription("경력","과제규모 5억원","5억 이상","5억원 규모 이상의 과제를 수행했어요!"),

  TeamBadgeDescription("경력","연 매출 1천만원","연 매출 1천만원","연 매출 1천만원 이상을 달성했어요!"),
  TeamBadgeDescription("경력","연 매출 5천만원","연 매출 5천만원","연 매출 5천만원 이상을 달성했어요!"),
  TeamBadgeDescription("경력","연 매출 1억원","연 매출 1억원","연 매출 5천만원 이상을 달성했어요!"),
  TeamBadgeDescription("경력","연 매출 3억원","연 매출 3억원","연 매출 3억원 이상을 달성했어요!"),
  TeamBadgeDescription("경력","연 매출 7억원","연 매출 7억원","연 매출 7억원 이상을 달성했어요!"),

  TeamBadgeDescription("경력","투자유치 1천만원","투자유치 1천만원","1천만원 이상의 투자를 유치했어요!"),
  TeamBadgeDescription("경력","투자유치 5천만원","투자유치 5천만원","5천만원 이상의 투자를 유치했어요!"),
  TeamBadgeDescription("경력","투자유치 1억원","투자유치 1억원","1억원 이상의 투자를 유치했어요!"),
  TeamBadgeDescription("경력","투자유치 3억원","투자유치 3억원","3억원 이상의 투자를 유치했어요!"),
  TeamBadgeDescription("경력","투자유치 5억원","투자유치 5억원"," 5억원 이상의 투자를 유치했어요!"),

  TeamBadgeDescription("경력","1개 특허보유","특허 등록 1개","1개의 등록 특허를 보유했어요!"),
  TeamBadgeDescription("경력","3개 특허보유","특허 등록 3개","3개의 등록 특허를 보유했어요!"),
  TeamBadgeDescription("경력","5개 특허보유","특허 등록 5개","5개의 등록 특허를 보유했어요!"),
  TeamBadgeDescription("경력","10개 특허보유","특허 등록 10개","10개의 등록 특허를 보유했어요!"),
  TeamBadgeDescription("경력","20개 특허보유","특허 등록 20개 이상","20개 이상의 등록 특허를 보유했어요!"),

  TeamBadgeDescription("수상","수상경력","일반수상","수상 경력을 보유하고 있어요!"),
  TeamBadgeDescription("수상","기관장상","기관장","기관장급 수상 경력을 보유하고 있어요!"),
  TeamBadgeDescription("수상","장관상","장관","장관급 수상 경력을 보유하고 있어요!"),
  TeamBadgeDescription("수상","대통령상","대통령","대통령급 수상 경력을 보유하고 있어요!"),

  TeamBadgeDescription("수상","해외수상","해외수상","해외에서 수상한 경력을 보유하고 있어요!"),

  TeamBadgeDescription("수상","수상경력 3회","수상경력 3회","수상경력이 3회 이상이에요!"),
  TeamBadgeDescription("수상","수상경력 5회","수상경력 5회","수상경력이 5회 이상이에요!"),
  TeamBadgeDescription("수상","수상경력 5회","수상경력 5회","수상경력이 10회 이상이에요!"),

  TeamBadgeDescription("매력","비흡연","비흡연자 서약서","팀원 모두가 비흡연자에요!"),
];
