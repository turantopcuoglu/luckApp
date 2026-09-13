import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';

/// Tarih doğrulaması için açık saat bağımlılığı.
final Provider<DateTime> birthDateTodayProvider = Provider<DateTime>(
  (Ref ref) => DateTime.now(),
);

/// Başlangıç formunun oturum içi taslağı ve kalıcı yazma durumu.
class ProfileFormState {
  /// Değiştirilemez form görünümü.
  const ProfileFormState({
    this.name = '',
    this.saving = false,
    this.invalidName = false,
    this.failed = false,
    this.legacy = false,
    this.birthDate,
    this.invalidBirthDate = false,
  });

  /// Henüz kaydedilmemiş ad/rumuz.
  final String name;

  /// Kullanıcının açıkça seçtiği doğum günü; varsayılan tarih kaydedilmez.
  final DateTime? birthDate;

  /// Eksik veya takvim aralığı dışındaki tarih.
  final bool invalidBirthDate;

  /// Disk yazması sürüyor; tekrar gönderme ve geri dönüş kilitlenir.
  final bool saving;

  /// Boş giriş doğrulama hatası.
  final bool invalidName;

  /// Yazma başarısız oldu; taslak kaybolmaz.
  final bool failed;

  /// Eski profilin tohumunu korumak için ad bu adımda salt okunurdur.
  final bool legacy;
}

/// Karşılamaya dönülse de taslağı korur; hata tekrarında kimlik değiştirmez.
class ProfileFormController extends Notifier<ProfileFormState> {
  UserProfile? _candidate;
  bool _disposed = false;

  @override
  ProfileFormState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final UserProfile? saved = ref.read(userRepositoryProvider).profil();
    _candidate = saved;
    return ProfileFormState(
      name: saved?.isim ?? '',
      birthDate: saved?.dogumTarihi,
      legacy: saved?.seedSurumu == 1,
    );
  }

  /// Kullanıcı düzenlemesi; yazım sırasında ve legacy profilde değişmez.
  void changeName(String value) {
    if (state.saving || state.legacy) return;
    state = ProfileFormState(name: value, birthDate: state.birthDate);
  }

  /// Tarihin saatini kaldırır; v1'de ve bekleyen yazımda değiştirmez.
  void changeBirthDate(DateTime value) {
    if (state.saving || state.legacy) return;
    state = ProfileFormState(
      name: state.name,
      birthDate: DateTime(value.year, value.month, value.day),
    );
  }

  /// İlk kimliği bir kez üretir; diske yazılmadan başarı döndürmez.
  Future<bool> save() async {
    if (state.saving) return false;
    final String name = state.name.trim();
    final bool legacy = state.legacy;
    final DateTime? birthDate = state.birthDate;
    final DateTime now = ref.read(birthDateTodayProvider);
    final bool invalidDate =
        birthDate == null ||
        birthDate.year < 1900 ||
        birthDate.isAfter(DateTime(now.year, now.month, now.day));
    if (name.isEmpty || invalidDate) {
      state = ProfileFormState(
        name: state.name,
        invalidName: name.isEmpty,
        birthDate: birthDate,
        invalidBirthDate: invalidDate,
        legacy: legacy,
      );
      return false;
    }
    state = ProfileFormState(
      name: state.name,
      birthDate: birthDate,
      saving: true,
      legacy: legacy,
    );
    try {
      _candidate ??=
          ref.read(userRepositoryProvider).profil() ??
          ref
              .read(userProfileFactoryProvider)
              .olustur(isim: name, dogumTarihi: birthDate);
      final UserProfile candidate = _candidate!;
      // V1 adı motor girdisidir. V2 adı yalnız görünüm bilgisidir.
      _candidate = candidate.seedSurumu == 1
          ? candidate
          : candidate.copyWith(isim: name, dogumTarihi: birthDate);
      await ref.read(userRepositoryProvider).kaydet(_candidate!);
      if (_disposed) return false;
      state = ProfileFormState(
        name: state.name,
        birthDate: birthDate,
        legacy: legacy,
      );
      return true;
    } catch (_) {
      if (_disposed) return false;
      state = ProfileFormState(
        name: state.name,
        birthDate: birthDate,
        failed: true,
        legacy: legacy,
      );
      return false;
    }
  }
}

/// Taslak karşılamaya geri dönüşte yaşar; kapanış sonrası yalnız kayıt kalır.
final NotifierProvider<ProfileFormController, ProfileFormState>
profileFormProvider = NotifierProvider<ProfileFormController, ProfileFormState>(
  ProfileFormController.new,
);
