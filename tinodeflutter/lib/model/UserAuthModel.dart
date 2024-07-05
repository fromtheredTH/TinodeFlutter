
enum AuthProvider {
  email,
  google,
  apple,
  facebook,
}

const Map<AuthProvider, String> kAuthProviderNames = {
  AuthProvider.email: "이메일",
  AuthProvider.google: "구글",
  AuthProvider.apple: "애플",
};

class UserSocialInfo {
  late AuthProvider authProvider;
  late String id;
  String? nickname;
  String? name;
  String? profileImage;
  String? mobile;
  String? email;
  String? accessToken;
  String? refreshToken;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (nickname != null) {
      json['nickname'] = nickname;
    }
    if (profileImage != null) {
      json['profileImage'] = profileImage;
    }

    if (email != null) {
      json['email'] = email;
    }

    return json;
  }
}