import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/user.dart';
import '../providers/users_provider.dart';
import '../screens/profile_detail_screen.dart';

class UserCard extends ConsumerStatefulWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<UserCard>
    with TickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _burstController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _burstAnimation;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();

    // Twitter-like scale animation
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_likeController);

    // Burst effect animation
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _burstController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _handleLike() {
    ref.read(usersProvider.notifier).toggleLike(widget.user.id);
    _likeController.forward().then((_) => _likeController.reverse());
    _burstController.forward().then((_) => _burstController.reset());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(user: widget.user),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - Now loads instantly from cache
            Expanded(
              child: Stack(
                children: [
                  _buildImage(),
                  // Like Button with Twitter Animation
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildLikeButton(),
                  ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.cake_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.user.age} years',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.user.city,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_imageError) {
      return _buildFallbackAvatar();
    }

    return Hero(
      tag: 'profile_${widget.user.id}',
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: CachedNetworkImage(
          imageUrl: widget.user.pictureUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          memCacheWidth: 600,
          memCacheHeight: 800,
          // No placeholder needed - images are already cached!
          fadeInDuration: Duration.zero, // Instant display
          fadeOutDuration: Duration.zero,
          errorWidget: (context, url, error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _imageError = true);
              }
            });
            return _buildFallbackAvatar();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Text(
          widget.user.firstName[0].toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: _handleLike,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Burst circles animation
            AnimatedBuilder(
              animation: _burstAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(32, 32),
                  painter: widget.user.isLiked
                      ? BurstPainter(_burstAnimation.value)
                      : null,
                );
              },
            ),
            // Heart icon with scale animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.user.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.user.isLiked ? Colors.red : Colors.grey[700],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for burst effect
class BurstPainter extends CustomPainter {
  final double progress;

  BurstPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity((1 - progress) * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw multiple expanding circles
    for (int i = 0; i < 3; i++) {
      final radius = maxRadius * progress * (1 + i * 0.3);
      canvas.drawCircle(center, radius, paint);
    }

    // Draw dots around the heart
    final dotPaint = Paint()
      ..color = Colors.red.withOpacity((1 - progress) * 0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final distance = maxRadius * progress * 1.5;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  double cos(double angle) => (angle * 180 / 3.14159).toDouble();
  double sin(double angle) => (angle * 180 / 3.14159).toDouble();

  @override
  bool shouldRepaint(BurstPainter oldDelegate) => progress != oldDelegate.progress;
}
