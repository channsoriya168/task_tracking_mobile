import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.isDark,
    required this.name,
    required this.role,
    required this.email,
    required this.avatarLetter,
    this.profileImageUrl,
    this.isUploadingImage = false,
    this.onEditTap,
  });

  final bool isDark;
  final String name;
  final String role;
  final String email;
  final String avatarLetter;
  final String? profileImageUrl;
  final bool isUploadingImage;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: kContentPaddingLarge,
      child: Column(
        children: [
          GestureDetector(
            onTap: isUploadingImage ? null : onEditTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimary.withAlpha(30),
                    border: Border.all(color: kPrimary.withAlpha(80), width: 2),
                  ),
                  child: ClipOval(
                    child: isUploadingImage
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: kPrimary,
                              ),
                            ),
                          )
                        : profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? Image.network(
                                profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    avatarLetter,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimary,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  avatarLetter,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimary,
                                  ),
                                ),
                              ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty ? '—' : name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.isEmpty ? '—' : role,
              style: const TextStyle(
                fontSize: 12,
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              email,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : kTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}