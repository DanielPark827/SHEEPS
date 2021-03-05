import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';

class Community{
  int id;
  int userID;
  String category;
  String title;
  String contents;
  String imageUrl1;
  String imageUrl2;
  String imageUrl3;
  String createdAt;
  String updatedAt;
  List<CommunityLike> communityLike;
  List<CommunityReplyLight> communityReply;

  Community({this.id, this.userID, this.category, this.title, this.contents, this.imageUrl1, this.imageUrl2, this.imageUrl3, this.createdAt, this.updatedAt, this.communityReply, this.communityLike});

  factory Community.fromJson(Map<String, dynamic> json) {
    List<CommunityReplyLight> tmp2 = List();

    if(json['CommunityReplies'] != null){
      for(int i =0;i<(json['CommunityReplies'] as List).length;i++){
        Map<String, dynamic> data = (json['CommunityReplies'] as List)[i];
        CommunityReplyLight tt = CommunityReplyLight.fromJson(data);
        tmp2.add(tt);
      }
    }

    List<CommunityLike> tmp = List();
    if(json['CommunityLikes'] != null) {
      for(int i =0;i<(json['CommunityLikes'] as List).length;i++){
        Map<String,dynamic> data = (json['CommunityLikes'] as List)[i];
        CommunityLike tmpLike = CommunityLike.fromJson(data);
        tmp.add(tmpLike);
      }
    }

    return Community(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      category: json['Category'] as String,
      title: json['Title'] as String,
      contents: json['Contents'] as String,
      imageUrl1: json['ImageUrl1'] == null ? null : ApiProvider().getUrl + json['ImageUrl1'],
      imageUrl2: json['ImageUrl2'] == null ? null : ApiProvider().getUrl + json['ImageUrl2'],
      imageUrl3: json['ImageUrl3'] == null ? null : ApiProvider().getUrl + json['ImageUrl3'],
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
      communityLike: tmp,
      communityReply: tmp2,
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userID' : userID,
    'category' : category,
    'title' : title,
    'contents' : contents,
    'imageUrl1' : imageUrl1,
    'imageUrl2' : imageUrl2,
    'imageUrl3' : imageUrl3,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'CommunityLikes' : communityLike,
    'CommunityReplies' : communityReply,
  };
}

class CommunityReplyLight{
  int id;
  int userID;
  int postID;
  String contents;
  String createdAt;
  String updatedAt;

  CommunityReplyLight({this.id, this.userID, this.postID, this.contents,this.createdAt, this.updatedAt});

  factory  CommunityReplyLight.fromJson(Map<String, dynamic> json) {
    return  CommunityReplyLight(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      postID: json['PostID'] as int,
      contents: json['Contents'] as String,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'UserID' : userID,
    'PostID' : postID,
    'Contexts' : contents,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}
class InsertReplyReplyLike{
  CommunityReplyReplyLike item;
  bool created;
  InsertReplyReplyLike({this.item, this.created});
  factory InsertReplyReplyLike.fromJson(Map<String,dynamic> json){
    Map<String,dynamic> data = json['item'];
    CommunityReplyReplyLike tmpLike = CommunityReplyReplyLike.fromJson(data);

    return InsertReplyReplyLike(
      item: tmpLike,
      created: json['created'] as bool,
    );
  }
  Map<String, dynamic> toJson() =>{
    'item' : item,
    'created' : created,
  };
}
class InsertReplyLike{
  CommunityReplyLike item;
  bool created;
  InsertReplyLike({this.item, this.created});
  factory InsertReplyLike.fromJson(Map<String,dynamic> json){
    Map<String,dynamic> data = json['item'];
    CommunityReplyLike tmpLike = CommunityReplyLike.fromJson(data);

    return InsertReplyLike(
      item: tmpLike,
      created: json['created'] as bool,
    );
  }
  Map<String, dynamic> toJson() =>{
    'item' : item,
    'created' : created,
  };
}
class InsertLike{
  CommunityLike item;
  bool created;
  InsertLike({this.item, this.created});
  factory InsertLike.fromJson(Map<String,dynamic> json){
    if((json['created'] as bool) == false) return null;

    Map<String,dynamic> data = json['item'];
    CommunityLike tmpLike = CommunityLike.fromJson(data);

    return InsertLike(
      item: tmpLike,
      created: json['created'] as bool,
    );
  }
  Map<String, dynamic> toJson() =>{
    'item' : item,
    'created' : created,
  };
}
class CommunityLike{
  int id;
  int userID;
  int postID;
  String createdAt;
  String updatedAt;

  CommunityLike({this.id, this.userID, this.postID, this.createdAt, this.updatedAt});

  factory  CommunityLike.fromJson(Map<String, dynamic> json) {
    return  CommunityLike(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      postID: json['PostID'] as int,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'UserID' : userID,
    'PostID' : postID,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}
class CommunityReplyLike{
  int id;
  int userID;
  int replyID;
  String createdAt;
  String updatedAt;

  CommunityReplyLike({this.id, this.userID, this.replyID, this.createdAt, this.updatedAt});

  factory  CommunityReplyLike.fromJson(Map<String, dynamic> json) {
    return  CommunityReplyLike(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      replyID: json['ReplyID'] as int,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'UserID' : userID,
    'ReplyID' : replyID,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}

class CommunityReply{
  int id;
  int userID;
  int postID;
  String contents;
  String createdAt;
  String updatedAt;
  List<CommunityReplyLike> communityReplyLike;
  List<CommunityReplyReply> communityReplyReply;

  CommunityReply({this.id, this.userID, this.contents, this.createdAt, this.updatedAt, this.postID, this.communityReplyLike,this.communityReplyReply});

  factory CommunityReply.fromJson(Map<String, dynamic> json) {


    List<CommunityReplyLike> tmp2 = List();

    for(int i =0;i<(json['CommunityReplyLikes'] as List).length;i++){
      Map<String,dynamic> data = (json['CommunityReplyLikes'] as List)[i];
      CommunityReplyLike tmpReply = CommunityReplyLike.fromJson(data);
      tmp2.add(tmpReply);
    }

    List<CommunityReplyReply> tmp = List();

    for(int i =0;i<(json['CommunityReplyReplies'] as List).length;i++){
      Map<String,dynamic> data = (json['CommunityReplyReplies'] as List)[i];
      CommunityReplyReply tmpReply = CommunityReplyReply.fromJson(data);
      tmp.add(tmpReply);
    }
    return CommunityReply(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      postID: json['PostID'] as int,
      contents: json['Contents'] as String,
      createdAt: replaceUTCDatetest(json['createdAt'] as String),
      updatedAt: replaceUTCDatetest(json['updatedAt'] as String),
      communityReplyLike: tmp2,
      communityReplyReply: tmp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userID' : userID,
    'contents' : contents,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'CommunityReplyLikes' : communityReplyLike,
    'CommunityReplyReplies' : communityReplyReply
  };
}



class CommunityReplyReplyLike{
  int id;
  int userID;
  int replyReplyID;
  String createdAt;
  String updatedAt;

  CommunityReplyReplyLike({this.id, this.userID, this.replyReplyID, this.createdAt, this.updatedAt});

  factory  CommunityReplyReplyLike.fromJson(Map<String, dynamic> json) {
    return  CommunityReplyReplyLike(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      replyReplyID: json['ReplyReplyID'] as int,
      createdAt: replaceUTCDate(json['createdAt'] as String),
      updatedAt: replaceUTCDate(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'UserID' : userID,
    'ReplyReplyID' : replyReplyID,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}


class CommunityReplyReply{
  int id;
  int userID;
  int replyID;
  String contents;
  String createdAt;
  String updatedAt;
  List<CommunityReplyReplyLike> communityReplyReplyLike;

  CommunityReplyReply({this.id, this.userID, this.contents, this.createdAt, this.updatedAt, this.replyID, this.communityReplyReplyLike});

  factory CommunityReplyReply.fromJson(Map<String, dynamic> json) {

    List<CommunityReplyReplyLike> tmp = List();

    for(int i =0;i<(json['CommunityReplyReplyLikes'] as List).length;i++){
      Map<String,dynamic> data = (json['CommunityReplyReplyLikes'] as List)[i];
      CommunityReplyReplyLike tmpReply = CommunityReplyReplyLike.fromJson(data);
      tmp.add(tmpReply);
    }
    return CommunityReplyReply(
      id: json['id'] as int,
      userID: json['UserID'] as int,
      replyID: json['ReplyID'] as int,
      contents: json['Contents'] as String,
      createdAt: replaceUTCDatetest(json['createdAt'] as String),
      updatedAt: replaceUTCDatetest(json['updatedAt'] as String),
      communityReplyReplyLike: tmp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userID' : userID,
    'contents' : contents,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
    'CommunityReplyReplyLikes' : communityReplyReplyLike,
  };
}


//프로필 수정에서 인증 중, 반려, 인증 완료를 나누기 위한 status
enum IdentifiedType {Reject, Complete, Proceed}

bool insertCheckForFilterAfterSelect(int userID, int index) {
  bool check = false;
  for (int i = 0;
  i <  GlobalProfile. filteredCommunityList[index].communityLike.length;
  i++) {
    if (GlobalProfile. filteredCommunityList[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}
bool searchWordInsertCheck(int userID, int index){
  bool check = false;
  for(int i= 0; i<GlobalProfile.searchWord[index].communityLike.length;i++){
    if(GlobalProfile.searchWord[index].communityLike[i].userID == userID){
      check = true;
      break;
    }
  }
  return check;
}
bool popularCommunityInsertCheck(int userID, int index) {
  bool check = false;
  for (int i = 0;
  i < GlobalProfile.popularCommunityList[index].communityLike.length;
  i++) {
    if (GlobalProfile.popularCommunityList[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}
bool popularCommunityByJobInsertCheck(int userID, int index) {
  bool check = false;
  for (int i = 0;
  i < GlobalProfile.popularCommunityListByJob[index].communityLike.length;
  i++) {
    if (GlobalProfile.popularCommunityListByJob[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}
bool newCommunityInsertCheck(int userID, int index) {
  bool check = false;
  for (int i = 0;
  i < GlobalProfile.newCommunityList[index].communityLike.length;
  i++) {
    if (GlobalProfile.newCommunityList[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}
bool newCommunityByJobInsertCheck(int userID, int index) {
  bool check = false;
  for (int i = 0;
  i < GlobalProfile.newCommunityListByJob[index].communityLike.length;
  i++) {
    if (GlobalProfile.newCommunityListByJob[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}
bool searchWordCheck(int userID, int index) {
  bool check = false;
  for (int i = 0;
  i < GlobalProfile.searchWord[index].communityLike.length;
  i++) {
    if (GlobalProfile.searchWord[index].communityLike[i].userID == userID) {
      check = true;
      break;
    }
  }
  return check;
}

bool insertReplyCheck(int userID, int index) {
  bool check = false;
  for (int i = 0;
  i < GlobalProfile.communityReply[index].communityReplyLike.length;
  i++) {
    if (GlobalProfile.communityReply[index].communityReplyLike[i].userID ==
        userID) {
      check = true;
      break;
    }
  }
  return check;
}

bool insertReplyReplyCheck(int userID, int index, int index2) {
  bool check = false;
  for (int i = 0;
  i <
      GlobalProfile.communityReply[index].communityReplyReply[index2]
          .communityReplyReplyLike.length;
  i++) {
    if (GlobalProfile.communityReply[index].communityReplyReply[index2]
        .communityReplyReplyLike[i].userID ==
        userID) {
      check = true;
      break;
    }
  }
  return check;
}