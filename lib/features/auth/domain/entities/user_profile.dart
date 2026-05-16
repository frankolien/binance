import 'package:equatable/equatable.dart';

/// Snapshot of the user's KYC-derived profile data used to autofill forms.
/// In Phase 1 this is stubbed; once KYC is real, the same shape gets populated
/// from the verification result.
class UserProfile extends Equatable {
  const UserProfile({
    required this.fullName,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  final String fullName;
  final String address;
  final String city;
  final String postalCode;
  final String country;

  @override
  List<Object?> get props => [fullName, address, city, postalCode, country];
}
