class ModelPersonalLikes {
  int id;
  int UserId;
  int TargetID;
  String createdAt;
  String updatedAt;

  ModelPersonalLikes({this.updatedAt,this.id,this.createdAt,this.TargetID,this.UserId});

  factory ModelPersonalLikes.fromJson(Map<String, dynamic> json){
    return ModelPersonalLikes(
      id: json['id'] as int,
      UserId: json['UserId'] as int,
      TargetID: json['TargetID'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}