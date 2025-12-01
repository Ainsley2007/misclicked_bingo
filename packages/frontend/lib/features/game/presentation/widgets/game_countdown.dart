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

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
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

    if (mounted) {
      setState(() {
        _hasStarted = newHasStarted;
        _hasEnded = newHasEnded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startTime == null && widget.endTime == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();

    if (!_hasStarted && widget.startTime != null) {
      return _CountdownCard(
        targetTime: widget.startTime!,
        label: 'Game starts in',
        icon: Icons.play_circle_outline_rounded,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    if (_hasEnded) {
      return _StatusCard(
        label: 'Game has ended',
        icon: Icons.stop_circle_outlined,
        color: Theme.of(context).colorScheme.error,
      );
    }

    if (widget.endTime != null && now.isBefore(widget.endTime!)) {
      return _CountdownCard(
        targetTime: widget.endTime!,
        label: 'Game ends in',
        icon: Icons.timer_outlined,
        color: Theme.of(context).colorScheme.tertiary,
      );
    }

    return const SizedBox.shrink();
  }
}

class _CountdownCard extends StatefulWidget {
  const _CountdownCard({
    required this.targetTime,
    required this.label,
    required this.icon,
    required this.color,
  });

  final DateTime targetTime;
  final String label;
  final IconData icon;
  final Color color;

  @override
  State<_CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<_CountdownCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateRemaining();
    });
  }

  @override
  void didUpdateWidget(_CountdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _updateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    if (mounted) {
      setState(() {
        _remaining = widget.targetTime.difference(DateTime.now());
        if (_remaining.isNegative) {
          _remaining = Duration.zero;
        }
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
      parts.add('$weeks week${weeks > 1 ? 's' : ''}');
      if (remainingDays > 0) {
        parts.add('$remainingDays day${remainingDays > 1 ? 's' : ''}');
      }
    } else if (days > 0) {
      parts.add('$days day${days > 1 ? 's' : ''}');
      if (hours > 0) {
        parts.add('$hours hr${hours > 1 ? 's' : ''}');
      }
    } else if (hours > 0) {
      parts.add('$hours hr${hours > 1 ? 's' : ''}');
      if (minutes > 0) {
        parts.add('$minutes min');
      }
    } else {
      parts.add('$minutes min');
    }

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: widget.color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(_remaining),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

