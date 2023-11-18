import 'package:cached_annotation/cached_annotation.dart';

part 'blur_hash_cache.cached.dart';

@WithCache()
abstract mixin class BlurHashRepository implements _$BlurHashRepository {
  factory BlurHashRepository() = _BlurHashRepository;

  @clearAllCached
  void clearAllData();
}
