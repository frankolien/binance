import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// Phase-1 stand-in for KYC-backed profile data. Returns a single fake user.
/// Swap for a real impl once KYC writes through to a profile store.
class StubUserProfileRepository implements UserProfileRepository {
  const StubUserProfileRepository();

  @override
  UserProfile? current() {
    // Placeholder data for the demo. Real impl reads from the KYC store.
    // Don't put real personal data here — this file is committed to git.
    return const UserProfile(
      fullName: 'Demo User',
      address: '123 Example Street',
      city: 'Lagos',
      postalCode: '100001',
      country: 'Nigeria',
    );
  }
}
