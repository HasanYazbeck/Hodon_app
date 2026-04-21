import '../enums/app_enums.dart';

class TrustCircleMember {
  final String id;
  final String parentId;
  final String? userId; // if they have a Hodon account
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final TrustCircleMemberType memberType;
  final bool isHodonUser;
  final DateTime addedAt;

  const TrustCircleMember({
    required this.id,
    required this.parentId,
    this.userId,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.memberType,
    required this.isHodonUser,
    required this.addedAt,
  });

  factory TrustCircleMember.fromJson(Map<String, dynamic> json) => TrustCircleMember(
        id: json['id'] as String,
        parentId: json['parentId'] as String,
        userId: json['userId'] as String?,
        name: json['name'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        memberType: TrustCircleMemberType.values.byName(json['memberType'] as String),
        isHodonUser: json['isHodonUser'] as bool? ?? false,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'userId': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'memberType': memberType.name,
        'isHodonUser': isHodonUser,
        'addedAt': addedAt.toIso8601String(),
      };
}

class Review {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String revieweeId;
  final double overallRating;
  final double punctualityRating;
  final double careQualityRating;
  final double communicationRating;
  final double professionalismRating;
  final String? comment;
  final DateTime createdAt;

  // Display
  final String? reviewerName;
  final String? reviewerAvatarUrl;

  const Review({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.overallRating,
    required this.punctualityRating,
    required this.careQualityRating,
    required this.communicationRating,
    required this.professionalismRating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        bookingId: json['bookingId'] as String,
        reviewerId: json['reviewerId'] as String,
        revieweeId: json['revieweeId'] as String,
        overallRating: (json['overallRating'] as num).toDouble(),
        punctualityRating: (json['punctualityRating'] as num).toDouble(),
        careQualityRating: (json['careQualityRating'] as num).toDouble(),
        communicationRating: (json['communicationRating'] as num).toDouble(),
        professionalismRating: (json['professionalismRating'] as num).toDouble(),
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        reviewerName: json['reviewerName'] as String?,
        reviewerAvatarUrl: json['reviewerAvatarUrl'] as String?,
      );
}

class NotificationItem {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: NotificationType.values.byName(json['type'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
        data: json['data'] as Map<String, dynamic>?,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.isRead,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        text: json['text'] as String,
        imageUrl: json['imageUrl'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}

class ChatConversation {
  final String id;
  final String parentId;
  final String sitterId;
  final String? bookingId;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  // Display
  final String? otherUserName;
  final String? otherUserAvatarUrl;

  const ChatConversation({
    required this.id,
    required this.parentId,
    required this.sitterId,
    this.bookingId,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    this.otherUserName,
    this.otherUserAvatarUrl,
  });
}

class EarningsSummary {
  final double totalEarned;
  final double thisMonthEarned;
  final int totalJobs;
  final int thisMonthJobs;
  final double averageRating;
  final List<MonthlyEarning> monthlyBreakdown;

  const EarningsSummary({
    required this.totalEarned,
    required this.thisMonthEarned,
    required this.totalJobs,
    required this.thisMonthJobs,
    required this.averageRating,
    required this.monthlyBreakdown,
  });
}

class MonthlyEarning {
  final String month; // "Jan 2025"
  final double amount;
  final int jobs;

  const MonthlyEarning({
    required this.month,
    required this.amount,
    required this.jobs,
  });
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double priceMonthly;
  final double? priceYearly;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMonthly,
    this.priceYearly,
    required this.features,
    this.isPopular = false,
  });
}

