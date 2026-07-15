import 'package:flutter/material.dart';
import '../models/enums.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    required this.type,
    this.compact = true,
  });

  final CreatorVerificationType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = Color(type.color);
    if (compact) {
      return Tooltip(
        message: type.label,
        child: Icon(type.icon, color: color, size: 18),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            type.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the appropriate verification badge for a user profile.
class UserVerificationBadge extends StatelessWidget {
  const UserVerificationBadge({super.key, required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    final isVerified = user.isVerifiedCreator as bool? ?? false;
    final type = user.creatorVerificationType as CreatorVerificationType?;

    if (isVerified && type != null) {
      return VerifiedBadge(type: type);
    }

    if (user.isVerified == true) {
      return const Icon(Icons.verified, color: Color(0xFFD4AF37), size: 18);
    }

    return const SizedBox.shrink();
  }
}
