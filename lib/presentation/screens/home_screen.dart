import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profile_explore/domain/entities/user.dart';
import '../providers/users_provider.dart';
import '../widgets/user_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Set context for image prefetching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).setContext(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<User> _filterUsers(List<User> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }
    return users.where((user) {
      final nameLower = user.fullName.toLowerCase();
      final cityLower = user.city.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return nameLower.contains(searchLower) || cityLower.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile Explorer',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or city...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    usersAsync.when(
                      data: (users) => '${users.length}',
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    'Total Profiles',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    usersAsync.when(
                      data: (users) =>
                          '${users.where((u) => u.isLiked).length}',
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    'Favorites',
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(child: _buildContent(usersAsync)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AsyncValue<List<User>> usersAsync) {
    return RefreshIndicator(
      onRefresh: () => ref.read(usersProvider.notifier).fetchUsers(),
      child: usersAsync.when(
        data: (users) {
          final filteredUsers = _filterUsers(users);

          if (filteredUsers.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              return UserCard(
                key: ValueKey(filteredUsers[index].id),
                user: filteredUsers[index],
              );
            },
          );
        },
        loading: () => _buildLoadingWithMessage(),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildLoadingWithMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Loading Profiles...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'fetching images',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No profiles found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    String errorMessage = 'Unable to load profiles';
    String errorDetail = 'Please try again';
    IconData errorIcon = Icons.cloud_off_rounded;

    if (error.toString().contains('internet') ||
        error.toString().contains('network')) {
      errorMessage = 'No Internet Connection';
      errorDetail = 'Please check your network settings';
      errorIcon = Icons.wifi_off_rounded;
    } else if (error.toString().contains('timeout')) {
      errorMessage = 'Connection Timeout';
      errorDetail = 'Request took too long';
      errorIcon = Icons.timer_off_rounded;
    } else if (error.toString().contains('Server')) {
      errorMessage = 'Server Error';
      errorDetail = 'Our servers are having issues';
      errorIcon = Icons.dns_rounded;
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                errorIcon,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              Text(
                errorMessage,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorDetail,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(usersProvider.notifier).fetchUsers(),
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
