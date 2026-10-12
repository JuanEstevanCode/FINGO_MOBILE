import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/fingo_theme.dart';
import '../models/financial_movement.dart';
import '../services/movement_service.dart';
import '../widgets/movement_form.dart';

/// Pantalla principal: presenta el balance y los movimientos registrados.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Por ahora los movimientos se conservan en memoria durante la sesión.
  final MovementService _movementService = MovementService();

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    return '\$ $formattedInteger,${parts[1]}';
  }

  Future<void> _openMovementForm() async {
    final movement = await showModalBottomSheet<FinancialMovement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FingoColors.surface,
      builder: (_) => const MovementForm(),
    );

    if (movement == null || !mounted) return;

    setState(() {
      _movementService.addMovement(movement);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento registrado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movements = _movementService.movements;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FINGO',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.account_circle_outlined, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Hola, bienvenido',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Tus finanzas, más claras.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _buildBalanceCard(),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Movimientos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${movements.length} registros',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (movements.isEmpty)
              _buildEmptyState()
            else
              ...movements.map(_buildMovementTile),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openMovementForm,
                icon: const Icon(Icons.add),
                label: const Text('Registrar movimiento'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FingoColors.primary, Color(0xFF10543D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance disponible',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            _formatMoney(_movementService.balance),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.arrow_downward, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ingresos\n${_formatMoney(_movementService.totalIncome)}',
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gastos\n${_formatMoney(_movementService.totalExpenses)}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: FingoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FingoColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: FingoColors.accent,
          ),
          SizedBox(height: 12),
          Text(
            'Aún no tienes movimientos',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Registra tu primer ingreso o gasto para comenzar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: FingoColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _editMovement(FinancialMovement movement) async {
    final updatedMovement = await showModalBottomSheet<FinancialMovement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FingoColors.surface,
      builder: (_) => MovementForm(initialMovement: movement),
    );

    if (updatedMovement == null || !mounted) return;

    final updated = _movementService.updateMovement(movement, updatedMovement);

    if (!updated) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento actualizado correctamente')),
    );
  }

  Future<void> _confirmDeleteMovement(FinancialMovement movement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este movimiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleted = _movementService.deleteMovement(movement);

    if (!deleted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento eliminado correctamente')),
    );
  }

  Widget _buildMovementTile(FinancialMovement movement) {
    final isIncome = movement.type == MovementType.income;
    final color = isIncome ? FingoColors.income : FingoColors.expense;
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FingoColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FingoColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.south_west : Icons.north_east,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  movement.description.isEmpty
                      ? '${isIncome ? 'Ingreso' : 'Gasto'} · '
                            '${movement.date.day.toString().padLeft(2, '0')}/'
                            '${movement.date.month.toString().padLeft(2, '0')}/'
                            '${movement.date.year}'
                      : movement.description,
                  style: const TextStyle(
                    color: FingoColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${_formatMoney(movement.amount)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Acciones del movimiento',
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editMovement(movement);
                  } else if (value == 'delete') {
                    _confirmDeleteMovement(movement);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
