import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/palabra.dart';
import '../providers/palabras_provider.dart';

class EditarScreen extends StatefulWidget {
  final Palabra? palabra;

  const EditarScreen({super.key, this.palabra});

  @override
  State<EditarScreen> createState() => _EditarScreenState();
}

class _EditarScreenState extends State<EditarScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _palabraController;
  late final TextEditingController _significadoController;
  late final TextEditingController _ejemploController;

  late String _tipo;
  late bool _incluirNotificaciones;
  bool _guardando = false;

  bool get _esEdicion => widget.palabra != null;

  static const _tipos = {
    'sust': 'Sustantivo',
    'adj': 'Adjetivo',
    'verbo': 'Verbo',
    'adv': 'Adverbio',
  };

  @override
  void initState() {
    super.initState();
    final p = widget.palabra;
    _palabraController = TextEditingController(text: p?.palabra ?? '');
    _significadoController = TextEditingController(text: p?.significado ?? '');
    _ejemploController = TextEditingController(text: p?.ejemplo ?? '');
    _tipo = p?.tipo ?? 'sust';
    _incluirNotificaciones = p?.incluirNotificaciones ?? true;
  }

  @override
  void dispose() {
    _palabraController.dispose();
    _significadoController.dispose();
    _ejemploController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final provider = context.read<PalabrasProvider>();

    final palabra = Palabra(
      id: widget.palabra?.id,
      palabra: _palabraController.text.trim(),
      tipo: _tipo,
      significado: _significadoController.text.trim(),
      ejemplo: _ejemploController.text.trim().isEmpty ? null : _ejemploController.text.trim(),
      favorito: widget.palabra?.favorito ?? false,
      incluirNotificaciones: _incluirNotificaciones,
      fechaCrea: widget.palabra?.fechaCreacion,
      vecesVista: widget.palabra?.vecesVista ?? 0,
    );

    if (_esEdicion) {
      await provider.editar(palabra);
    } else {
      await provider.agregar(palabra);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _eliminar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar palabra'),
        content: Text('¿Seguro que quieres eliminar "${widget.palabra!.palabra}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      await context.read<PalabrasProvider>().eliminar(widget.palabra!.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          _esEdicion ? 'Editar palabra' : 'Nueva palabra',
          style: TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _palabraController,
              decoration: _decoracion('Palabra'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'La palabra es obligatoria' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: _decoracion('Tipo gramatical'),
              items: _tipos.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _significadoController,
              decoration: _decoracion('Significado'),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El significado es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ejemploController,
              decoration: _decoracion('Ejemplo de uso (opcional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Incluir en notificaciones',
                style: TextStyle(fontFamily: 'IBM Plex Sans', fontWeight: FontWeight.w500),
              ),
              value: _incluirNotificaciones,
              activeThumbColor: const Color(0xFF0E6B5C),
              onChanged: (v) => setState(() => _incluirNotificaciones = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _guardando ? null : _guardar,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0E6B5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
            if (_esEdicion) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _eliminar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Eliminar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracion(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondaryContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}