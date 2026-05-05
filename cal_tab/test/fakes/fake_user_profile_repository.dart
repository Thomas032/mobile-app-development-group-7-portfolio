import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/repositories/user_profile_repository.dart';

class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository({UserProfile? initialProfile})
    : _profile = initialProfile;

  UserProfile? _profile;

  UserProfile? get profile => _profile;

  @override
  Future<UserProfile?> loadProfile() async {
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> clearProfile() async {
    _profile = null;
  }
}
