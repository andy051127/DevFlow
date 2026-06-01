import 'package:flutter/material.dart';
import '../../domain/entities/routine.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final bool isCompleted;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.isCompleted,
    required this.streak,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(routine.color, radix: 16));

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Text(routine.icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          routine.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            if (streak > 0) ...[
              const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
              Text(
                ' $streak일',
                style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
              ),
              if (routine.goal != null) const Text('  ·  ', style: TextStyle(fontSize: 12)),
            ],
            if (routine.goal != null)
              Expanded(
                child: Text(routine.goal!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
