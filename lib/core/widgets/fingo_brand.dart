import 'package:flutter/material.dart';

import '../theme/fingo_theme.dart';

/// Marca provisional autocontenida, fácil de sustituir por el logotipo final.
class FingoBrand extends StatelessWidget {
  const FingoBrand({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 58.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: FingoColors.primary,
            borderRadius: BorderRadius.circular(compact ? 10 : 17),
          ),
          child: Icon(
            Icons.auto_graph_rounded,
            color: Colors.white,
            size: compact ? 20 : 32,
          ),
        ),
        SizedBox(width: compact ? 9 : 12),
        Text(
          'FINGO',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
        ),
      ],
    );
  }
}
