import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  bool _isArabic = true; // Default to Arabic now

  bool get isArabic => _isArabic;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isArabic = prefs.getBool('isArabic') ?? true;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _isArabic = !_isArabic;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isArabic', _isArabic);
  }

  // Very simple localization
  String get title => '85';
  String get tabLive => _isArabic ? 'مباشر' : 'Live';
  String get tabAll => _isArabic ? 'كل المباريات' : 'All Matches';
  String get today => _isArabic ? 'اليوم' : 'TODAY';
  String get noMatches => _isArabic ? 'لا توجد مباريات متاحة' : 'No matches available';
  String get filterTitle => _isArabic ? 'اختر دورياتك المفضلة' : 'Select Your Leagues';
  String get filterDesc => _isArabic ? 'اختر الدوريات التي تريد متابعتها. إذا لم تختر شيئاً، ستعرض جميع المباريات.' : 'Choose the leagues you want to follow. If none are selected, all matches will be shown.';
  String get filterEmpty => _isArabic ? 'لم يتم العثور على دوريات. حاول تحديث المباريات.' : 'No leagues found. Try refreshing matches first.';
  
  // Onboarding Strings
  String get welcomeTitle => 'Welcome to 85';
  String get welcomeDesc => _isArabic ? 'التطبيق الأسرع لمتابعة كرة القدم.' : 'The fastest app to follow football.';
  String get selectLeaguesTitle => _isArabic ? 'ما هي دورياتك المفضلة؟' : 'What are your favorite leagues?';
  String get selectTeamsTitle => _isArabic ? 'ما هي فرقك المفضلة؟' : 'What are your favorite teams?';
  String get btnContinue => _isArabic ? 'متابعة' : 'Continue';
  String get btnFinish => _isArabic ? 'ابدأ الآن' : 'Start Now';
  String get btnSkip => _isArabic ? 'تخطي' : 'Skip';

  // Match Details Strings
  String get tabTimeline => _isArabic ? 'خط الزمن' : 'Timeline';
  String get tabLineups => _isArabic ? 'التشكيلة' : 'Lineups';
  String get tabStats => _isArabic ? 'إحصائيات' : 'Stats';

  // Bottom Nav
  String get navMatches => _isArabic ? 'المباريات' : 'Matches';
  String get navLeagues => _isArabic ? 'البطولات' : 'Leagues';
  String get navProfile => _isArabic ? 'حسابي' : 'Profile';
}
