import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';

final remoteDataSourceProvider = Provider((ref) => RemoteDataSource());

final userRepositoryProvider = Provider((ref) =>
    UserRepositoryImpl(ref.read(remoteDataSourceProvider)));

class UsersNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepositoryImpl repository;
  BuildContext? _context;

  UsersNotifier(this.repository) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  // Set context for image precaching
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> fetchUsers() async {
    // Don't show loading if we already have data (for refresh)
    if (state.hasValue) {
      state = AsyncValue.data(state.value!);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      final users = await repository.fetchUsers();
      
      // Prefetch all images immediately
      if (_context != null && _context!.mounted) {
        await _prefetchAllImages(users, _context!);
      }
      
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Prefetch all images to cache
  Future<void> _prefetchAllImages(List<User> users, BuildContext context) async {
    try {
      // Create a list of futures for parallel image loading
      final precacheFutures = users.map((user) {
        return precacheImage(
          CachedNetworkImageProvider(
            user.pictureUrl,
            maxWidth: 600,
            maxHeight: 800,
          ),
          context,
        ).catchError((error) {
          // Ignore individual image errors
          debugPrint('Failed to precache image for ${user.fullName}: $error');
        });
      }).toList();

      // Wait for all images to be cached (with timeout)
      await Future.wait(precacheFutures).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Image precaching timed out');
          return <void>[]; // Return an empty list to satisfy the return type
        },
      );
      
      debugPrint('✅ All ${users.length} images prefetched successfully!');
    } catch (e) {
      debugPrint('Error prefetching images: $e');
    }
  }

  void toggleLike(String userId) {
    state.whenData((users) {
      final updatedUsers = users.map((user) {
        if (user.id == userId) {
          user.isLiked = !user.isLiked;
        }
        return user;
      }).toList();
      state = AsyncValue.data(updatedUsers);
    });
  }
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<User>>>((ref) {
  return UsersNotifier(ref.read(userRepositoryProvider));
});
