import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palabras_provider.dart';
import '../widgets/palabra_card.dart';
import 'editar_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mis palabras',
                      style: TextStyle(
                        fontFamily: 'Bricolage Grotesque',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.onSurface
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (valor) => context.read<PalabrasProvider>().buscar(valor),
                decoration: InputDecoration(
                  hintText: 'Buscar palabra o significado',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondaryContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<PalabrasProvider>(
                builder: (context, provider, _) => Row(
                  children: [
                    _FiltroChip(
                      label: 'Todas',
                      activo: provider.filtro == FiltroPalabras.todas,
                      onTap: () => provider.filtrar(FiltroPalabras.todas),
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'Recientes',
                      activo: provider.filtro == FiltroPalabras.recientes,
                      onTap: () => provider.filtrar(FiltroPalabras.recientes),
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'Favoritas',
                      activo: provider.filtro == FiltroPalabras.favoritas,
                      onTap: () => provider.filtrar(FiltroPalabras.favoritas),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<PalabrasProvider>(
                builder: (context, provider, _) {
                  if (provider.cargando && provider.palabras.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(child: Text(provider.error!));
                  }

                  final palabras = provider.palabras;

                  if (palabras.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No hay palabras que coincidan. Agrega una nueva con el botón +.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'IBM Plex Sans', color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: palabras.length,
                    itemBuilder: (context, index) {
                      final palabra = palabras[index];
                      return PalabraCard(
                        palabra: palabra,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EditarScreen(palabra: palabra)),
                        ),
                        onFavoritoTap: () => provider.alternarFavorito(palabra),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditarScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Agregar palabra'),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroChip({required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? const Color(0xFF0E6B5C) : Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: activo 
              ? Theme.of(context).colorScheme.onPrimaryContainer 
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 80),
          ),
        ),
      ),
    );
  }
}