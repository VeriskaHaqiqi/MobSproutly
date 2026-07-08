import '../config/app_config.dart';
import '../models/article_model.dart';
import '../models/user_model.dart';
import '../models/consultation_model.dart';
import '../screens/user/user_artikel.dart';
import '../screens/user/user_pencarian.dart';
import '../screens/user/user_consult.dart';
import '../screens/expert/expert_consult.dart';
import '../screens/expert/expert_artikel.dart';

class ModelConverter {
  static String getBaseUrl() {
    return AppConfig.baseUrl.replaceAll('/api', '');
  }

  static String getUserAvatar(User user) {
    final baseUrl = getBaseUrl();
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      if (user.photoUrl!.startsWith('http')) {
        return user.photoUrl!;
      } else {
        return '$baseUrl/storage/${user.photoUrl}';
      }
    }
    return 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80';
  }

  // Convert Article to ArticleItem
  static ArticleItem articleToItem(Article article) {
    final baseUrl = getBaseUrl();
    String imageUrl = 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=800&q=80';

    if (article.coverImage != null && article.coverImage!.isNotEmpty) {
      if (article.coverImage!.startsWith('http')) {
        imageUrl = article.coverImage!;
      } else {
        imageUrl = '$baseUrl/storage/${article.coverImage}';
      }
    }

    String friendlyTime = 'Recently';
    if (article.createdAt != null) {
      final diff = DateTime.now().difference(article.createdAt!);
      if (diff.inDays > 0) {
        friendlyTime = '${diff.inDays} days ago';
      } else if (diff.inHours > 0) {
        friendlyTime = '${diff.inHours} hours ago';
      } else if (diff.inMinutes > 0) {
        friendlyTime = '${diff.inMinutes} minutes ago';
      } else {
        friendlyTime = 'Just now';
      }
    }

    return ArticleItem(
      id: article.id.toString(),
      category: article.category?.name ?? 'Indoor Plants',
      title: article.title,
      author: article.author?.name ?? 'Expert Botanist',
      time: friendlyTime,
      imageUrl: imageUrl,
      isBookmarked: article.isBookmarked,
      content: article.content,
    );
  }

  // Convert Article to ExpertArticleItem
  static ExpertArticleItem articleToExpertArticleItem(Article article, int? currentUserId) {
    final baseUrl = getBaseUrl();
    String imageUrl = 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=800&q=80';

    if (article.coverImage != null && article.coverImage!.isNotEmpty) {
      if (article.coverImage!.startsWith('http')) {
        imageUrl = article.coverImage!;
      } else {
        imageUrl = '$baseUrl/storage/${article.coverImage}';
      }
    }

    String friendlyTime = 'Recently';
    if (article.createdAt != null) {
      final diff = DateTime.now().difference(article.createdAt!);
      if (diff.inDays > 0) {
        friendlyTime = '${diff.inDays} days ago';
      } else if (diff.inHours > 0) {
        friendlyTime = '${diff.inHours} hours ago';
      } else if (diff.inMinutes > 0) {
        friendlyTime = '${diff.inMinutes} minutes ago';
      } else {
        friendlyTime = 'Just now';
      }
    }

    return ExpertArticleItem(
      id: article.id.toString(),
      category: article.category?.name ?? 'Ornamental Plants',
      title: article.title,
      author: article.author?.name ?? 'Expert Botanist',
      time: friendlyTime,
      imageUrl: imageUrl,
      content: article.content,
      isMine: currentUserId != null && article.userId == currentUserId,
      isBookmarked: article.isBookmarked,
    );
  }


  // Convert Expert User to ExpertItem
  static ExpertItem userToExpertItem(User user) {
    final profile = user.expertProfile;
    final avatar = getUserAvatar(user);

    // Determine category based on specializations or default to first strict category
    String category = 'Ornamental Plants';
    final strictCategories = [
      'Ornamental Plants',
      'Vegetables & Food Crops',
      'Fruit Plants',
      'Herbs & Spices',
    ];

    if (user.specializations != null && user.specializations!.isNotEmpty) {
      for (var spec in user.specializations!) {
        final match = strictCategories.firstWhere(
          (c) => c.toLowerCase() == spec.name.toLowerCase(),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          category = match;
          break;
        }
      }
      // If no strict category matched, check if first specialization matches partly
      if (category == 'Ornamental Plants' && user.specializations!.isNotEmpty) {
        final firstSpec = user.specializations!.first.name.toLowerCase();
        if (firstSpec.contains('vegetable') || firstSpec.contains('crop') || firstSpec.contains('pangan') || firstSpec.contains('sayur')) {
          category = 'Vegetables & Food Crops';
        } else if (firstSpec.contains('fruit') || firstSpec.contains('buah')) {
          category = 'Fruit Plants';
        } else if (firstSpec.contains('herb') || firstSpec.contains('spice') || firstSpec.contains('rempah') || firstSpec.contains('obat')) {
          category = 'Herbs & Spices';
        }
      }
    }

    final specs = user.specializations?.map((s) => s.name).toList() ?? ['Generalist'];

    return ExpertItem(
      id: user.id.toString(),
      name: user.name,
      degree: profile?.university ?? 'Certified Botanist',
      rating: profile?.averageRating ?? 5.0,
      yearsExp: profile?.yearsOfExperience ?? 3,
      isAvailableNow: profile?.availabilityStatus == 'available',
      availableText: profile?.availabilityStatus == 'available' ? 'Available Now' : 'Unavailable',
      specialties: specs,
      bio: profile?.description ?? 'No bio provided.',
      avatarUrl: avatar,
      category: category,
      pricePerSession: profile?.sessionFee ?? 50000.0,
      topics: specs.map((s) => s.toLowerCase()).toList(),
      totalConsultations: profile?.totalConsultations ?? 0,
      avgResponse: '5 min',
      reviews: [], // Can load dynamically if ratings are expanded
    );
  }

  // Convert Consultation to ConsultItem (User Side)
  static ConsultItem consultationToConsultItem(Consultation consultation) {
    final expertUser = consultation.expert;
    final expertName = expertUser?.name ?? 'Expert Botanist';
    final avatar = expertUser != null ? getUserAvatar(expertUser) : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80';
    final specialty = (expertUser?.specializations != null && expertUser!.specializations!.isNotEmpty)
        ? expertUser.specializations!.first.name
        : 'Botanist';
    final topics = expertUser?.specializations?.map((s) => s.name).toList() ?? <String>[];

    String lastMsg = 'Tap to chat';
    if (consultation.status == 'waiting_payment') {
      lastMsg = 'Menunggu Pembayaran';
    } else if (consultation.status == 'waiting_verification') {
      lastMsg = 'Menunggu Verifikasi Pembayaran';
    } else if (consultation.status == 'rejected') {
      lastMsg = 'Pembayaran Ditolak. Silakan unggah ulang.';
    } else if (consultation.status == 'completed') {
      lastMsg = 'Sesi Konsultasi Selesai';
    } else if (consultation.status == 'active') {
      lastMsg = 'Sesi Konsultasi Aktif';
    }

    String friendlyTime = 'Recently';
    final dateToUse = consultation.startedAt ?? consultation.createdAt;
    if (dateToUse != null) {
      final diff = DateTime.now().difference(dateToUse);
      if (diff.inDays > 0) {
        friendlyTime = '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        friendlyTime = '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        friendlyTime = '${diff.inMinutes}m ago';
      } else {
        friendlyTime = 'Just now';
      }
    }

    return ConsultItem(
      id: consultation.id.toString(),
      expertId: consultation.expertId.toString(),
      expertName: expertName,
      specialty: specialty,
      lastMessage: lastMsg,
      time: friendlyTime,
      avatarUrl: avatar,
      isOnline: expertUser?.expertProfile?.availabilityStatus == 'available',
      isRead: true,
      isActive: consultation.status == 'active',
      topics: topics,
    );
  }

  // Convert Consultation to ExpertConsultItem (Expert Side)
  static ExpertConsultItem consultationToExpertConsultItem(Consultation consultation) {
    final clientUser = consultation.user;
    final clientName = clientUser?.name ?? 'Client User';
    final avatar = clientUser != null ? getUserAvatar(clientUser) : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80';
    final topic = consultation.topic ?? 'Plant Consultation';

    String lastMsg = 'Tap to chat';
    if (consultation.status == 'waiting_payment') {
      lastMsg = 'Menunggu Pembayaran';
    } else if (consultation.status == 'waiting_verification') {
      lastMsg = 'Menunggu Verifikasi Pembayaran';
    } else if (consultation.status == 'rejected') {
      lastMsg = 'Pembayaran Ditolak';
    } else if (consultation.status == 'completed') {
      lastMsg = 'Sesi Konsultasi Selesai';
    } else if (consultation.status == 'active') {
      lastMsg = 'Sesi Konsultasi Aktif';
    }

    String friendlyTime = 'Recently';
    final dateToUse = consultation.startedAt ?? consultation.createdAt;
    if (dateToUse != null) {
      final diff = DateTime.now().difference(dateToUse);
      if (diff.inDays > 0) {
        friendlyTime = '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        friendlyTime = '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        friendlyTime = '${diff.inMinutes}m ago';
      } else {
        friendlyTime = 'Just now';
      }
    }

    return ExpertConsultItem(
      id: consultation.id.toString(),
      clientName: clientName,
      clientAvatar: avatar,
      lastMessage: lastMsg,
      time: friendlyTime,
      isOnline: false,
      isRead: true,
      topic: topic,
      sessionFee: consultation.fee,
      category: topic,
    );
  }
}