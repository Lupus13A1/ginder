import 'package:flutter/material.dart';

/// Item representing an active interest for display as tags/chips
class InterestDisplayItem {
  final String key;
  final String label;
  final String value;
  final IconData icon;

  const InterestDisplayItem({
    required this.key,
    required this.label,
    required this.value,
    required this.icon,
  });
}

/// Category metadata definition for the 14 Tinder-style interests
class InterestCategoryDefinition {
  final String key;
  final String label;
  final IconData icon;
  final bool isMultiSelect;
  final List<String> options;

  const InterestCategoryDefinition({
    required this.key,
    required this.label,
    required this.icon,
    this.isMultiSelect = false,
    required this.options,
  });
}

/// Structured interests and lifestyle data model inspired by Tinder UX
class ProfileInterests {
  final String? datingFor;
  final String? lookingFor;
  final List<String> languages;
  final String? zodiac;
  final String? education;
  final String? familyPlans;
  final String? communicationStyle;
  final String? loveStyle;
  final String? bloodType;
  final String? pets;
  final String? drinking;
  final String? smoking;
  final String? workout;
  final String? socialMedia;

  const ProfileInterests({
    this.datingFor,
    this.lookingFor,
    this.languages = const [],
    this.zodiac,
    this.education,
    this.familyPlans,
    this.communicationStyle,
    this.loveStyle,
    this.bloodType,
    this.pets,
    this.drinking,
    this.smoking,
    this.workout,
    this.socialMedia,
  });

  bool get isEmpty =>
      (datingFor == null || datingFor!.isEmpty) &&
      (lookingFor == null || lookingFor!.isEmpty) &&
      languages.isEmpty &&
      (zodiac == null || zodiac!.isEmpty) &&
      (education == null || education!.isEmpty) &&
      (familyPlans == null || familyPlans!.isEmpty) &&
      (communicationStyle == null || communicationStyle!.isEmpty) &&
      (loveStyle == null || loveStyle!.isEmpty) &&
      (bloodType == null || bloodType!.isEmpty) &&
      (pets == null || pets!.isEmpty) &&
      (drinking == null || drinking!.isEmpty) &&
      (smoking == null || smoking!.isEmpty) &&
      (workout == null || workout!.isEmpty) &&
      (socialMedia == null || socialMedia!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  /// Returns active interests for rendering badges/chips on Profile and Swipe Cards
  List<InterestDisplayItem> get displayItems {
    final list = <InterestDisplayItem>[];

    if (datingFor != null && datingFor!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'datingFor',
          label: 'Dating For',
          value: datingFor!,
          icon: Icons.favorite_outline,
        ),
      );
    }
    if (lookingFor != null && lookingFor!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'lookingFor',
          label: 'Looking For',
          value: lookingFor!,
          icon: Icons.search,
        ),
      );
    }
    if (languages.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'languages',
          label: 'Languages',
          value: languages.join(', '),
          icon: Icons.translate,
        ),
      );
    }
    if (zodiac != null && zodiac!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'zodiac',
          label: 'Zodiac',
          value: zodiac!,
          icon: Icons.nights_stay_outlined,
        ),
      );
    }
    if (education != null && education!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'education',
          label: 'Education',
          value: education!,
          icon: Icons.school_outlined,
        ),
      );
    }
    if (workout != null && workout!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'workout',
          label: 'Workout',
          value: workout!,
          icon: Icons.fitness_center_outlined,
        ),
      );
    }
    if (communicationStyle != null && communicationStyle!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'communicationStyle',
          label: 'Communication',
          value: communicationStyle!,
          icon: Icons.chat_bubble_outline,
        ),
      );
    }
    if (loveStyle != null && loveStyle!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'loveStyle',
          label: 'Love Style',
          value: loveStyle!,
          icon: Icons.favorite_border,
        ),
      );
    }
    if (pets != null && pets!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'pets',
          label: 'Pets',
          value: pets!,
          icon: Icons.pets_outlined,
        ),
      );
    }
    if (drinking != null && drinking!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'drinking',
          label: 'Drinking',
          value: drinking!,
          icon: Icons.local_bar_outlined,
        ),
      );
    }
    if (smoking != null && smoking!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'smoking',
          label: 'Smoking',
          value: smoking!,
          icon: Icons.smoking_rooms_outlined,
        ),
      );
    }
    if (familyPlans != null && familyPlans!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'familyPlans',
          label: 'Family Plans',
          value: familyPlans!,
          icon: Icons.child_friendly_outlined,
        ),
      );
    }
    if (bloodType != null && bloodType!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'bloodType',
          label: 'Blood Type',
          value: bloodType!,
          icon: Icons.water_drop_outlined,
        ),
      );
    }
    if (socialMedia != null && socialMedia!.isNotEmpty) {
      list.add(
        InterestDisplayItem(
          key: 'socialMedia',
          label: 'Social Media',
          value: socialMedia!,
          icon: Icons.alternate_email,
        ),
      );
    }

    return list;
  }

  ProfileInterests copyWith({
    String? datingFor,
    String? lookingFor,
    List<String>? languages,
    String? zodiac,
    String? education,
    String? familyPlans,
    String? communicationStyle,
    String? loveStyle,
    String? bloodType,
    String? pets,
    String? drinking,
    String? smoking,
    String? workout,
    String? socialMedia,
    bool clearDatingFor = false,
    bool clearLookingFor = false,
    bool clearZodiac = false,
    bool clearEducation = false,
    bool clearFamilyPlans = false,
    bool clearCommunicationStyle = false,
    bool clearLoveStyle = false,
    bool clearBloodType = false,
    bool clearPets = false,
    bool clearDrinking = false,
    bool clearSmoking = false,
    bool clearWorkout = false,
    bool clearSocialMedia = false,
  }) {
    return ProfileInterests(
      datingFor: clearDatingFor ? null : (datingFor ?? this.datingFor),
      lookingFor: clearLookingFor ? null : (lookingFor ?? this.lookingFor),
      languages: languages ?? this.languages,
      zodiac: clearZodiac ? null : (zodiac ?? this.zodiac),
      education: clearEducation ? null : (education ?? this.education),
      familyPlans: clearFamilyPlans ? null : (familyPlans ?? this.familyPlans),
      communicationStyle: clearCommunicationStyle
          ? null
          : (communicationStyle ?? this.communicationStyle),
      loveStyle: clearLoveStyle ? null : (loveStyle ?? this.loveStyle),
      bloodType: clearBloodType ? null : (bloodType ?? this.bloodType),
      pets: clearPets ? null : (pets ?? this.pets),
      drinking: clearDrinking ? null : (drinking ?? this.drinking),
      smoking: clearSmoking ? null : (smoking ?? this.smoking),
      workout: clearWorkout ? null : (workout ?? this.workout),
      socialMedia: clearSocialMedia ? null : (socialMedia ?? this.socialMedia),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'datingFor': datingFor,
      'lookingFor': lookingFor,
      'languages': languages,
      'zodiac': zodiac,
      'education': education,
      'familyPlans': familyPlans,
      'communicationStyle': communicationStyle,
      'loveStyle': loveStyle,
      'bloodType': bloodType,
      'pets': pets,
      'drinking': drinking,
      'smoking': smoking,
      'workout': workout,
      'socialMedia': socialMedia,
    };
  }

  factory ProfileInterests.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const ProfileInterests();

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ProfileInterests(
      datingFor: map['datingFor']?.toString(),
      lookingFor: map['lookingFor']?.toString(),
      languages: parseList(map['languages']),
      zodiac: map['zodiac']?.toString(),
      education: map['education']?.toString(),
      familyPlans: map['familyPlans']?.toString(),
      communicationStyle: map['communicationStyle']?.toString(),
      loveStyle: map['loveStyle']?.toString(),
      bloodType: map['bloodType']?.toString(),
      pets: map['pets']?.toString(),
      drinking: map['drinking']?.toString(),
      smoking: map['smoking']?.toString(),
      workout: map['workout']?.toString(),
      socialMedia: map['socialMedia']?.toString(),
    );
  }

  /// All 14 Category Definitions with UX options
  static const List<InterestCategoryDefinition> categories = [
    InterestCategoryDefinition(
      key: 'datingFor',
      label: 'Dating For',
      icon: Icons.favorite_outline,
      options: [
        'Long-term relationship',
        'Long-term, open to short',
        'Short-term, open to long',
        'Short-term fun',
        'New friends',
        'Still figuring it out',
      ],
    ),
    InterestCategoryDefinition(
      key: 'lookingFor',
      label: 'Looking For',
      icon: Icons.search,
      options: [
        'Women',
        'Men',
        'Everyone',
        'Study Partners',
        'Project Teammates',
      ],
    ),
    InterestCategoryDefinition(
      key: 'languages',
      label: 'Add Languages',
      icon: Icons.translate,
      isMultiSelect: true,
      options: [
        'Thai',
        'English',
        'Chinese (Mandarin)',
        'Japanese',
        'Korean',
        'German',
        'French',
        'Spanish',
        'Russian',
      ],
    ),
    InterestCategoryDefinition(
      key: 'zodiac',
      label: 'Zodiac',
      icon: Icons.nights_stay_outlined,
      options: [
        'Aries ♈',
        'Taurus ♉',
        'Gemini ♊',
        'Cancer ♋',
        'Leo ♌',
        'Virgo ♍',
        'Libra ♎',
        'Scorpio ♏',
        'Sagittarius ♐',
        'Capricorn ♑',
        'Aquarius ♒',
        'Pisces ♓',
      ],
    ),
    InterestCategoryDefinition(
      key: 'education',
      label: 'Education',
      icon: Icons.school_outlined,
      options: [
        'Undergraduate / Bachelor',
        'Master\'s Degree',
        'Doctorate / PhD',
        'Vocational / Technical',
        'High School',
      ],
    ),
    InterestCategoryDefinition(
      key: 'familyPlans',
      label: 'Family Plans',
      icon: Icons.child_friendly_outlined,
      options: [
        'Want children',
        'Don\'t want children',
        'Have children & want more',
        'Have children & don\'t want more',
        'Not sure yet',
      ],
    ),
    InterestCategoryDefinition(
      key: 'communicationStyle',
      label: 'Communication Style',
      icon: Icons.chat_bubble_outline,
      options: [
        'Big time texter',
        'Phone caller',
        'Video chatter',
        'Bad texter',
        'Better in person',
      ],
    ),
    InterestCategoryDefinition(
      key: 'loveStyle',
      label: 'Love Style',
      icon: Icons.favorite_border,
      options: [
        'Words of affirmation',
        'Quality time',
        'Receiving gifts',
        'Acts of service',
        'Physical touch',
      ],
    ),
    InterestCategoryDefinition(
      key: 'bloodType',
      label: 'Blood Type',
      icon: Icons.water_drop_outlined,
      options: ['A', 'B', 'AB', 'O'],
    ),
    InterestCategoryDefinition(
      key: 'pets',
      label: 'Pets',
      icon: Icons.pets_outlined,
      options: [
        'Dog lover 🐶',
        'Cat person 🐱',
        'Both dogs & cats 🐾',
        'Reptiles / Fish / Birds 🦜',
        'Want a pet',
        'Allergic to pets',
        'Pet-free',
      ],
    ),
    InterestCategoryDefinition(
      key: 'drinking',
      label: 'Drinking',
      icon: Icons.local_bar_outlined,
      options: [
        'Not for me',
        'Sober',
        'Special occasions only',
        'Socially on weekends',
        'Most nights',
      ],
    ),
    InterestCategoryDefinition(
      key: 'smoking',
      label: 'Smoking',
      icon: Icons.smoking_rooms_outlined,
      options: [
        'Non-smoker',
        'Social smoker',
        'Smoker when drinking',
        'Smoker',
        'Trying to quit',
      ],
    ),
    InterestCategoryDefinition(
      key: 'workout',
      label: 'Workout',
      icon: Icons.fitness_center_outlined,
      options: [
        'Everyday',
        'Often (3-4x/week)',
        'Sometimes (1-2x/week)',
        'Never / Rarely',
      ],
    ),
    InterestCategoryDefinition(
      key: 'socialMedia',
      label: 'Social Media',
      icon: Icons.alternate_email,
      options: [
        'Active on Instagram',
        'TikTok scroller',
        'Spotify playlist curator',
        'X (Twitter) active',
        'LinkedIn professional',
        'Minimal social media',
      ],
    ),
  ];
}
