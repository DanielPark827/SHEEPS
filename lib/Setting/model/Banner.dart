

import 'package:flutter/services.dart';
import 'package:sheeps_app/network/ApiProvider.dart';

//서버 통신용
class WebBanner {
  int id;
  String title;
  String description;
  String webURL;
  String imgURL;
  int index;
  String createdAt;
  String updatedAt;

  WebBanner({this.id, this.title, this.description, this.webURL, this.imgURL, this.index, this.createdAt, this.updatedAt});

  factory WebBanner.fromJson(Map<String, dynamic> json){
    return WebBanner(
      id : json['id'] as int,
      title: json['Title'],
      description: json['Description'],
      webURL: json['WebURL'],
      imgURL: ApiProvider().getUrl + '/BannerPhotos/' + json['ImgURL'],
      index: json['Index'] as int,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt']
    );
  }
}

List<WebBanner> globalWebBannerList = new List<WebBanner>();

Future<void> setWebBannerData() async {
  var res = await ApiProvider().get('/Banner/List');

  for(int i = 0 ; i < res.length; ++i){
    globalWebBannerList.add(WebBanner.fromJson(res[i]));
  }
}

//클라이언트 용
class ClientBanner {
  String imgURL;
  String webURL;

  ClientBanner({this.imgURL, this.webURL});
}

List<ClientBanner> globalClientBannerList = new List<ClientBanner>();

Future<void> setClientBannerData() async {

  //파일로부터 데이터를 가져옴
  String txtData = await loadAsset('assets/txt/bannerFile.txt');

  List<String> enter = txtData.split('\n');

  for(int i = 0 ; i < enter.length; ++i){
    List<String> split = enter[i].split('|');

    if(split.length != 2) continue;

    globalClientBannerList.add(ClientBanner(imgURL: 'assets/images/DashBoard/' + split[0], webURL: split[1]));
  }
}

Future<String> loadAsset(String path) async{
  return rootBundle.loadString(path);
}