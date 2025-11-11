import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
  });

  final String nome;
  final String email;
  final String telefone;
  final String statusText;
  final Color statusColor;
  final VoidCallback onTap;

  String get _initials {
    final parts =
    nome.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    String first = parts.isNotEmpty ? parts.first[0] : '?';
    String last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                Theme.of(context).colorScheme.secondaryContainer,
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(statusText,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
