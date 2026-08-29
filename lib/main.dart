import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/home_screen.dart';
import 'screens/newsfeed_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'constants.dart'; // Make sure you have your color constants here

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const PadillaFacebook());
}

class PadillaFacebook extends StatelessWidget {
  const PadillaFacebook({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Facebook Replication',
          theme: ThemeData(
            scaffoldBackgroundColor: FB_LIGHT_PRIMARY, 
            primaryColor: FB_PRIMARY,
            appBarTheme: const AppBarTheme(
              backgroundColor: FB_PRIMARY,
            ),
          ),
          initialRoute: '/splash',
          routes: {
            '/newsfeed': (context) => const NewsFeedScreen(),
            '/home': (context) => const HomeScreen(),
            '/login': (context) => LogInScreen(),
            '/register': (context) => RegisterScreen(),
            '/splash': (context) => SplashScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
