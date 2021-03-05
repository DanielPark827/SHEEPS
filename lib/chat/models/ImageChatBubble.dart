import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class ImageChatBubble extends StatelessWidget {
  final bool isMe;
  final bool isContinue;
  final ChatRecvMessageModel message;

  ImageChatBubble({@required this.isMe, @required this.isContinue, @required this.message});

  double sizeUnit = 1;

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        isMe ? _bubbleEndWidget(context) : Container(),  //작성자에 따른 시간 표시
        Container(
          padding: EdgeInsets.all(8*sizeUnit),
          margin: EdgeInsets.symmetric(horizontal: 4*sizeUnit),
          width: 120*sizeUnit,
          height: 120*sizeUnit,
          decoration: BoxDecoration(
              color: hexToColor("#EEEEEE"),
              borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
              image: DecorationImage(
                  //image: MemoryImage(base64Decode(message.message)),
                  image: FileImage(File(message.fileMessage)),
                  fit: BoxFit.cover
              )
          ),
        ),
        !isMe ? _bubbleEndWidget(context) : Container(), //작성자에 따른 시간 표시
      ],
    );
  }

  Widget _bubbleEndWidget(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return Column(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        message.isContinue ? Text(
          setDateAmPm(message.date, false, null),
          style: SheepsTextStyle.b4(context).copyWith(fontSize: 8*sizeUnit),
        ) : Container(),
      ],
    );
  }
}
