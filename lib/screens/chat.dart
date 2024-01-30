import 'package:chat/widgets/chat_messages.dart';
import 'package:chat/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB( 150, 100, 100, 150),
        title: const Text('FlutterChat'),
        actions: [
          IconButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
              },
              icon:const Icon(Icons.exit_to_app , )),
        ],
      ),
      body:const Column(
        children: [
          Expanded(
              child: ChatMessages()),
          NewMessages(),
        ],
      ),
    );
  }
}
