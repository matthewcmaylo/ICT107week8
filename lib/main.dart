

import 'package:flutter/material.dart';

import 'screens/notes_screen.dart';

void main() {
  runApp(const MyApp());
}

// MyApp is a StatelessWidget — it describes part of the UI
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Header Body Footer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// HomePage is the main screen widget.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the standard visual layout structure:

    return Scaffold(

      
      // SECTION 1: HEADER
      // AppBar is Flutter's built-in header widget.
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0), //Header Colour Background Dark Blue
        centerTitle: true,
        title: const Text(
          'My first flutter app',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        // leading: icon on the LEFT side of the AppBar
        leading: const Icon(Icons.menu, color: Colors.white),
        // actions: icons on the RIGHT side of the AppBar
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),

  
      // SECTION 2: BODY
      body: Container(
        color: const Color(0xFFF5F5F5), // Light grey page background
        child: Column(
          children: [
            // --- Welcome Banner ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Flutter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Building cross-platform apps with Dart & Flutter.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Task 2 entry point: opens the SQLite CRUD screen.
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotesScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                    icon: const Icon(Icons.storage_outlined),
                    label: const Text('Open SQLite Notes (CRUD)'),
                  ),
                ],
              ),
            ),

            // --- Section Label ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Core Flutter Concepts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // --- Scrollable Info Cards ---
            // Expanded fills all remaining vertical space between banner and footer
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _bodyItems.length,
                itemBuilder: (context, index) {
                  final item = _bodyItems[index];
                  return _InfoCard(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    description: item['description'] as String,
                    color: item['color'] as Color,
                  );
                },
              ),
            ),
          ],
        ),
      ),


      // SECTION 3: FOOTER
      // BottomAppBar is pinned to the bottom of the screen.
      // It holds navigation icons/buttons.
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1565C0),
        elevation: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const _FooterButton(icon: Icons.home,     label: 'Home'),
              const _FooterButton(icon: Icons.search,   label: 'Search'),
              // Second entry point into the Task 2 SQLite CRUD screen.
              _FooterButton(
                icon: Icons.storage_outlined,
                label: 'SQLite',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotesScreen()),
                  );
                },
              ),
              const _FooterButton(icon: Icons.person, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// DATA: Content items displayed in the Body section
const List<Map<String, Object>> _bodyItems = [
  {
    'icon': Icons.widgets_outlined,
    'title': 'Widgets',
    'description': 'Everything in Flutter is a widget — buttons, text, layouts, and even the app itself.',
    'color': Color(0xFF1E88E5),
  },
  {
    'icon': Icons.account_tree_outlined,
    'title': 'Widget Tree',
    'description': 'Flutter builds the UI as a tree of nested widgets. Parent widgets control layout; children provide content.',
    'color': Color(0xFF43A047),
  },
  {
    'icon': Icons.layers_outlined,
    'title': 'Scaffold',
    'description': 'Scaffold provides the page structure: AppBar (header), body, and BottomAppBar (footer).',
    'color': Color(0xFFE53935),
  },
  {
    'icon': Icons.palette_outlined,
    'title': 'Material Design',
    'description': 'Flutter ships with Material 3 widgets out of the box — consistent, accessible, and themeable.',
    'color': Color(0xFF8E24AA),
  },
  {
    'icon': Icons.phone_android_outlined,
    'title': 'Cross-Platform',
    'description': 'One Dart codebase compiles to iOS, Android, Web, Windows, macOS, and Linux.',
    'color': Color(0xFFF4511E),
  },
];

// REUSABLE WIDGET: _InfoCard
// Custom card for displaying each concept in the body.

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular icon with accent colour background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// REUSABLE WIDGET: _FooterButton
// Single navigation button in the Footer bar.
class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _FooterButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
} //AI used with design ideas and help with customised widgets and icons.
