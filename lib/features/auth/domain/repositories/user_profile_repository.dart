import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  /// Returns the current user's profile, or null if not signed in / not KYC'd.
  UserProfile? current();
}
