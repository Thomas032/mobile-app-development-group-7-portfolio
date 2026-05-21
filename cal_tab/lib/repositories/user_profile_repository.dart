import 'dart:convert';

import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/services/local_key_value_store.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> loadProfile();

  Future<void> saveProfile(UserProfile profile);

  Future<void> clearProfile();
}

class LocalUserProfileRepository implements UserProfileRepository {
  const LocalUserProfileRepository({
    required LocalKeyValueStore store,
    this.storageKey = 'user_profile_v1',
  }) : _store = store;

  final LocalKeyValueStore _store;
  final String storageKey;

  @override
  Future<UserProfile?> loadProfile() async {
    final encodedProfile = await _store.readString(storageKey);
    if (encodedProfile == null) {
      return null;
    }

    final decoded = jsonDecode(encodedProfile) as Map<String, dynamic>;
    return UserProfile.fromJson(decoded);
  }

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _store.writeString(storageKey, jsonEncode(profile.toJson()));
  }

  @override
  Future<void> clearProfile() {
    return _store.remove(storageKey);
  }
}
