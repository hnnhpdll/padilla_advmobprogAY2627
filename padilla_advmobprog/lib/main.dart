import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  //runs the StateManagementActivity and provides the ThemeModel
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const StateManagementActivity(),
    ),
  );
}

// Main app wrapper (connects app to the material design system)
class StateManagementActivity extends StatelessWidget {
  const StateManagementActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

// App State Management using Provider
//  uses ChangeNotifier so that widgets can be updated when the theme changes
class ThemeModel with ChangeNotifier {

  // false = Light Mode
  // true = Dark Mode

  bool _isDark = false;

  bool get isDark => _isDark;

// Changes the theme from light to dark or dark to light.
  // notifyListeners() tells Provider that the state has changed

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// Root Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'State Management Activity',

 // Changes the entire application theme depending on isDark value
      theme: themeModel.isDark
          ? ThemeData.dark()
          : ThemeData.light(),

 // The first screen shown when the app starts.
      home: const CounterScreen(),
    );
  }
}


// ===============================
// SCREEN 1: COUNTER SCREEN
// Ephemeral State Management
// ===============================

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {

  // Local state (Ephemeral State) This value is temporary and exists only while this widget is active.
  int _counter = 0;


//  Function that increases the counter value.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

// Builds the user interface for the Counter Screen.
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Screen'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              'You have pushed the button this many times:',
            ),
 // Displays the current counter value.
            Text(
              '$_counter',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),


            const SizedBox(height: 30),


            ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ThemeScreen(),
                  ),
                );

              },

              child: const Text(
                'Go to Theme Settings',
              ),
            ),

          ],
        ),
      ),

// Floating button that triggers the counter update
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,

        tooltip: 'Increment',

        child: const Icon(Icons.add),
      ),
    );
  }
}




// ===============================
// SCREEN 2: THEME SCREEN
// App State Management
// ===============================

class ThemeScreen extends StatelessWidget {

  const ThemeScreen({super.key});


  @override
  Widget build(BuildContext context) {

// Accesses the shared ThemeModel state.
    final themeModel =
        Provider.of<ThemeModel>(context);


    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Theme Toggle Screen',
        ),
      ),


      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,


          children: [

            const Text(
              'Toggle the theme:',
              style: TextStyle(
                fontSize: 20,
              ),
            ),

 // Switch changes the application theme.
            Switch(

              value: themeModel.isDark,

// Calls toggleTheme() when switched
              onChanged: (_) {

                themeModel.toggleTheme();

              },

            ),

 // Displays the current theme status.
            Text(

              themeModel.isDark
                  ? 'Dark Mode Enabled'
                  : 'Light Mode Enabled',

            ),

          ],
        ),
      ),
    );
  }
}