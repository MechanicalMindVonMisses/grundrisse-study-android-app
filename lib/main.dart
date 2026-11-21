import 'package:material_ui/material_ui.dart';

import 'data.dart';
import 'nav.dart';
import 'screens/curriculum.dart';
import 'screens/glossary.dart';
import 'screens/home.dart';
import 'screens/labs.dart';
import 'screens/library.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([Course.load(), store.load()]);
  runApp(const GrundrisseStudyApp());
}

class GrundrisseStudyApp extends StatelessWidget {
  const GrundrisseStudyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Grundrisse Study',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const Shell(),
      );
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.color = C.ink});
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (h, c) in [(22.0, color), (17.0, C.coral), (26.0, color)])
                Container(width: 6, height: h, margin: const EdgeInsets.only(right: 2), color: c),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GRUNDRISSE', style: display(16, weight: 700, color: color, height: 1, spacing: 0.6)),
              const SizedBox(height: 3),
              Text('STUDY EDITION', style: mono(8, color: color, spacing: 1.5, height: 1)),
            ],
          ),
        ],
      );
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  static const _screens = [
    HomeScreen(),
    CurriculumScreen(),
    LibraryScreen(),
    LabsScreen(),
    GlossaryScreen(),
  ];

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: AppNav.tab,
        builder: (context, tab, _) => PopScope(
          canPop: tab == AppNav.home,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) AppNav.tab.value = AppNav.home;
          },
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 20,
              title: const Brand(),
              actions: [
                ListenableBuilder(
                  listenable: store,
                  builder: (context, _) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Center(
                      child: Text(
                        '${store.completedCount}/${course.lessons.length}',
                        style: mono(12, color: C.muted),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'My notebook',
                  icon: const Icon(Icons.edit_note, size: 26),
                  onPressed: () => AppNav.openNotebook(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: IndexedStack(index: tab, children: _screens),
            bottomNavigationBar: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: C.lineSoft)),
              ),
              child: NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: (index) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  AppNav.tab.value = index;
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Start'),
                  NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Curriculum'),
                  NavigationDestination(icon: Icon(Icons.local_library_outlined), selectedIcon: Icon(Icons.local_library), label: 'Library'),
                  NavigationDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science), label: 'Labs'),
                  NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Glossary'),
                ],
              ),
            ),
          ),
        ),
      );
}
