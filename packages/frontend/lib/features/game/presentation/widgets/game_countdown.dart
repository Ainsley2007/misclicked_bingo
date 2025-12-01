import 'dart:async';
import 'package:flutter/material.dart';

class GameCountdown extends StatefulWidget {
  const GameCountdown({
    required this.startTime,
    required this.endTime,
    this.onGameStarted,
    super.key,
  });

  final DateTime? startTime;
  final DateTime? endTime;
  final VoidCallback? onGameStarted;

  @override
  State<GameCountdown> createState() => _GameCountdownState();
}

class _GameCountdownState extends State<GameCountdown> {
  Timer? _timer;
  bool _hasStarted = true;
  bool _hasEnded = false;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateStatus() {
    final now = DateTime.now();
    final newHasStarted = widget.startTime == null || now.isAfter(widget.startTime!);
    final newHasEnded = widget.endTime != null && now.isAfter(widget.endTime!);

    if (!_hasStarted && newHasStarted) {
      widget.onGameStarted?.call();
    }

    Duration remaining = Duration.zero;
    if (!newHasStarted && widget.startTime != null) {
      remaining = widget.startTime!.difference(now);
    } else if (!newHasEnded && widget.endTime != null) {
      remaining = widget.endTime!.difference(now);
    }

    if (mounted) {
      setState(() {
        _hasStarted = newHasStarted;
        _hasEnded = newHasEnded;
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;

    final parts = <String>[];

    if (days > 7) {
      final weeks = days ~/ 7;
      final remainingDays = days % 7;
      parts.add('${weeks}w');
      if (remainingDays > 0) {
        parts.add('${remainingDays}d');
      }
    } else if (days > 0) {
      parts.add('${days}d');
      if (hours > 0) {
        parts.add('${hours}h');
      }
    } else if (hours > 0) {
      parts.add('${hours}h');
      if (minutes > 0) {
        parts.add('${minutes}m');
      }
    } else {
      parts.add('${minutes}m');
    }

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startTime == null && widget.endTime == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    // Game hasn't started yet - show warning style
    if (!_hasStarted && widget.startTime != null) {
      return _InlineCountdown(
        icon: Icons.schedule_rounded,
        label: 'Starts in',
        value: _formatDuration(_remaining),
        color: theme.colorScheme.error,
        isWarning: true,
      );
    }

    // Game has ended
    if (_hasEnded) {
      return _InlineCountdown(
        icon: Icons.check_circle_outline_rounded,
        label: 'Ended',
        value: null,
        color: theme.colorScheme.onSurfaceVariant,
        isWarning: false,
      );
    }

    // Game is in progress with end time
    if (widget.endTime != null) {
      return _InlineCountdown(
        icon: Icons.timer_outlined,
        label: 'Ends in',
        value: _formatDuration(_remaining),
        color: theme.colorScheme.onSurfaceVariant,
        isWarning: false,
      );
    }

    return const SizedBox.shrink();
  }
}

class _InlineCountdown extends StatelessWidget {
  const _InlineCountdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isWarning,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color color;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWarning ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isWarning ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value != null ? '$label $value' : label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: isWarning ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
