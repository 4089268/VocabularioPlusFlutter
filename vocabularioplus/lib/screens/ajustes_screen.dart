import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ajustes_provider.dart';
import '../providers/palabras_provider.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  static const _opcionesFrecuencia = [1, 3, 5, 8];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<AjustesProvider>(
          builder: (context, ajustes, _) {
            if (ajustes.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            final p = ajustes.preferencias;
            final palabrasProvider = context.read<PalabrasProvider>();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Ajustes',
                  style: TextStyle(
                    fontFamily: 'Bricolage Grotesque',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurface
                  ),
                ),
                const SizedBox(height: 20),

                // Vista previa de la notificación
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.menu_book, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'efímero',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans',
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface
                              ),
                            ),
                            Text(
                              'Que dura poco tiempo',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans',
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _Seccion(
                  titulo: 'Notificaciones',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activar notificaciones', style: TextStyle(fontFamily: 'IBM Plex Sans')),
                    value: p.notificacionesActivas,
                    activeThumbColor: Theme.of(context).colorScheme.primaryContainer,
                    onChanged: (valor) async {
                      final concedido = await ajustes.activarNotificaciones(valor, palabrasProvider);
                      if (!concedido && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Necesitas conceder permisos de notificación')),
                        );
                      }
                    },
                  ),
                ),

                _Seccion(
                  titulo: 'Frecuencia diaria',
                  child: Wrap(
                    spacing: 8,
                    children: _opcionesFrecuencia.map((f) {
                      final activo = p.frecuenciaDiaria == f;
                      return ChoiceChip(
                        label: Text('$f×'),
                        selected: activo,
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          color: activo 
                            ? Theme.of(context).colorScheme.onPrimaryContainer 
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: .8)
                        ),
                        onSelected: (_) => ajustes.actualizarFrecuencia(f, palabrasProvider),
                      );
                    }).toList(),
                  ),
                ),

                _Seccion(
                  titulo: 'Rango horario',
                  child: Row(
                    children: [
                      Expanded(
                        child: _SelectorHora(
                          label: 'Desde',
                          hora: p.horaDesde,
                          onChanged: (h) => ajustes.actualizarHorario(h, p.horaHasta, palabrasProvider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SelectorHora(
                          label: 'Hasta',
                          hora: p.horaHasta,
                          onChanged: (h) => ajustes.actualizarHorario(p.horaDesde, h, palabrasProvider),
                        ),
                      ),
                    ],
                  ),
                ),

                _Seccion(
                  titulo: 'Preferencias',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Solo favoritas', style: TextStyle(fontFamily: 'IBM Plex Sans')),
                    value: p.soloFavoritas,
                    activeThumbColor: const Color(0xFF0E6B5C),
                    onChanged: (valor) => ajustes.actualizarSoloFavoritas(valor, palabrasProvider),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;

  const _Seccion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SelectorHora extends StatelessWidget {
  final String label;
  final int hora;
  final ValueChanged<int> onChanged;

  const _SelectorHora({required this.label, required this.hora, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final seleccionada = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hora, minute: 0),
        );
        if (seleccionada != null) onChanged(seleccionada.hour);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans',
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer
              )
            ),
            Text(
              '${hora.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer
              ),
            ),
          ],
        ),
      ),
    );
  }
}