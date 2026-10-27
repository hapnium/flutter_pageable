import 'package:flutter/material.dart';

import 'screens/feed_screen.dart';
import 'screens/layouts_screen.dart';
import 'screens/sources_screen.dart';
import 'screens/toolkit_screen.dart';

void main() {
  runApp(const PageableShowcaseApp());
}

class PageableShowcaseApp extends StatelessWidget {
  const PageableShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_pageable showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157D5)),
        useMaterial3: true,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
      home: const ShowcaseHome(),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _selectedIndex = 0;

  static const _screens = [
    FeedScreen(),
    LayoutsScreen(),
    SourcesScreen(),
    ToolkitScreen(),
  ];

  static const _titles = [
    'Live feed',
    'View gallery',
    'Mixed sources',
    'Toolkit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'flutter_pageable',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Views',
          ),
          NavigationDestination(icon: Icon(Icons.merge_type), label: 'Sources'),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            label: 'Toolkit',
          ),
        ],
      ),
    );
  }
}
