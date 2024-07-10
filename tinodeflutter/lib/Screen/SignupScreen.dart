import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tinodeflutter/Screen/messageRoomListScreen.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/tinode/src/models/account-params.dart';
import 'package:tinodeflutter/tinode/src/models/credential.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      // 여기서 회원가입 로직을 추가하세요.
      print('ID: ${_idController.text}');
      print('PW: ${_pwController.text}');
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      
      Credential credential = Credential(meth: 'email', val: _emailController.text);
      AccountParams accountParams = AccountParams(cred: [credential] , public:{'fn':_nameController.text} );
      try{
       var result = await tinode_global.createAccountBasic(_idController.text, _pwController.text, true, accountParams);
       print("ddd");
       token = result.params['token'];
       url_encoded_token = Uri.encodeComponent(result.params['token']);
       tinode_global.setDeviceToken(gPushKey); //fcm push token 던지기
       Get.offAll(MessageRoomListScreen(
        tinode: tinode_global,
      ));
      }
      catch(err)
      {
        showToast('회원가입 실패 $err');
      }
      
      // if(result.code >=400 && result.code<500)
      //   showToast("회원가입 실패 ${result.text}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입이 완료되었습니다.')),
      );
    }else{
      showToast('validate fail');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID를 입력하세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pwController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력하세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력하세요.';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return '유효한 이메일 주소를 입력하세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}