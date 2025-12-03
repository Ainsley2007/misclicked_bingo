import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class LeaderboardWidget extends StatelessWidget {
  final ProofStats? stats;
  final bool isLoading;

  const LeaderboardWidget({
    this.stats,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stats == null || 
        (stats!.topProofUploaders.isEmpty && stats!.topTileCompleters.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No stats yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload proofs and complete tiles\nto see the leaderboard',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsOverview(context),
          const SizedBox(height: 16),
          if (stats!.topPointsContributors.isNotEmpty) ...[
            _LeaderboardCard(
              title: 'Top Points Contributors',
              icon: Icons.emoji_events,
              users: stats!.topPointsContributors,
              color: const Color(0xFFFFA000),
              suffix: 'pts',
            ),
            const SizedBox(height: 12),
          ],
          if (stats!.topProofUploaders.isNotEmpty) ...[
            _LeaderboardCard(
              title: 'Top Proof Uploaders',
              icon: Icons.upload_file,
              users: stats!.topProofUploaders,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
          ],
          if (stats!.topTileCompleters.isNotEmpty)
            _LeaderboardCard(
              title: 'Top Tile Completers',
              icon: Icons.check_circle,
              users: stats!.topTileCompleters,
              color: const Color(0xFF4CAF50),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPoints = stats!.totalPoints > 0;
    
    return Row(
      children: [
        if (hasPoints) ...[
          Expanded(
            child: _StatCard(
              icon: Icons.emoji_events,
              label: 'Points',
              value: stats!.totalPoints.toString(),
              color: const Color(0xFFFFA000),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: _StatCard(
            icon: Icons.upload_file,
            label: 'Proofs',
            value: stats!.totalProofs.toString(),
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            label: 'Completed',
            value: stats!.totalCompletions.toString(),
            color: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<UserStats> users;
  final Color color;
  final String? suffix;

  const _LeaderboardCard({
    required this.title,
    required this.icon,
    required this.users,
    required this.color,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...users.asMap().entries.map((entry) => _LeaderboardRow(
              rank: entry.key + 1,
              user: entry.value,
              color: color,
              suffix: suffix,
            )),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final UserStats user;
  final Color color;
  final String? suffix;

  const _LeaderboardRow({
    required this.rank,
    required this.user,
    required this.color,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTopThree = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isTopThree
            ? color.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: isTopThree 
            ? Border.all(color: color.withValues(alpha: 0.2))
            : Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                _getRankDisplay(rank),
                style: TextStyle(
                  fontSize: isTopThree ? 18 : 13,
                  fontWeight: isTopThree ? FontWeight.bold : FontWeight.w500,
                  color: isTopThree ? null : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (user.avatar != null) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                'https://cdn.discordapp.com/avatars/${user.userId}/${user.avatar}.png?size=64',
              ),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 10),
          ] else ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                (user.username ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              user.username ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTopThree ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              suffix != null ? '${user.count} $suffix' : user.count.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRankDisplay(int rank) {
    return switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#$rank',
    };
  }
}

