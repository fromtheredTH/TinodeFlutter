class UserModel {
   String id;
   String name;
   String? email;
   String searchId;
   String picture;
   bool isFreind=false;
   dynamic? membership;
   bool selected=false;
    dynamic? tags;
  UserModel({required this.id, required this.name, required this.picture, required this.isFreind , this.membership, this.searchId="", this.tags, this.selected=false});


   UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? -1,
        // uid = json['uid'] ?? "",
        name = json['public']['fn'] ?? "",
       // nickname = json['nickname'] ?? "",
        // channelId = json['channel_id'] ?? "",
        email = json['email'] ?? "",
        picture = json['public']['photo']['ref'] ?? "",
        searchId = json['public']['photo']['ref'] ?? "";
        //isFreind = json['picture'] ?? json["profile_img"] ?? "";
        // urlBanner = json['url_banner'] ?? "",
        // isDeveloper = json['is_developer'] != null ? json['is_developer'] is int ? json['is_developer'] == 1 ? true : false : json['is_developer'] : false,
        // idVerified = json['id_verified'] ?? false,
        // followYou = json['follow_you'] ?? false,
        // isFollowing = json['is_following'] ?? false,
        // blockYou = json['block_you'] != null ? json['block_you'] is int ? json['block_you'] == 1 ? true : false : json['block_you'] : false,
        // isBlocked = json['is_blocked'] ?? false,
        // mutesYou = json['mutes_you'] != null ? json['mutes_you'] is int ? json['mutes_you'] == 1 ? true : false : json['mutes_you'] : false,
        // isMuted = json['is_muted'] ?? false,
        // followingCnt = json['following_cnt'] ?? 0,
        // followerCnt = json['follower_cnt'] ?? 0,
        // meta = UserMeta.fromJson(json['meta'] ?? {}),
        // profile = ProfileModel.fromJson(json['profile'] ?? {}),
        // setting = SettingModel.fromJson(json['setting'] ?? {}),
        // coin = CoinModel.fromJson(json['coin'] ?? {}),
        // verifiedInfo = VerifiedInfoModel.fromJson(json["verified_info"] ?? {}),
        // games = json['games'] != null ? json["games"].map((gameJson) => GameModel.fromJson(gameJson)).toList().cast<GameModel>() : [],
        // emailVerified = json['email_verified'] ?? false;

  Map<String,dynamic> toJson() {
    return {
      'id': id,
      // 'uid': uid,
      'name': name,
      // 'channel_id': channelId,
      'email': email,
      'picture': picture,
      'searchId': searchId,
      // 'url_banner': urlBanner,
      // 'is_developer': isDeveloper == 1,
      // 'id_verified': idVerified,
      // 'following_cnt': followingCnt,
      // 'follower_cnt': followerCnt,
      // 'meta': meta.toJson(),
      // 'profile': profile.toJson(),
      // 'setting': setting.toJson(),
      // 'coin': coin.toJson(),
      // 'games': games.map((game) => game.toJson()).toList(),
      // 'email_verified': emailVerified,
    };
  }
}