import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palabras_provider.dart';

class AleatoriaScreen extends StatefulWidget {
  const AleatoriaScreen({super.key});

  @override
  State<AleatoriaScreen> createState() => _AleatoriaScreenState();
}

class _AleatoriaScreenState extends State<AleatoriaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PalabrasProvider>().cargarPalabraAleatoria();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<PalabrasProvider>(
          builder: (context, provider, _) {
            final palabra = provider.palabraActual;

            if (palabra == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Todavía no tienes palabras registradas.\nAgrega algunas para empezar a repasar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans',
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              palabra.palabra,
                              style: TextStyle(
                                fontFamily: 'Bricolage Grotesque',
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                                color: Theme.of(context).colorScheme.onPrimaryContainer
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (!provider.revelada)
                              FilledButton(
                                onPressed: () => provider.revelarSignificado(),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Mostrar significado',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                                  ),
                              )
                            else ...[
                              Text(
                                palabra.significado,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                                ),
                              ),
                              if (palabra.ejemplo != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '"${palabra.ejemplo}"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.cargarPalabraAleatoria(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Otra palabra'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.revelada
                              ? () => provider.cargarPalabraAleatoria()
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Repasar después'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}