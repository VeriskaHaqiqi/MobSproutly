class Specialization {
  final int id;
  final String name;

  Specialization({
    required this.id,
    required this.name,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ExpertProfile {
  final int id;
  final int userId;
  final String? university;
  final int yearsOfExperience;
  final String? description;
  final String? certificate;
  final String? diploma;
  final String? bankName;
  final String? accountHolder;
  final String? accountNumber;
  final double sessionFee;
  final int sessionDuration;
  final bool instantBooking;
  final String availabilityStatus; // 'available' or 'unavailable'
  final double averageRating;
  final int totalConsultations;

  ExpertProfile({
    required this.id,
    required this.userId,
    this.university,
    required this.yearsOfExperience,
    this.description,
    this.certificate,
    this.diploma,
    this.bankName,
    this.accountHolder,
    this.accountNumber,
    required this.sessionFee,
    required this.sessionDuration,
    required this.instantBooking,
    required this.availabilityStatus,
    required this.averageRating,
    required this.totalConsultations,
  });

  factory ExpertProfile.fromJson(Map<String, dynamic> json) {
    return ExpertProfile(
      id: json['id'],
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'],
      university: json['university'],
      yearsOfExperience: json['years_of_experience'] is String
          ? int.parse(json['years_of_experience'])
          : (json['years_of_experience'] ?? 0),
      description: json['description'],
      certificate: json['certificate'],
      diploma: json['diploma'],
      bankName: json['bank_name'],
      accountHolder: json['account_holder'],
      accountNumber: json['account_number'],
      sessionFee: json['session_fee'] != null
          ? double.parse(json['session_fee'].toString())
          : 0.0,
      sessionDuration: json['session_duration'] is String
          ? int.parse(json['session_duration'])
          : (json['session_duration'] ?? 30),
      instantBooking: json['instant_booking'] is int
          ? json['instant_booking'] == 1
          : (json['instant_booking'] ?? false),
      availabilityStatus: json['availability_status'] ?? 'unavailable',
      averageRating: json['average_rating'] != null
          ? double.parse(json['average_rating'].toString())
          : 0.0,
      totalConsultations: json['total_consultations'] is String
          ? int.parse(json['total_consultations'])
          : (json['total_consultations'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'university': university,
        'years_of_experience': yearsOfExperience,
        'description': description,
        'certificate': certificate,
        'diploma': diploma,
        'bank_name': bankName,
        'account_holder': accountHolder,
        'account_number': accountNumber,
        'session_fee': sessionFee,
        'session_duration': sessionDuration,
        'instant_booking': instantBooking,
        'availability_status': availabilityStatus,
        'average_rating': averageRating,
        'total_consultations': totalConsultations,
      };
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? gender;
  final String role; // 'user' atau 'expert'
  final String? photoUrl;
  final ExpertProfile? expertProfile;
  final List<Specialization>? specializations;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.gender,
    required this.role,
    this.photoUrl,
    this.expertProfile,
    this.specializations,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var specList = json['specializations'] as List?;
    List<Specialization>? specs = specList != null
        ? specList.map((i) => Specialization.fromJson(i)).toList()
        : null;

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      gender: json['gender'],
      role: json['role'] ?? 'user',
      photoUrl: json['photo_url'],
      expertProfile: json['expert_profile'] != null
          ? ExpertProfile.fromJson(json['expert_profile'])
          : null,
      specializations: specs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'role': role,
        'photo_url': photoUrl,
        'expert_profile': expertProfile?.toJson(),
        'specializations': specializations?.map((e) => e.toJson()).toList(),
      };
}
