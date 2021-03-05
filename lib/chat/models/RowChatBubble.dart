import 'package:flutter/material.dart';
import '../models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class RowChatBubble extends StatelessWidget {
  final bool isMe;
  final bool isContinue;
  final ChatRecvMessageModel message;

  RowChatBubble({@required this.isMe, @required this.isContinue, @required this.message});

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    Color boxColor = isMe ? hexToColor('#EEEEEE') : hexToColor('#FFFFFF');
    TextStyle textStyle = SheepsTextStyle.b3(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        isMe ? _bubbleEndWidget(context, isMe) : Container(),  //작성자에 따른 시간 표시
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: hexToColor('#EEEEEE')),
            color:  boxColor,
            borderRadius: BorderRadius.circular(8*sizeUnit),
          ),
          constraints: BoxConstraints(
              maxWidth: 240*sizeUnit,
          ),
          child: Padding(
            padding: EdgeInsets.all(8*sizeUnit),
            child: Text(
              message.message,
              style: textStyle,
            ),
          ),
        ),
        !isMe ? _bubbleEndWidget(context, isMe) : Container(), //작성자에 따른 시간 표시
      ],
    );
  }

  Widget _bubbleEndWidget(BuildContext context, bool isMe) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    String date = isMe ? setDateAmPm(message.date, false, null) + ' ' : ' ' + setDateAmPm(message.date, false, null);
    return Column(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        message.isContinue ? Text(
          date,
          style: SheepsTextStyle.b4(context).copyWith(fontSize: 8*sizeUnit),
        ) : Container(),
      ],
    );
  }
}
