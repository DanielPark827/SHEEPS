import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sheeps_app/chat/models/ImageChatBubble.dart';
import 'package:sheeps_app/profile/DetailProfile.dart';
import '../models/ChatRecvMessageModel.dart';
import '../models/ChatGlobal.dart';
import '../models/RowChatBubble.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:sheeps_app/userdata/User.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';

class ChatItem extends StatelessWidget {
  final ChatRecvMessageModel message;
  final bool isContinue;
  final bool isImage;
  final String chatIconName;

  const ChatItem({Key key, @required this.message, @required this.isContinue, @required this.isImage, @required this.chatIconName}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    double sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    bool isMe;
    UserData chatUser;
    MainAxisAlignment mainAxisAlignment;

    if(this.message.from == CENTER_MESSAGE){
      isMe = true;
      chatUser = GlobalProfile.loggedInUser;
      mainAxisAlignment = MainAxisAlignment.center;
    }else{
      isMe = this.message.from == GlobalProfile.loggedInUser.userID;
      chatUser = isMe ? GlobalProfile.loggedInUser : GlobalProfile.getUserByUserID(this.message.from);
      mainAxisAlignment = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    }

    String name = chatUser.name;

    bool bMajor = chatUser.part == null || chatUser.part == '';
    bool bLocation =chatUser.location == null || chatUser.location == '';

    if(!bMajor && !bLocation){
      name = name + ' ( ' + chatUser.part + ' / ' + chatUser.location + ' )';
    }else if(!bMajor && bLocation){
      name = name + ' ( ' + chatUser.part + ' )';
    }else if(bMajor && !bLocation){
      name = name + ' ( ' + chatUser.location + ' )';
    }

    if(message.isContinue == null) message.isContinue = true;

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMe
            ? Container()
            : isContinue
              ? Container(padding: EdgeInsets.symmetric(horizontal: 24*sizeUnit))
              : chatIconName == 'BasicImage'
                ? Container(
                    width: 40*sizeUnit,
                    height: 40*sizeUnit,
                    decoration: BoxDecoration(
                      color: hexToColor('#F8F8F8'),
                      borderRadius: new BorderRadius.circular(8*sizeUnit),
                      boxShadow: [
                        new BoxShadow(
                          color: Color.fromRGBO(116, 125, 130, 0.2),
                          blurRadius: 4*sizeUnit,
                          offset: Offset(1*sizeUnit, 1*sizeUnit)
                        ),
                      ],
                    ),
                    child:  GestureDetector(
                      onTap: () {
                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: DetailProfile(index: 0,user: chatUser)));
                      },
                        child:
                        Center(
                            child: SvgPicture.asset(
                              svgPersonalProfileBasicImage,
                              width:87*sizeUnit,
                              height: 63*sizeUnit,
                            )
                        )
                    )
                )
                : Container(
                    width: 40*sizeUnit,
                    height: 40*sizeUnit,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: DetailProfile(index: 0,user: chatUser)));
                      },
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(8*sizeUnit),
                        child: FittedBox(
                          child: ExtendedImage.network(getOptimizeImageURL(chatIconName, 160)),
                          fit: BoxFit.cover,),
                      ),
                    ),
                ),
        (false == isContinue) && (false == isMe)
            ? Padding(
              padding: EdgeInsets.only(left: 8*sizeUnit),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget> [
                    Container(
                      child: Text(
                          name,
                          style: SheepsTextStyle.s3(context).copyWith(fontSize: 8*sizeUnit),
                      ),
                    ),
                    SizedBox(height: 4*sizeUnit),
                    this.message.isImage == 0
                    ? RowChatBubble(
                      isMe: isMe,
                      isContinue: isContinue,
                      message: this.message,
                    )
                    : ImageChatBubble(
                      isMe: isMe,
                      isContinue: isContinue,
                      message: this.message,
                    ),
                  ],
              ),
            )
            : this.message.isImage == 0
              ? RowChatBubble(
                isMe: isMe,
                isContinue: isContinue,
                message: this.message,
              )
              : ImageChatBubble(
                isMe: isMe,
                isContinue: isContinue,
                message: this.message,
              ),
      ],
    );
  }
}
