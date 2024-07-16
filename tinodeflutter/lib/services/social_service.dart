
// https://dalgoodori.tistory.com/tag/%EC%86%8C%EC%85%9C%20%EB%A1%9C%EA%B7%B8%EC%9D%B8
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tinodeflutter/model/UserAuthModel.dart'  as model;



class SocialService {

  Future<model.UserSocialInfo?> getProfile(
      model.AuthProvider authProvider) async {
    await FirebaseAuth.instance.signOut();
    switch (authProvider) {
      case model.AuthProvider.google:
        try {
          await GoogleSignIn().signOut(); // 여러 구글계정이 있을 경우를 대비
          // ignore: empty_catches
        } catch (err) {}

        try {
          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
          final GoogleSignInAuthentication googleSignInAuthentication = await googleUser!
              .authentication;
          if (googleUser == null) {
            throw '구글 로그인 오류';
          }
          final credential = GoogleAuthProvider.credential(
              accessToken: googleSignInAuthentication?.accessToken,
              idToken: googleSignInAuthentication?.idToken);

          final data = await FirebaseAuth.instance.signInWithCredential(
              credential);

          final socialInfo = model.UserSocialInfo();
          final googleLoginUser = data.user;
          if (googleLoginUser == null) throw '구글 로그인 실패';

          socialInfo.authProvider = authProvider;
          socialInfo.id = googleUser.id;
          socialInfo.uid = googleUser.displayName;
          socialInfo.profileImage = googleUser.photoUrl;
          socialInfo.email = googleUser.email;
          socialInfo.accessToken = googleSignInAuthentication.accessToken;
          socialInfo.refreshToken = googleSignInAuthentication?.idToken;
          return socialInfo;
        }catch(e){
          return null;
        }

      case model.AuthProvider.apple:
        try {
          final appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );
          print("apple login get email , full name");

          final oauthCredential = OAuthProvider("apple.com").credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode,
          );
          print("apple login oauthCredential    idToken accessToken");

          final data = await FirebaseAuth.instance.signInWithCredential(
              oauthCredential);
          print("sign with credential ");
          final appleUser = data.user;
          if (appleUser == null) {
            print("sign with appleUser null ");
            throw '애플 로그인 실패';}

          final socialInfo = model.UserSocialInfo();
          print("sign with apple UserSocialInfo ");

          socialInfo.authProvider = authProvider;
          socialInfo.id = appleUser.uid;
          socialInfo.uid = appleUser.displayName;
          socialInfo.name = "${appleCredential.givenName}${(appleCredential.familyName ?? "")}";
          socialInfo.profileImage = appleUser.photoURL;
          socialInfo.email = appleUser.providerData.isNotEmpty ? appleUser.providerData.first.email : appleUser.email;
          socialInfo.accessToken = appleCredential.identityToken;
          socialInfo.refreshToken = appleCredential.authorizationCode;
                    print("sign with apple final ");

          return socialInfo;
        }catch (e) {
          print("apple login fail");
          return null;
        }
      case model.AuthProvider.facebook:

        try{
          final LoginResult result = await FacebookAuth.instance.login();
          final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken?.token ?? "");

          final data = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
          final facebookUser = data.user;
          if(facebookUser == null) throw '페이스북 로그인 실패';

          final socialInfo = model.UserSocialInfo();

          socialInfo.authProvider = authProvider;
          socialInfo.id = facebookUser.uid;
          socialInfo.uid = facebookUser.displayName;
          socialInfo.profileImage = facebookUser.photoURL;
          socialInfo.email = facebookUser.email;
          socialInfo.accessToken = result.accessToken?.token ?? "";
          socialInfo.refreshToken = facebookUser?.refreshToken ?? "";

          return socialInfo;
        }catch (e) {
          return null;
        }
      case model.AuthProvider.email:
        break;
      default :
        break;
    }
    return null;
  }
}
