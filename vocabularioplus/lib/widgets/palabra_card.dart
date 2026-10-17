
import 'package:flutter/material.dart';
import '../models/palabra.dart';

class PalabraCard extends StatelessWidget {
  final Palabra palabra;
  final VoidCallback onTap;
  final VoidCallback onFavoritoTap;

  const PalabraCard({
    super.key,
    required this.palabra,
    required this.onTap,
    required this.onFavoritoTap,
  });

  String _etiquetaTipo(String tipo) {
    switch (tipo) {
      case 'sust':
        return 'sustantivo';
      case 'adj':
        return 'adjetivo';
      case 'verbo':
        return 'verbo';
      case 'adv':
        return 'adverbio';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          palabra.palabra,
                          style: TextStyle(
                            fontFamily: 'Bricolage Grotesque',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimaryContainer
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _etiquetaTipo(palabra.tipo),
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans',
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      palabra.significado,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavoritoTap,
                icon: Icon(
                  palabra.favorito ? Icons.star_rounded : Icons.star_border_rounded,
                  color: palabra.favorito 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}