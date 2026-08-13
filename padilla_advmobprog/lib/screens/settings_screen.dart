import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 3: Settings page
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ENHANCEMENT 3: Access the existing ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // ENHANCEMENT 3: Dark/Light mode setting
          Card(
            child: SwitchListTile(
              title: CustomText(
                text: 'Dark Mode',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),

              subtitle: CustomText(
                text: themeProvider.isDark
                    ? 'Dark theme is enabled'
                    : 'Light theme is enabled',
                fontSize: 13.sp,
              ),

              value: themeProvider.isDark,

              // ENHANCEMENT 3: Toggle the existing theme
              onChanged: (value) {
                context
                    .read<ThemeProvider>()
                    .toggleTheme();
              },

              secondary: Icon(
                themeProvider.isDark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
