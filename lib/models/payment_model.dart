class Payment {
  final int id;
  final int consultationId;
  final double amount;
  final double platformFee;
  final double totalAmount;
  final String paymentMethod;
  final String? paymentProof;
  final String status; // 'pending', 'verified', 'rejected'
  final String? rejectionNote;
  final DateTime? createdAt;

  Payment({
    required this.id,
    required this.consultationId,
    required this.amount,
    required this.platformFee,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentProof,
    required this.status,
    this.rejectionNote,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      consultationId: json['consultation_id'] is String
          ? int.parse(json['consultation_id'])
          : json['consultation_id'],
      amount: json['amount'] != null
          ? double.parse(json['amount'].toString())
          : 0.0,
      platformFee: json['platform_fee'] != null
          ? double.parse(json['platform_fee'].toString())
          : 0.0,
      totalAmount: json['total_amount'] != null
          ? double.parse(json['total_amount'].toString())
          : 0.0,
      paymentMethod: json['payment_method'] ?? 'bank_transfer',
      paymentProof: json['payment_proof'],
      status: json['status'] ?? 'pending',
      rejectionNote: json['rejection_note'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'consultation_id': consultationId,
        'amount': amount,
        'platform_fee': platformFee,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'payment_proof': paymentProof,
        'status': status,
        'rejection_note': rejectionNote,
        'created_at': createdAt?.toIso8601String(),
      };
}
