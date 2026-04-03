import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
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
    const avatarSize = 96.0;
    const bannerHeight = 100.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Gradient banner ───────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Banner
              Container(
                height: bannerHeight,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(15),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: 30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar overlapping the banner
              Positioned(
                bottom: -(avatarSize / 2),
                child: GestureDetector(
                  onTap: isUploadingImage ? null : onEditTap,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? kCardDark : Colors.white,
                          border: Border.all(
                            color: isDark ? kCardDark : Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: isUploadingImage
                              ? Container(
                                  color: kPrimary.withAlpha(20),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: kPrimary,
                                      ),
                                    ),
                                  ),
                                )
                              : profileImageUrl != null &&
                                      profileImageUrl!.isNotEmpty
                                  ? Image.network(
                                      profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _AvatarFallback(
                                        letter: avatarLetter,
                                        isDark: isDark,
                                      ),
                                    )
                                  : _AvatarFallback(
                                      letter: avatarLetter,
                                      isDark: isDark,
                                    ),
                        ),
                      ),
                      // Edit badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? kCardDark : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Name / role / email ────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24, avatarSize / 2 + 12, 24, 20),
            child: Column(
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.isEmpty ? '—' : role,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.letter, required this.isDark});
  final String letter;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimary.withAlpha(isDark ? 40 : 20),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: kPrimary,
          ),
        ),
      ),
    );
  }
}