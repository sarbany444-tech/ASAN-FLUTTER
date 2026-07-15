import '../models/enums.dart';
import '../models/user_model.dart';

/// Local-only account used when auth is bypassed for UI development.
class DevAccounts {
  DevAccounts._();

  static const guestCreator = UserModel(
    uid: 'dev_guest_creator',
    email: 'dev.creator@naseem.local',
    displayName: 'Dev Creator',
    role: UserRole.teacher,
    isVerified: true,
    verificationStatus: VerificationStatus.approved,
    creatorVerificationType: CreatorVerificationType.teacher,
  );
}
