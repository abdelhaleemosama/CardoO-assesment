import 'package:flutter/material.dart';

import 'features/readings/presentation/history_page.dart';
import 'features/readings/presentation/home_page.dart';

class CardoOApp extends StatelessWidget {
  const CardoOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardoO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const _Shell(),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [HomePage(), HistoryPage()];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Live'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'History'),
        ],
      ),
    );
  }
}
