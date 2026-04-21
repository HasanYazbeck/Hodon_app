import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/babysitter_profile.dart';
import '../../domain/models/models.dart';
import '../../data/repositories/interfaces/i_sitter_repository.dart';
import '../providers.dart';

// Search filter state
final sitterFilterProvider = StateProvider<SitterFilter>((ref) => const SitterFilter());

// Search results
class SitterSearchNotifier extends StateNotifier<AsyncValue<List<SitterCard>>> {
  SitterSearchNotifier(this._repo) : super(const AsyncValue.loading());

  final ISitterRepository _repo;
  int _page = 0;
  bool _hasMore = true;
  List<SitterCard> _items = [];
  SitterFilter _filter = const SitterFilter();

  Future<void> search({
    required double lat,
    required double lng,
    SitterFilter? filter,
    bool reset = false,
  }) async {
    if (filter != null) _filter = filter;
    if (reset) {
      _page = 0;
      _items = [];
      _hasMore = true;
    }
    if (!_hasMore) return;

    state = _page == 0
        ? const AsyncValue.loading()
        : AsyncValue.data(List.unmodifiable(_items));

    try {
      final results = await _repo.searchSitters(
        latitude: lat,
        longitude: lng,
        filter: _filter,
        page: _page,
        pageSize: 10,
      );
      _items = [..._items, ...results];
      _hasMore = results.length == 10;
      _page++;
      state = AsyncValue.data(List.unmodifiable(_items));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final sitterSearchProvider =
    StateNotifierProvider<SitterSearchNotifier, AsyncValue<List<SitterCard>>>((ref) {
  return SitterSearchNotifier(ref.watch(sitterRepositoryProvider));
});

// Single sitter detail
final sitterDetailProvider =
    FutureProvider.family<SitterCard, String>((ref, sitterId) async {
  return ref.watch(sitterRepositoryProvider).getSitterDetail(sitterId);
});

// Sitter reviews
final sitterReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, sitterId) async {
  return ref.watch(sitterRepositoryProvider).getSitterReviews(sitterId);
});

