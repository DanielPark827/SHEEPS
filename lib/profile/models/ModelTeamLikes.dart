class ModelTeamLikes {
  int id;
  int UserId;
  int TeamID;
  String createdAt;
  String updatedAt;

  ModelTeamLikes({this.updatedAt,this.id,this.createdAt,this.TeamID,this.UserId});

  factory ModelTeamLikes.fromJson(Map<String, dynamic> json){
    return ModelTeamLikes(
      id: json['id'] as int,
      UserId: json['UserId'] as int,
      TeamID: json['TeamID'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}