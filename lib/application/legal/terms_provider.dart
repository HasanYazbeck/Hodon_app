import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../providers.dart';

class ParentTermsAcceptanceNotifier extends StateNotifier<AsyncValue<bool>> {
  ParentTermsAcceptanceNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue.data(false);
      return;
    }

    try {
      final accepted = await _ref
          .read(secureStorageProvider)
          .hasAcceptedParentBookingTerms(user.id);
      state = AsyncValue.data(accepted);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> isAccepted() async {
    final current = state.valueOrNull;
    if (current != null) return current;
    await _load();
    return state.valueOrNull ?? false;
  }

  Future<void> accept() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    await _ref.read(secureStorageProvider).acceptParentBookingTerms(user.id);
    state = const AsyncValue.data(true);
  }
}

final parentTermsAcceptanceProvider =
    StateNotifierProvider<ParentTermsAcceptanceNotifier, AsyncValue<bool>>(
        (ref) {
  return ParentTermsAcceptanceNotifier(ref);
});
