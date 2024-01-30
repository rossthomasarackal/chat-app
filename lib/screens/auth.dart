import 'package:chat/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase= FirebaseAuth.instance;
class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  var _isLogin= true;
  final _formKey= GlobalKey<FormState>();
  var eEmail='';
  var eUserName='';
  var ePassword='';
  File? selectedImage;
  var _isAuth= false;

  void _submit() async {
    final isValid= _formKey.currentState!.validate();

   if(!isValid || _isLogin || selectedImage==null) {
     return;
   }
   _formKey.currentState!.save();
   try{
     setState(() {
       _isAuth= true;
     });
     if(_isLogin){
       //logic to log users in
       final userCredentials =await _firebase.signInWithEmailAndPassword(
           email: eEmail,
           password: ePassword);
       //print(userCredentials);
     }
     else {

       // add users to the firebase
       final userCredentials = await _firebase.createUserWithEmailAndPassword(
           email: eEmail,
           password: ePassword);
       //print(userCredentials);
       final storageRef = FirebaseStorage.instance
           .ref()
           .child('UserImages')
           .child('${userCredentials.user!.uid}.jpg');
       await storageRef.putFile(selectedImage!);
       final imageUrl = await storageRef.getDownloadURL();
       print(imageUrl);

       await FirebaseFirestore.instance.
       collection('Users').
       doc(userCredentials.user!.uid).
       set({
         'User Name' : eUserName,
         'Email Id' : eEmail,
         'User Image': imageUrl ,
       });

     }

   }
   on FirebaseAuthException catch(error){
     setState(() {
       _isAuth=false;
     });
     if(error.code=='email-already-in-use'){
       //...
     }
     ScaffoldMessenger.of(context).clearSnackBars();
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text(error.message??'Authentication Error Occurred')));
   }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB( 150, 100, 100, 150),
      //Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                margin:const EdgeInsets.only(
                  bottom: 20,  right: 20,
                  left: 20,  top: 30),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding:const EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        if(!_isLogin)  UserImagePicker(onPickedImage: (pickedImage){
                          selectedImage=pickedImage;
                        }),

                        TextFormField(
                          decoration:const InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value){
                            if(value==null || value.trim().isEmpty || !value.contains('@')){
                              return 'Please enter valid Email Address';
                            }
                            return null;
                          },
                          onSaved: (value){
                            eEmail=value!;
                          },
                        ),
                       if(!_isLogin)
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'User Name'),
                          enableSuggestions: false,
                          validator: (value){
                            if(value==null|| value.isEmpty || value.trim().length<3 ){
                            return 'Please enter at least 3 characters';
                            }
                            return null;
                          },
                          onSaved: (value){
                            eUserName= value!;
                          },
                        ),

                        TextFormField(
                          decoration:const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value){
                            if(value==null || value.trim().isEmpty || value.length<6){
                              return 'Password must contains atleast 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value){
                          ePassword=value!;
                          },
                        ),
                        const SizedBox(height: 10),
                        if(_isAuth)
                          const CircularProgressIndicator(),

                        if(!_isAuth)
                          ElevatedButton(
                              onPressed: _submit,
                              child: Text(_isLogin? 'Login':'Sign In')),

                        if(!_isAuth)
                          TextButton(onPressed: (){
                            setState(() {
                              _isLogin=!_isLogin;
                            });
                          }, child: Text(_isLogin?'Create an Account':'I have an  account')),

                      ],
                    ),
                  ) ,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
