import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/post_comment.dart';

class SocialPostService {
  /// Toggle like/unlike on a post ('job' or 'internship')
  static Future<Map<String, dynamic>> toggleLike({
    required String postType,
    required int postId,
  }) async {
    try {
      final res = await ApiClient.post('/posts/like', {
        'post_type': postType.toLowerCase(),
        'post_id': postId,
      });
      final json = ApiClient.parse(res);
      if (json['success'] == true && json['data'] != null) {
        return {
          'is_liked': json['data']['is_liked'] ?? false,
          'likes_count': json['data']['likes_count'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
    return {'is_liked': false, 'likes_count': 0};
  }

  /// Get comments for a post
  static Future<List<PostComment>> getComments({
    required String postType,
    required int postId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final res = await ApiClient.get(
        '/posts/comments?post_type=${postType.toLowerCase()}&post_id=$postId&page=$page&limit=$limit',
      );
      final json = ApiClient.parse(res);
      if (json['success'] == true && json['data'] is List) {
        final List list = json['data'];
        return list.map((item) => PostComment.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }
    return [];
  }

  /// Add a new comment
  static Future<PostComment?> addComment({
    required String postType,
    required int postId,
    required String content,
  }) async {
    try {
      final res = await ApiClient.post('/posts/comments', {
        'post_type': postType.toLowerCase(),
        'post_id': postId,
        'content': content,
      });
      final json = ApiClient.parse(res);
      if (json['success'] == true && json['data'] != null) {
        return PostComment.fromJson(json['data']);
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
    return null;
  }

  /// Record a share event
  static Future<int> recordShare({
    required String postType,
    required int postId,
    String platform = 'native',
  }) async {
    try {
      final res = await ApiClient.post('/posts/share', {
        'post_type': postType.toLowerCase(),
        'post_id': postId,
        'platform': platform,
      });
      final json = ApiClient.parse(res);
      if (json['success'] == true && json['data'] != null) {
        return json['data']['shares_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error recording share: $e');
    }
    return 0;
  }
}
