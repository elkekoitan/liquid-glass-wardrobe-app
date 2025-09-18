import 'package:firebase_auth/firebase_auth.dart';

/// Comprehensive User Model for Fashion AI App
/// Includes user profile, preferences, and social data
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastSignIn;
  final bool isEmailVerified;
  
  // Extended Profile Data
  final UserProfile? profile;
  final UserPreferences? preferences;
  final UserSocialData? socialData;
  final UserSubscription? subscription;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.createdAt,
    this.lastSignIn,
    required this.isEmailVerified,
    this.profile,
    this.preferences,
    this.socialData,
    this.subscription,
  });

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignIn: firebaseUser.metadata.lastSignInTime,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastSignIn: map['lastSignIn'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSignIn'])
          : null,
      isEmailVerified: map['isEmailVerified'] ?? false,
      profile: map['profile'] != null
          ? UserProfile.fromMap(map['profile'])
          : null,
      preferences: map['preferences'] != null
          ? UserPreferences.fromMap(map['preferences'])
          : null,
      socialData: map['socialData'] != null
          ? UserSocialData.fromMap(map['socialData'])
          : null,
      subscription: map['subscription'] != null
          ? UserSubscription.fromMap(map['subscription'])
          : null,
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSignIn': lastSignIn?.millisecondsSinceEpoch,
      'isEmailVerified': isEmailVerified,
      'profile': profile?.toMap(),
      'preferences': preferences?.toMap(),
      'socialData': socialData?.toMap(),
      'subscription': subscription?.toMap(),
    };
  }

  /// Copy with modifications
  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? lastSignIn,
    bool? isEmailVerified,
    UserProfile? profile,
    UserPreferences? preferences,
    UserSocialData? socialData,
    UserSubscription? subscription,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      socialData: socialData ?? this.socialData,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
}

/// User Profile - Extended user information
class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? avatar;
  final DateTime? birthDate;
  final String? gender;
  final String? location;
  final String? occupation;
  final List<String>? interests;
  final String? website;
  final Map<String, String>? socialLinks;
  
  // Fashion-specific data
  final UserMeasurements? measurements;
  final List<String>? preferredBrands;
  final List<String>? stylePreferences;
  final String? skinTone;
  final String? bodyType;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.bio,
    this.avatar,
    this.birthDate,
    this.gender,
    this.location,
    this.occupation,
    this.interests,
    this.website,
    this.socialLinks,
    this.measurements,
    this.preferredBrands,
    this.stylePreferences,
    this.skinTone,
    this.bodyType,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['firstName'],
      lastName: map['lastName'],
      bio: map['bio'],
      avatar: map['avatar'],
      birthDate: map['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birthDate'])
          : null,
      gender: map['gender'],
      location: map['location'],
      occupation: map['occupation'],
      interests: map['interests'] != null
          ? List<String>.from(map['interests'])
          : null,
      website: map['website'],
      socialLinks: map['socialLinks'] != null
          ? Map<String, String>.from(map['socialLinks'])
          : null,
      measurements: map['measurements'] != null
          ? UserMeasurements.fromMap(map['measurements'])
          : null,
      preferredBrands: map['preferredBrands'] != null
          ? List<String>.from(map['preferredBrands'])
          : null,
      stylePreferences: map['stylePreferences'] != null
          ? List<String>.from(map['stylePreferences'])
          : null,
      skinTone: map['skinTone'],
      bodyType: map['bodyType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'avatar': avatar,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'gender': gender,
      'location': location,
      'occupation': occupation,
      'interests': interests,
      'website': website,
      'socialLinks': socialLinks,
      'measurements': measurements?.toMap(),
      'preferredBrands': preferredBrands,
      'stylePreferences': stylePreferences,
      'skinTone': skinTone,
      'bodyType': bodyType,
    };
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? bio,
    String? avatar,
    DateTime? birthDate,
    String? gender,
    String? location,
    String? occupation,
    List<String>? interests,
    String? website,
    Map<String, String>? socialLinks,
    UserMeasurements? measurements,
    List<String>? preferredBrands,
    List<String>? stylePreferences,
    String? skinTone,
    String? bodyType,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      interests: interests ?? this.interests,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
      measurements: measurements ?? this.measurements,
      preferredBrands: preferredBrands ?? this.preferredBrands,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      skinTone: skinTone ?? this.skinTone,
      bodyType: bodyType ?? this.bodyType,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? '';
  }
}

/// User measurements for accurate fitting
class UserMeasurements {
  final double? height; // in cm
  final double? weight; // in kg
  final double? chest; // in cm
  final double? waist; // in cm
  final double? hips; // in cm
  final double? inseam; // in cm
  final String? shirtSize;
  final String? pantsSize;
  final String? shoeSize;

  const UserMeasurements({
    this.height,
    this.weight,
    this.chest,
    this.waist,
    this.hips,
    this.inseam,
    this.shirtSize,
    this.pantsSize,
    this.shoeSize,
  });

  factory UserMeasurements.fromMap(Map<String, dynamic> map) {
    return UserMeasurements(
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      chest: map['chest']?.toDouble(),
      waist: map['waist']?.toDouble(),
      hips: map['hips']?.toDouble(),
      inseam: map['inseam']?.toDouble(),
      shirtSize: map['shirtSize'],
      pantsSize: map['pantsSize'],
      shoeSize: map['shoeSize'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'inseam': inseam,
      'shirtSize': shirtSize,
      'pantsSize': pantsSize,
      'shoeSize': shoeSize,
    };
  }
}

/// User preferences for app experience
class UserPreferences {
  final bool isDarkMode;
  final String? language;
  final String? currency;
  final bool enableNotifications;
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableSocialSharing;
  final bool isProfilePublic;
  final List<String>? interestedCategories;
  final double? priceRangeMin;
  final double? priceRangeMax;

  const UserPreferences({
    this.isDarkMode = false,
    this.language,
    this.currency,
    this.enableNotifications = true,
    this.enablePushNotifications = true,
    this.enableEmailNotifications = true,
    this.enableSocialSharing = true,
    this.isProfilePublic = false,
    this.interestedCategories,
    this.priceRangeMin,
    this.priceRangeMax,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      isDarkMode: map['isDarkMode'] ?? false,
      language: map['language'],
      currency: map['currency'],
      enableNotifications: map['enableNotifications'] ?? true,
      enablePushNotifications: map['enablePushNotifications'] ?? true,
      enableEmailNotifications: map['enableEmailNotifications'] ?? true,
      enableSocialSharing: map['enableSocialSharing'] ?? true,
      isProfilePublic: map['isProfilePublic'] ?? false,
      interestedCategories: map['interestedCategories'] != null
          ? List<String>.from(map['interestedCategories'])
          : null,
      priceRangeMin: map['priceRangeMin']?.toDouble(),
      priceRangeMax: map['priceRangeMax']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'currency': currency,
      'enableNotifications': enableNotifications,
      'enablePushNotifications': enablePushNotifications,
      'enableEmailNotifications': enableEmailNotifications,
      'enableSocialSharing': enableSocialSharing,
      'isProfilePublic': isProfilePublic,
      'interestedCategories': interestedCategories,
      'priceRangeMin': priceRangeMin,
      'priceRangeMax': priceRangeMax,
    };
  }
}

/// User social data and statistics
class UserSocialData {
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int likesReceived;
  final List<String>? recentFollowers;
  final DateTime? lastActivity;

  const UserSocialData({
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.likesReceived = 0,
    this.recentFollowers,
    this.lastActivity,
  });

  factory UserSocialData.fromMap(Map<String, dynamic> map) {
    return UserSocialData(
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      likesReceived: map['likesReceived'] ?? 0,
      recentFollowers: map['recentFollowers'] != null
          ? List<String>.from(map['recentFollowers'])
          : null,
      lastActivity: map['lastActivity'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastActivity'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'likesReceived': likesReceived,
      'recentFollowers': recentFollowers,
      'lastActivity': lastActivity?.millisecondsSinceEpoch,
    };
  }
}

/// User subscription information
class UserSubscription {
  final String? planId;
  final String? planName;
  final double? monthlyPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isTrialPeriod;
  final List<String>? features;

  const UserSubscription({
    this.planId,
    this.planName,
    this.monthlyPrice,
    this.startDate,
    this.endDate,
    this.isActive = false,
    this.isTrialPeriod = false,
    this.features,
  });

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      planId: map['planId'],
      planName: map['planName'],
      monthlyPrice: map['monthlyPrice']?.toDouble(),
      startDate: map['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startDate'])
          : null,
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      isActive: map['isActive'] ?? false,
      isTrialPeriod: map['isTrialPeriod'] ?? false,
      features: map['features'] != null
          ? List<String>.from(map['features'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'planName': planName,
      'monthlyPrice': monthlyPrice,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'isActive': isActive,
      'isTrialPeriod': isTrialPeriod,
      'features': features,
    };
  }

  bool get hasActiveSubscription {
    return isActive && (endDate == null || endDate!.isAfter(DateTime.now()));
  }
}