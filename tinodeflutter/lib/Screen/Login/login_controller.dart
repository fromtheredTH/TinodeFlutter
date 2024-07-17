import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Trans;

class LoginController extends GetxController{

  TextEditingController emailController=TextEditingController();

  TextEditingController passwordController=TextEditingController();

  RxString emailValidationText="".obs;


}