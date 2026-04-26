import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matches_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchesProvider = context.watch<MatchesProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, isDark, langProvider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(langProvider.isArabic ? "التنبيهات" : "Notifications"),
                  _buildSettingsTile(
                    icon: Icons.play_circle_outline,
                    title: langProvider.isArabic ? "بداية المباراة" : "Match Start",
                    subtitle: langProvider.isArabic ? "تنبيه عند انطلاق صافرة البداية" : "Get notified when the match begins",
                    trailing: Switch(
                      value: matchesProvider.notifyMatchStart,
                      onChanged: (_) => matchesProvider.toggleNotifyMatchStart(),
                      activeColor: Colors.blue,
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.sports_soccer,
                    title: langProvider.isArabic ? "الأهداف" : "Goals",
                    subtitle: langProvider.isArabic ? "تنبيه فوري عند تسجيل الأهداف" : "Instant alert when a goal is scored",
                    trailing: Switch(
                      value: matchesProvider.notifyGoals,
                      onChanged: (_) => matchesProvider.toggleNotifyGoals(),
                      activeColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(langProvider.isArabic ? "الإعدادات العامة" : "General Settings"),
                  _buildSettingsTile(
                    icon: Icons.dark_mode,
                    title: langProvider.isArabic ? "الوضع الداكن" : "Dark Mode",
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeColor: Colors.blue,
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: langProvider.isArabic ? "اللغة العربية" : "Arabic Language",
                    trailing: Switch(
                      value: langProvider.isArabic,
                      onChanged: (_) => langProvider.toggleLanguage(),
                      activeColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "Football 85 v1.2.0",
                      style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, LanguageProvider lang) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                  : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                lang.isArabic ? "مشجع كرة قدم" : "Football Fan",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: subtitle != null 
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))
            : null,
        trailing: trailing,
      ),
    );
  }
}
