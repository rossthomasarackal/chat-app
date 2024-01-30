import 'package:chat/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  void setUpPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token= await fcm.getToken();
    print('**********************************************');
    print(token);
    fcm.subscribeToTopic('Chat');
  }

  @override
  void initState() {
    super.initState();
    setUpPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser= FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Chat')
            .orderBy('Created At' , descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots){
          if(chatSnapshots.connectionState== ConnectionState.waiting){
            return  const Center(child:  CircularProgressIndicator());
          }
          if(!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty){
            return const Center(
              child: Text('NO messages...'),
            );
          }
          if(chatSnapshots.hasError){
            return const Center(
              child: Text('Something went wrong...'),
            );
          }
          final loadedMessages= chatSnapshots.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13 ,
              right: 13,
            ),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index){
                //return Text(loadedMessages[index].data()['Text']);
                final chatMessage= loadedMessages[index].data();
                final nextChatMessage= index+ 1 < loadedMessages.length
                    ? loadedMessages[index+1].data()
                    : null;

                final currentMessageUserId= chatMessage['User id'];
                final nextMessageUserId= nextChatMessage!=null
                    ? nextChatMessage['User id']
                    :null;
                final isNextUserSame= nextMessageUserId== currentMessageUserId;
                if(isNextUserSame){
                  return MessageBubble.next(
                      message: chatMessage['Text'],
                      isMe: authenticatedUser.uid==currentMessageUserId);
                }
                else{
                  return MessageBubble.first(
                      userImage: chatMessage['User Image'],
                      username: chatMessage['User Name'],
                      message: chatMessage['Text'],
                      isMe: authenticatedUser.uid==currentMessageUserId);
                }

              }
          );


        }
    );

  }
}
