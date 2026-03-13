import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leksis/data/notifiers.dart';
import 'package:leksis/theme/app_styles.dart';
import 'package:leksis/views/widgets/language_selector_widget.dart';
import 'package:leksis/views/pages/stats_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({
    super.key,

    required this.currentLocale,

    required this.onLocaleChange,
  });

  final Locale currentLocale;
  final Function(Locale) onLocaleChange;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,

      builder: (BuildContext context, ThemeMode themeMode, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: GoogleFonts.philosopher(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: Container(
            decoration: BoxDecoration(
              gradient: AppStyles.pageGradient(context),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  _buildSettingItem(
                    context,
                    title: loc.changeLanguage,
                    icon: Icons.language_rounded,
                    child: LanguageSelector(
                      currentLocale: currentLocale,
                      onLocaleChange: onLocaleChange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    context,
                    title: AppLocalizations.of(context)!.modus,
                    icon: Icons.dark_mode_rounded,
                    child: _buildThemeSelector(context, themeMode),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: themeColorNotifier,
                    builder: (context, themeColor, child) {
                      return _buildSettingItem(
                        context,
                        title: loc.accentColor,
                        icon: Icons.palette_rounded,
                        child: _buildColorSelector(context, themeColor),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildActivityButton(context),
                  const SizedBox(height: 16),
                  _buildAboutButton(context),
                  const SizedBox(height: 16),
                ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1, end: 0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityButton(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatsPage()),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.activityAndProgress,
                style: GoogleFonts.firaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Icon(
                Icons.bar_chart_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutButton(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () => _showAboutDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.aboutTheApp,
                style: GoogleFonts.firaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 40,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.aboutTitle,
                    style: GoogleFonts.philosopher(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.aboutContent1,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.aboutContent2,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse('https://play.google.com/store/apps/details?id=com.cyprien.leksis');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.star_rounded, color: Colors.amber),
                      label: Text(loc.rateOnPlayStore),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.firaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeMode themeMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(8),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          value: themeMode,
          icon: Icon(
            Icons.arrow_drop_down,
            size: 28,
            color: Theme.of(context).colorScheme.secondary,
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),

          onChanged: (ThemeMode? newThemeMode) {
            if (newThemeMode != null) {
              themeModeNotifier.value = newThemeMode;

              saveThemeMode(newThemeMode);
            }
          },

          items: ThemeMode.values.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      mode == ThemeMode.system
                          ? Icons.brightness_auto
                          : mode == ThemeMode.light
                          ? Icons.wb_sunny
                          : Icons.nightlight_round,

                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mode == ThemeMode.system
                          ? AppLocalizations.of(context)!.system
                          : mode == ThemeMode.light
                          ? AppLocalizations.of(context)!.light
                          : AppLocalizations.of(context)!.dark,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColorSelector(BuildContext context, String currentThemeColor) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentThemeColor,
          icon: Icon(
            Icons.arrow_drop_down,
            size: 28,
            color: Theme.of(context).colorScheme.secondary,
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onChanged: (String? newColor) {
            if (newColor != null) {
              saveThemeColor(newColor);
            }
          },
          items: [
            _buildColorDropdownItem(context, 'default', loc.defaultColor, Icons.settings_brightness),
            _buildColorDropdownItem(context, 'indigo', loc.indigo, Icons.circle, color: Colors.indigo),
            _buildColorDropdownItem(context, 'rose', loc.rose, Icons.circle, color: Colors.pink),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildColorDropdownItem(
    BuildContext context,
    String value,
    String label,
    IconData icon, {
    Color? color,
  }) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.secondary, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
