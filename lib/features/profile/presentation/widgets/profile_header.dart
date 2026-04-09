import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

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
    const avatarRadius = 36.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Avatar ──────────────────────────────────────────────
        GestureDetector(
          onTap: isUploadingImage ? null : onEditTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withAlpha(isDark ? 40 : 20),
                ),
                child: ClipOval(
                  child: isUploadingImage
                      ? Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPrimary,
                            ),
                          ),
                        )
                      : profileImageUrl != null &&
                            profileImageUrl!.isNotEmpty
                      ? Image.network(
                          profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _AvatarFallback(
                            letter: avatarLetter,
                          ),
                        )
                      : _AvatarFallback(letter: avatarLetter),
                ),
              ),
              // Camera badge
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // ── Info ─────────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? '—' : name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : kTextDark,
                  letterSpacing: kLs(-0.3),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                email.isEmpty ? '—' : email,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : kTextMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.letter});
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: kPrimary,
        ),
      ),
    );
  }
}
