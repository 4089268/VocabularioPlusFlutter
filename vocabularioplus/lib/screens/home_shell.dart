import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'aleatoria_screen.dart';
import 'ajustes_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  static const _pantallas = [
    MainScreen(),
    AleatoriaScreen(),
    AjustesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: _pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: 'Palabras',
          ),
          NavigationDestination(
            icon: const Icon(Icons.shuffle_outlined),
            selectedIcon: Icon(Icons.shuffle, color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: 'Aleatoria',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}