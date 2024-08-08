class UnreadModel {
   String userId;
   int readId;
   int recvId;
   int unreadCount;

  UnreadModel({required this.userId, required this.unreadCount, required this.recvId, required this.readId, });


   UnreadModel.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] ?? -1,
      readId= json['read'],
      recvId= json['recv'],
        unreadCount = json['unreadCount'];
      
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
      'userId': userId,
      // 'uid': uid,
    
    };
  }
}