import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});
  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _messageController= TextEditingController();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    print('..................................................................');
  var enteredMessage= _messageController.text;

   if(enteredMessage.trim().isEmpty){
     return;
   }

   FocusScope.of(context).unfocus();
    _messageController.clear();
   // send to firebase

   final user=  FirebaseAuth.instance.currentUser!;
   final userDetails = await FirebaseFirestore
       .instance
       .collection('Users')
       .doc(user.uid)
       .get();
   await FirebaseFirestore.instance.collection('Chat').add(
     {
       'Text': enteredMessage ,
       'Created At': Timestamp.now(),
       'User id': user.uid,
       'User Name': userDetails.data()!['User Name'] ,
       'User Image': userDetails.data()!['User Image'] ,

     }

   );

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                controller: _messageController ,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration( labelText: 'Send a message'),
              )),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
              onPressed: _submitMessage,
              icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
