import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leksis/l10n/l10n.dart';
import 'package:leksis/service/rating_service.dart';
import 'package:leksis/views/widgets/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import 'package:leksis/theme/theme.dart';
import 'package:leksis/views/widget_tree.dart';
import 'package:leksis/data/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadThemeMode();
  runApp(ProviderScope(child: LeksisApp()));
}

class LeksisApp extends StatefulWidget {
  const LeksisApp({super.key});

  @override
  State<LeksisApp> createState() => _LeksisAppState();
}

class _LeksisAppState extends State<LeksisApp> {
  Locale? _locale;
  final RatingService _ratingService = RatingService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Check for rating after app is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForRating();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_locale == null) {
      _setDefaultLocale();
    }
  }

  Future<void> _setDefaultLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString('selected_locale');
    Locale newLocale;

    if (savedLocaleCode != null) {
      final parts = savedLocaleCode.split('_');
      newLocale = parts.length > 1
          ? Locale(parts[0], parts[1])
          : Locale(parts[0]);
    } else {
      final deviceLocale = _getDeviceLocale();

      final supportedLocales = L10n.allLanguages;

      final isSupported = supportedLocales.any(
        (locale) => locale.languageCode == deviceLocale.languageCode,
      );

      newLocale = isSupported ? deviceLocale : const Locale('en');
    }

    setState(() {
      _locale = newLocale;
    });
  }

  void _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();

    final localeCode = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await prefs.setString('selected_locale', localeCode);

    setState(() {
      _locale = locale;
    });
  }

  Locale _getDeviceLocale() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final systemLocales = platformDispatcher.locales;
    return systemLocales.isNotEmpty ? systemLocales.first : const Locale('en');
  }

  Future<void> _checkForRating() async {
    // Wait for app to be fully loaded and user to have some experience
    await Future.delayed(const Duration(seconds: 5));

    // Use the real service check with proper conditions
    if (await _ratingService.shouldShowRating() && mounted) {
      _showRatingDialog();
    }
  }

  Future<void> _launchStore() async {
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.cyprien.leksis');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Play Store')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: themeColorNotifier,
          builder: (context, themeColor, child) {
            ColorScheme lightScheme;
            ColorScheme darkScheme;

            switch (themeColor) {
              case 'indigo':
                lightScheme = MaterialTheme.indigoLightScheme();
                darkScheme = MaterialTheme.indigoDarkScheme();
                break;
              case 'rose':
                lightScheme = MaterialTheme.roseLightScheme();
                darkScheme = MaterialTheme.roseDarkScheme();
                break;
              default:
                lightScheme = MaterialTheme.lightScheme();
                darkScheme = MaterialTheme.darkScheme();
            }

            return MaterialApp(
              navigatorKey: _navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Leksis',
              theme: MaterialTheme(ThemeData.light().textTheme).theme(lightScheme),
              darkTheme: MaterialTheme(ThemeData.dark().textTheme).theme(darkScheme),
              scrollBehavior: const MaterialScrollBehavior(),
              themeMode: themeMode,
              supportedLocales: L10n.allLanguages,
              locale: _locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: WidgetTree(
                currentLocale: _locale ?? const Locale('en'),
                onLocaleChange: _setLocale,
              ),
            );
          },
        );
      },
    );
  }

  void _showRatingDialog() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        onRated: () {
          Navigator.pop(context);
          _ratingService.setRated();
          _launchStore();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.thankYou)),
            );
          }
        },
        onLater: () {
          Navigator.pop(context);
          _ratingService.setLater();
        },
      ),
    );
  }
}
