import 'profile_interests.dart';
export 'profile_interests.dart';

/// Represents an item in the dynamic profile completeness checklist
class ProfileChecklistItem {
  final String title;
  final int weightPercent;
  final bool isCompleted;
  final String sectionKey;

  const ProfileChecklistItem({
    required this.title,
    required this.weightPercent,
    required this.isCompleted,
    this.sectionKey = '',
  });
}

/// Data model representing a university student profile on Ginder
class StudentProfile {
  final String id;
  final String name;
  final String nickname;
  final int age;
  final String faculty;
  final String major;
  final String
  year; // e.g., "Year 1 (Freshman)", "Year 2 (Sophomore)", "Year 3 (Junior)", "Year 4 (Senior)", "Postgrad"
  final String studentEmail;
  final String bio;
  final List<String> photos;
  final List<String> interests; // Campus activities / passions
  final List<String> commonInterests;
  final ProfileInterests
  profileInterests; // Tinder-style lifestyle & relationship interests
  final String anthemSong;
  final String anthemArtist;
  final String favoriteMovie;
  final String campusHangout;
  final double distanceKm;
  final bool isVerifiedStudent;
  final int matchesCount;
  final int likesCount;

  /// Alias for campus activities/passions to separate clearly from profileInterests
  List<String> get activities => interests;

  /// Dynamically calculated profile completeness score (0.0 to 1.0)
  double get profileCompleteness => calculatedCompleteness;

  /// Calculates dynamic completeness based on actual profile data (0.0 to 1.0)
  double get calculatedCompleteness {
    double score = 0.0;

    // 1. Photos (20% total)
    if (photos.isNotEmpty) {
      score += 0.10; // At least 1 photo
      if (photos.length >= 3) {
        score += 0.10; // 3 or more photos
      }
    }

    // 2. Education & Verification (15% total)
    if (faculty.trim().isNotEmpty && faculty.trim() != 'All') {
      score += 0.05;
    }
    if (major.trim().isNotEmpty && major.trim() != '-') {
      score += 0.05;
    }
    if (isVerifiedStudent) {
      score += 0.05;
    }

    // 3. Bio / About Me (15% total)
    if (bio.trim().length >= 10) {
      score += 0.15;
    } else if (bio.trim().isNotEmpty) {
      score += 0.08;
    }

    // 4. Campus Activities & Passions (15% total)
    if (activities.length >= 3) {
      score += 0.15;
    } else if (activities.isNotEmpty) {
      score += (activities.length / 3.0) * 0.15;
    }

    // 5. Lifestyle & Dating Goal (20% total)
    final lifestyleCount = profileInterests.displayItems.length;
    if (lifestyleCount >= 4) {
      score += 0.20;
    } else if (lifestyleCount > 0) {
      score += (lifestyleCount / 4.0) * 0.20;
    }

    // 6. Campus Vibes (15% total)
    if (anthemSong.trim().isNotEmpty) {
      score += 0.10;
    }
    if (campusHangout.trim().isNotEmpty) {
      score += 0.05;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Breakdown of criteria for the profile completeness checklist
  List<ProfileChecklistItem> get completenessChecklist {
    return [
      ProfileChecklistItem(
        title: 'At least 1 profile photo',
        weightPercent: 10,
        isCompleted: photos.isNotEmpty,
        sectionKey: 'photos',
      ),
      ProfileChecklistItem(
        title: '3 or more profile photos',
        weightPercent: 10,
        isCompleted: photos.length >= 3,
        sectionKey: 'photos',
      ),
      ProfileChecklistItem(
        title: 'Specify your faculty',
        weightPercent: 5,
        isCompleted: faculty.trim().isNotEmpty && faculty.trim() != 'All',
        sectionKey: 'faculty',
      ),
      ProfileChecklistItem(
        title: 'Specify your major',
        weightPercent: 5,
        isCompleted: major.trim().isNotEmpty && major.trim() != '-',
        sectionKey: 'major',
      ),
      ProfileChecklistItem(
        title: 'Verify student email (@email.kmutnb.ac.th)',
        weightPercent: 5,
        isCompleted: isVerifiedStudent,
        sectionKey: 'email',
      ),
      ProfileChecklistItem(
        title: 'Write campus bio (at least 10 characters)',
        weightPercent: 15,
        isCompleted: bio.trim().length >= 10,
        sectionKey: 'bio',
      ),
      ProfileChecklistItem(
        title: 'Select campus activities (at least 3)',
        weightPercent: 15,
        isCompleted: activities.length >= 3,
        sectionKey: 'activities',
      ),
      ProfileChecklistItem(
        title: 'Fill lifestyle & interests (at least 4)',
        weightPercent: 20,
        isCompleted: profileInterests.displayItems.length >= 4,
        sectionKey: 'lifestyle',
      ),
      ProfileChecklistItem(
        title: 'Pick campus anthem song',
        weightPercent: 10,
        isCompleted: anthemSong.trim().isNotEmpty,
        sectionKey: 'anthem',
      ),
      ProfileChecklistItem(
        title: 'Specify campus hangout spot',
        weightPercent: 5,
        isCompleted: campusHangout.trim().isNotEmpty,
        sectionKey: 'hangout',
      ),
    ];
  }

  const StudentProfile({
    required this.id,
    required this.name,
    required this.nickname,
    required this.age,
    required this.faculty,
    required this.major,
    required this.year,
    required this.studentEmail,
    required this.bio,
    required this.photos,
    required this.interests,
    this.commonInterests = const [],
    this.profileInterests = const ProfileInterests(),
    this.anthemSong = '',
    this.anthemArtist = '',
    this.favoriteMovie = '',
    this.campusHangout = '',
    this.distanceKm = 0.0,
    this.isVerifiedStudent = false,
    this.matchesCount = 0,
    this.likesCount = 0,
  });

  StudentProfile copyWith({
    String? id,
    String? name,
    String? nickname,
    int? age,
    String? faculty,
    String? major,
    String? year,
    String? studentEmail,
    String? bio,
    List<String>? photos,
    List<String>? interests,
    List<String>? activities,
    List<String>? commonInterests,
    ProfileInterests? profileInterests,
    String? anthemSong,
    String? anthemArtist,
    String? favoriteMovie,
    String? campusHangout,
    double? distanceKm,
    bool? isVerifiedStudent,
    int? matchesCount,
    int? likesCount,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      year: year ?? this.year,
      studentEmail: studentEmail ?? this.studentEmail,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      interests: activities ?? interests ?? this.interests,
      commonInterests: commonInterests ?? this.commonInterests,
      profileInterests: profileInterests ?? this.profileInterests,
      anthemSong: anthemSong ?? this.anthemSong,
      anthemArtist: anthemArtist ?? this.anthemArtist,
      favoriteMovie: favoriteMovie ?? this.favoriteMovie,
      campusHangout: campusHangout ?? this.campusHangout,
      distanceKm: distanceKm ?? this.distanceKm,
      isVerifiedStudent: isVerifiedStudent ?? this.isVerifiedStudent,
      matchesCount: matchesCount ?? this.matchesCount,
      likesCount: likesCount ?? this.likesCount,
    );
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    final uid = id ?? map['uid']?.toString() ?? map['id']?.toString() ?? '';
    final name = map['name']?.toString() ?? 'Student';
    final nickname = map['nickname']?.toString().isNotEmpty == true
        ? map['nickname'].toString()
        : name.split(' ').first;

    final rawActivities = map['activities'] ?? map['interests'];
    final parsedInterests = parseList(rawActivities);

    final rawInterestsData =
        map['profileInterests'] ?? map['lifestyle'] ?? map['interestsData'];
    final profileInterests = ProfileInterests.fromMap(
      rawInterestsData is Map ? rawInterestsData : null,
    );

    return StudentProfile(
      id: uid,
      name: name,
      nickname: nickname,
      age: (map['age'] is num)
          ? (map['age'] as num).toInt()
          : int.tryParse(map['age']?.toString() ?? '20') ?? 20,
      faculty: map['faculty']?.toString() ?? '',
      major: map['major']?.toString() ?? '',
      year: map['year']?.toString() ?? '',
      studentEmail:
          map['email']?.toString() ?? map['studentEmail']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      photos: parseList(map['photos']),
      interests: parsedInterests,
      commonInterests: parseList(map['commonInterests']),
      profileInterests: profileInterests,
      anthemSong: map['anthemSong']?.toString() ?? '',
      anthemArtist: map['anthemArtist']?.toString() ?? '',
      favoriteMovie: map['favoriteMovie']?.toString() ?? '',
      campusHangout: map['campusHangout']?.toString() ?? '',
      distanceKm: (map['distanceKm'] is num)
          ? (map['distanceKm'] as num).toDouble()
          : double.tryParse(map['distanceKm']?.toString() ?? '0.0') ?? 0.0,
      isVerifiedStudent: map['isVerifiedStudent'] == true,
      matchesCount: (map['matchesCount'] is num)
          ? (map['matchesCount'] as num).toInt()
          : 0,
      likesCount: (map['likesCount'] is num)
          ? (map['likesCount'] as num).toInt()
          : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'nickname': nickname,
      'age': age,
      'faculty': faculty,
      'major': major,
      'year': year,
      'email': studentEmail,
      'bio': bio,
      'photos': photos,
      'activities': interests,
      'interests': interests,
      'profileInterests': profileInterests.toMap(),
      'commonInterests': commonInterests,
      'anthemSong': anthemSong,
      'anthemArtist': anthemArtist,
      'favoriteMovie': favoriteMovie,
      'campusHangout': campusHangout,
      'distanceKm': distanceKm,
      'isVerifiedStudent': isVerifiedStudent,
      'matchesCount': matchesCount,
      'likesCount': likesCount,
      'profileCompleteness': profileCompleteness,
    };
  }

  /// Sample mock profiles across university faculties
  static List<StudentProfile> get sampleProfiles => [
    const StudentProfile(
      id: 'student_1',
      name: 'Pimchanok V.',
      nickname: 'Pim',
      age: 21,
      faculty: 'Architecture & Design',
      major: 'Industrial Design',
      year: 'Year 3 (Junior)',
      studentEmail: 'pim.v@student.chula.ac.th',
      bio:
          'Drafting blueprints by day, hunting indie coffee bars by night. Big fan of Bauhaus geometry, analog photography, and jazz vinyls.',
      photos: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=700&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=700&auto=format&fit=crop&q=80',
      ],
      interests: [
        'Architecture',
        'Film Photography',
        'Indie Rock',
        'Matcha Latte',
        'Art Exhibitions',
        'Sketching',
      ],
      commonInterests: ['Architecture', 'Indie Rock', 'Matcha Latte'],
      profileInterests: ProfileInterests(
        datingFor: 'Long-term relationship',
        lookingFor: 'Everyone',
        languages: ['Thai', 'English'],
        zodiac: 'Virgo ♍',
        education: 'Undergraduate / Bachelor',
        familyPlans: 'Not sure yet',
        communicationStyle: 'Better in person',
        loveStyle: 'Quality time',
        bloodType: 'O',
        pets: 'Cat person 🐱',
        drinking: 'Special occasions only',
        smoking: 'Non-smoker',
        workout: 'Often (3-4x/week)',
        socialMedia: 'Active on Instagram',
      ),
      anthemSong: 'Sparks',
      anthemArtist: 'Coldplay',
      favoriteMovie: 'Grand Budapest Hotel',
      campusHangout: 'Faculty of Arch Library & Lawn',
      distanceKm: 0.3,
      isVerifiedStudent: true,
      matchesCount: 22,
      likesCount: 65,
    ),
    const StudentProfile(
      id: 'student_2',
      name: 'Tanawat S.',
      nickname: 'Mark',
      age: 22,
      faculty: 'Engineering',
      major: 'Computer Engineering',
      year: 'Year 4 (Senior)',
      studentEmail: 'tanawat.s@student.ku.ac.th',
      bio:
          'Building robots, debugging life at 2 AM. Always down for badminton, late night hackathons, and good street food after midterm.',
      photos: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=700&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=700&auto=format&fit=crop&q=80',
      ],
      interests: [
        'Coding',
        'Badminton',
        'Board Games',
        'Sci-Fi Movies',
        'Specialty Coffee',
        'Hackathons',
      ],
      commonInterests: ['Coding', 'Board Games', 'Specialty Coffee'],
      profileInterests: ProfileInterests(
        datingFor: 'Long-term, open to short',
        lookingFor: 'Women',
        languages: ['Thai', 'English', 'Japanese'],
        zodiac: 'Gemini ♊',
        education: 'Undergraduate / Bachelor',
        communicationStyle: 'Big time texter',
        loveStyle: 'Acts of service',
        bloodType: 'B',
        pets: 'Dog lover 🐶',
        drinking: 'Socially on weekends',
        smoking: 'Non-smoker',
        workout: 'Everyday',
        socialMedia: 'LinkedIn professional',
      ),
      anthemSong: 'Midnight City',
      anthemArtist: 'M83',
      favoriteMovie: 'Interstellar',
      campusHangout: 'Engineering Co-working Space',
      distanceKm: 0.8,
      isVerifiedStudent: true,
      matchesCount: 18,
      likesCount: 52,
    ),
    const StudentProfile(
      id: 'student_3',
      name: 'Chanya K.',
      nickname: 'Mei',
      age: 20,
      faculty: 'Communication Arts',
      major: 'Film & Photography',
      year: 'Year 2 (Sophomore)',
      studentEmail: 'chanya.k@student.cmu.ac.th',
      bio:
          'Directing short films and capturing candid campus life. Need a movie marathon partner or someone to share dessert with.',
      photos: [
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=700&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=700&auto=format&fit=crop&q=80',
      ],
      interests: [
        'Cinema',
        'Baking',
        'Vintage Thrift',
        'Pop Art',
        'Cats',
        'Spotify Playlists',
      ],
      commonInterests: ['Cinema', 'Spotify Playlists', 'Vintage Thrift'],
      profileInterests: ProfileInterests(
        datingFor: 'New friends',
        lookingFor: 'Everyone',
        languages: ['Thai', 'English', 'Korean'],
        zodiac: 'Pisces ♓',
        education: 'Undergraduate / Bachelor',
        communicationStyle: 'Phone caller',
        loveStyle: 'Words of affirmation',
        bloodType: 'A',
        pets: 'Cat person 🐱',
        drinking: 'Special occasions only',
        smoking: 'Non-smoker',
        workout: 'Sometimes (1-2x/week)',
        socialMedia: 'Spotify playlist curator',
      ),
      anthemSong: 'About You',
      anthemArtist: 'The 1975',
      favoriteMovie: 'La La Land',
      campusHangout: 'Campus Film Studio & Amphitheater',
      distanceKm: 1.2,
      isVerifiedStudent: true,
      matchesCount: 31,
      likesCount: 89,
    ),
    const StudentProfile(
      id: 'student_4',
      name: 'Krit P.',
      nickname: 'Ken',
      age: 23,
      faculty: 'Medicine',
      major: 'General Medicine',
      year: 'Year 5 (Clinical)',
      studentEmail: 'krit.p@student.mahidol.ac.th',
      bio:
          'Surviving ward rounds on pure espresso. When not studying anatomy, I play acoustic guitar and run 10k loops around campus.',
      photos: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=700&auto=format&fit=crop&q=80',
      ],
      interests: [
        'Running',
        'Acoustic Guitar',
        'Espresso',
        'Med Student Memes',
        'Hiking',
        'Podcasts',
      ],
      commonInterests: ['Espresso', 'Running', 'Podcasts'],
      profileInterests: ProfileInterests(
        datingFor: 'Long-term relationship',
        lookingFor: 'Women',
        languages: ['Thai', 'English'],
        zodiac: 'Capricorn ♑',
        education: 'Doctorate / PhD',
        communicationStyle: 'Bad texter',
        loveStyle: 'Quality time',
        bloodType: 'AB',
        pets: 'Want a pet',
        drinking: 'Special occasions only',
        smoking: 'Non-smoker',
        workout: 'Everyday',
        socialMedia: 'Minimal social media',
      ),
      anthemSong: 'Slow Dancing in a Burning Room',
      anthemArtist: 'John Mayer',
      favoriteMovie: 'Good Will Hunting',
      campusHangout: 'Hospital Quadrangle & Rooftop',
      distanceKm: 2.1,
      isVerifiedStudent: true,
      matchesCount: 15,
      likesCount: 44,
    ),
    const StudentProfile(
      id: 'student_5',
      name: 'Nattaporn R.',
      nickname: 'Grace',
      age: 21,
      faculty: 'Business Administration',
      major: 'Marketing & Brand Strategy',
      year: 'Year 3 (Junior)',
      studentEmail: 'nattaporn.r@student.tu.ac.th',
      bio:
          'Case competition enthusiast, cafe hopper, and travel planner. Let’s trade pitch deck tips and find the best croissants in town.',
      photos: [
        'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=700&auto=format&fit=crop&q=80',
      ],
      interests: [
        'Startups',
        'Pastry Baking',
        'Pilates',
        'Travel Vlogging',
        'Modern Art',
        'Networking',
      ],
      commonInterests: ['Startups', 'Modern Art', 'Pastry Baking'],
      profileInterests: ProfileInterests(
        datingFor: 'Long-term relationship',
        lookingFor: 'Men',
        languages: ['Thai', 'English', 'Chinese (Mandarin)'],
        zodiac: 'Leo ♌',
        education: 'Undergraduate / Bachelor',
        communicationStyle: 'Big time texter',
        loveStyle: 'Receiving gifts',
        bloodType: 'B',
        pets: 'Both dogs & cats 🐾',
        drinking: 'Socially on weekends',
        smoking: 'Non-smoker',
        workout: 'Often (3-4x/week)',
        socialMedia: 'Active on Instagram',
      ),
      anthemSong: 'Cruel Summer',
      anthemArtist: 'Taylor Swift',
      favoriteMovie: 'The Devil Wears Prada',
      campusHangout: 'BBA Lounge & Central Library',
      distanceKm: 0.5,
      isVerifiedStudent: true,
      matchesCount: 27,
      likesCount: 73,
    ),
    const StudentProfile(
      id: 'student_6',
      name: 'Vorapol M.',
      nickname: 'Peak',
      age: 20,
      faculty: 'Science',
      major: 'Biochemistry',
      year: 'Year 2 (Sophomore)',
      studentEmail: 'vorapol.m@student.chula.ac.th',
      bio:
          'Pipetting solutions in the lab. Passionate about stargazing, synth-wave concerts, and ramen quests after late classes.',
      photos: [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=700&auto=format&fit=crop&q=80',
      ],
      interests: [
        'Astronomy',
        'Ramen',
        'Synthwave',
        'Camping',
        'Anime',
        'Gym Workout',
      ],
      commonInterests: ['Ramen', 'Astronomy', 'Gym Workout'],
      profileInterests: ProfileInterests(
        datingFor: 'Still figuring it out',
        lookingFor: 'Everyone',
        languages: ['Thai', 'English', 'Japanese'],
        zodiac: 'Aquarius ♒',
        education: 'Undergraduate / Bachelor',
        communicationStyle: 'Better in person',
        loveStyle: 'Physical touch',
        bloodType: 'O',
        pets: 'Reptiles / Fish / Birds 🦜',
        drinking: 'Socially on weekends',
        smoking: 'Social smoker',
        workout: 'Often (3-4x/week)',
        socialMedia: 'X (Twitter) active',
      ),
      anthemSong: 'Resonance',
      anthemArtist: 'HOME',
      favoriteMovie: 'Blade Runner 2049',
      campusHangout: 'Science Faculty Garden',
      distanceKm: 1.5,
      isVerifiedStudent: true,
      matchesCount: 12,
      likesCount: 39,
    ),
  ];

  /// Current logged-in user profile default
  static StudentProfile get currentUser => const StudentProfile(
    id: 'my_user_id',
    name: 'Thanathip A.',
    nickname: 'Art',
    age: 21,
    faculty: 'Architecture & Design',
    major: 'Urban Planning & Visual Media',
    year: 'Year 3 (Junior)',
    studentEmail: 'art.thana@student.chula.ac.th',
    bio:
        'Obsessed with modernist grid layouts, Brutalism, espresso shots, and urban exploration. Looking for study partners and concert buddies.',
    photos: [],
    interests: [
      'Architecture',
      'Indie Rock',
      'Matcha Latte',
      'Coding',
      'Board Games',
      'Specialty Coffee',
      'Cinema',
      'Running',
    ],
    commonInterests: [],
    profileInterests: ProfileInterests(
      datingFor: 'Long-term, open to short',
      lookingFor: 'Everyone',
      languages: ['Thai', 'English'],
      zodiac: 'Scorpio ♏',
      education: 'Undergraduate / Bachelor',
      communicationStyle: 'Better in person',
      loveStyle: 'Quality time',
      bloodType: 'O',
      pets: 'Cat person 🐱',
      drinking: 'Socially on weekends',
      smoking: 'Non-smoker',
      workout: 'Often (3-4x/week)',
      socialMedia: 'Active on Instagram',
    ),
    anthemSong: 'Blue Monday',
    anthemArtist: 'New Order',
    favoriteMovie: 'Metropolis (1927)',
    campusHangout: 'Central Library 4th Floor & Arch Workshop',
    distanceKm: 0.0,
    isVerifiedStudent: true,
    matchesCount: 16,
    likesCount: 58,
  );
}
