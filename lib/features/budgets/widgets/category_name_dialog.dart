import 'package:flutter/material.dart';

class CategoryNameDialog extends StatefulWidget {
  const CategoryNameDialog({super.key});

  @override
  State<CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<CategoryNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Añadir categoría'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLength: 100,
          decoration: const InputDecoration(labelText: 'Nombre'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      );
}
