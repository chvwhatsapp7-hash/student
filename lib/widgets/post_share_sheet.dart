import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/social_post_service.dart';

class PostShareSheet extends StatelessWidget {
  final String postType;
  final int postId;
  final String title;
  final String company;
  final Function(int newShareCount)? onShareRecorded;

  const PostShareSheet({
    super.key,
    required this.postType,
    required this.postId,
    required this.title,
    required this.company,
    this.onShareRecorded,
  });

  static void show(
    BuildContext context, {
    required String postType,
    required int postId,
    required String title,
    required String company,
    Function(int newShareCount)? onShareRecorded,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PostShareSheet(
        postType: postType,
        postId: postId,
        title: title,
        company: company,
        onShareRecorded: onShareRecorded,
      ),
    );
  }

  String get _shareUrl =>
      'https://studenthub.app/${postType.toLowerCase()}s/$postId';

  String get _shareText =>
      'Check out this $postType opportunity: "$title" at $company on StudentHub!\n$_shareUrl';

  Future<void> _handleShare(BuildContext context, String platform) async {
    Navigator.pop(context);

    // Record share on backend
    final newCount = await SocialPostService.recordShare(
      postType: postType,
      postId: postId,
      platform: platform,
    );
    if (newCount > 0) {
      onShareRecorded?.call(newCount);
    }

    try {
      if (platform == 'copy') {
        await Clipboard.setData(ClipboardData(text: _shareText));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Link copied to clipboard!'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (platform == 'whatsapp') {
        final uri = Uri.parse(
            'whatsapp://send?text=${Uri.encodeComponent(_shareText)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          final webUri = Uri.parse(
              'https://api.whatsapp.com/send?text=${Uri.encodeComponent(_shareText)}');
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } else if (platform == 'linkedin') {
        final uri = Uri.parse(
            'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(_shareUrl)}');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (platform == 'twitter') {
        final uri = Uri.parse(
            'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(_shareText)}');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Share launch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share Post With Friends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Help your peers discover "$title"',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Share Options Grid/Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.link_rounded,
                  label: 'Copy Link',
                  color: const Color(0xFF6B7280),
                  onTap: () => _handleShare(context, 'copy'),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _handleShare(context, 'whatsapp'),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.business_center_rounded,
                  label: 'LinkedIn',
                  color: const Color(0xFF0A66C2),
                  onTap: () => _handleShare(context, 'linkedin'),
                ),
                _buildShareOption(
                  context,
                  icon: Icons.flutter_dash_rounded,
                  label: 'Twitter / X',
                  color: const Color(0xFF1DA1F2),
                  onTap: () => _handleShare(context, 'twitter'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
