import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Palette converted from the web edition's oklch tokens.
abstract final class C {
  static const paper = Color(0xFFF5EDDB);
  static const paperDeep = Color(0xFFECE1CC);
  static const raised = Color(0xFFFBF6EB);
  static const ink = Color(0xFF120F0C);
  static const muted = Color(0xFF544C43);
  static const coral = Color(0xFFD85C38);
  static const accentSoft = Color(0xFFF6C9B3);
  static const plum = Color(0xFF2E1F2E);
  static const forest = Color(0xFF144439);
  static const lineSoft = Color(0xFFC5B9A5);
  static const lineStrong = Color(0xFF433C33);
  static const error = Color(0xFFA82D2E);
}

FontWeight _nearest(double w) =>
    FontWeight.values[((w / 100).round() - 1).clamp(0, 8)];

/// Archivo — headings and interface labels.
TextStyle display(
  double size, {
  double weight = 560,
  Color color = C.ink,
  double? height,
  double? spacing,
}) =>
    TextStyle(
      fontFamily: 'Archivo',
      fontSize: size,
      fontWeight: _nearest(weight),
      fontVariations: [FontVariation('wght', weight)],
      color: color,
      height: height ?? 1.12,
      letterSpacing: spacing ?? (size >= 20 ? -0.035 * size : 0),
    );

/// Newsreader — running text.
TextStyle reading(
  double size, {
  double weight = 400,
  Color color = C.ink,
  double height = 1.6,
  bool italic = false,
}) =>
    TextStyle(
      fontFamily: 'Newsreader',
      fontSize: size,
      fontWeight: _nearest(weight),
      fontVariations: [FontVariation('wght', weight)],
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      color: color,
      height: height,
    );

/// IBM Plex Mono — eyebrows, counters, formulas.
TextStyle mono(
  double size, {
  Color color = C.ink,
  bool medium = false,
  double spacing = 0,
  double height = 1.45,
}) =>
    TextStyle(
      fontFamily: 'IBMPlexMono',
      fontSize: size,
      fontWeight: medium ? FontWeight.w500 : FontWeight.w400,
      color: color,
      letterSpacing: spacing,
      height: height,
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.coral,
    brightness: Brightness.light,
  ).copyWith(
    primary: C.ink,
    onPrimary: C.paper,
    secondary: C.coral,
    onSecondary: C.ink,
    surface: C.paper,
    onSurface: C.ink,
    error: C.error,
    outline: C.lineSoft,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.paper,
    fontFamily: 'Newsreader',
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      bodyLarge: reading(17),
      bodyMedium: reading(16),
      bodySmall: reading(14, color: C.muted),
      titleMedium: display(16, height: 1.25),
      labelLarge: display(14, weight: 580, height: 1.25),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: C.paper,
      foregroundColor: C.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: display(15, weight: 600, height: 1.2),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: C.raised,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      shape: const Border(bottom: BorderSide(color: C.lineSoft)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.raised,
      surfaceTintColor: Colors.transparent,
      indicatorColor: C.accentSoft,
      indicatorShape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => display(
          11,
          weight: states.contains(WidgetState.selected) ? 650 : 500,
          color: states.contains(WidgetState.selected) ? C.ink : C.muted,
          height: 1.2,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? C.ink : C.muted,
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 2,
      activeTrackColor: C.ink,
      inactiveTrackColor: C.lineSoft,
      thumbColor: C.coral,
      overlayColor: Color(0x22D85C38),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
      trackShape: RectangularSliderTrackShape(),
    ),
    dividerTheme: const DividerThemeData(color: C.lineSoft, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.ink,
      contentTextStyle: display(13, color: C.paper, height: 1.3),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(),
    ),
  );
}

const pagePadding = EdgeInsets.symmetric(horizontal: 20);

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = C.ink, this.bottom = 12});
  final String text;
  final Color color;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Text(text.toUpperCase(), style: mono(11, color: color, spacing: 1.05)),
      );
}

/// Page heading with an optional serif-italic second part, as on the web.
class PageTitle extends StatelessWidget {
  const PageTitle(this.plain, this.emphasis, {super.key, this.size = 40, this.color = C.ink});
  final String plain;
  final String emphasis;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          text: plain,
          children: [
            TextSpan(
              text: emphasis,
              style: reading(size * 1.04, weight: 430, italic: true, color: color, height: 1.02)
                  .copyWith(letterSpacing: -0.04 * size),
            ),
          ],
        ),
        style: display(size, color: color, height: 1.02),
      );
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.eyebrow,
    required this.plain,
    required this.emphasis,
    required this.body,
    this.trailing,
  });
  final String eyebrow;
  final String plain;
  final String emphasis;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(eyebrow),
            PageTitle(plain, emphasis),
            const SizedBox(height: 18),
            Text(body, style: reading(16.5, color: C.muted, height: 1.55)),
            if (trailing != null) ...[const SizedBox(height: 16), trailing!],
          ],
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onPressed, this.icon, this.leading, this.expand = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? leading;
  final bool expand;

  @override
  Widget build(BuildContext context) => _Btn(
        label: label,
        onPressed: onPressed,
        icon: icon,
        leading: leading,
        expand: expand,
        background: C.ink,
        foreground: C.paper,
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, this.onPressed, this.icon, this.leading, this.expand = false, this.foreground = C.ink});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? leading;
  final bool expand;
  final Color foreground;

  @override
  Widget build(BuildContext context) => _Btn(
        label: label,
        onPressed: onPressed,
        icon: icon,
        leading: leading,
        expand: expand,
        background: Colors.transparent,
        foreground: foreground,
      );
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.leading,
    required this.expand,
    required this.background,
    required this.foreground,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? leading;
  final bool expand;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: foreground == C.paper ? C.ink : foreground),
          borderRadius: BorderRadius.circular(1),
        ),
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    Icon(leading, size: 18, color: foreground),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: display(14, weight: 580, color: foreground, height: 1.25),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 10),
                    Icon(icon, size: 18, color: foreground),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UnderlinedLink extends StatelessWidget {
  const UnderlinedLink(this.label, {super.key, required this.onTap, this.icon, this.color = C.ink});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 3),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: color)),
                  ),
                  child: Text(label, style: display(14, weight: 550, color: color, height: 1.25)),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 16, color: color),
              ],
            ],
          ),
        ),
      );
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.hint, required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: display(15, weight: 450, height: 1.3),
        cursorColor: C.coral,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: display(15, weight: 400, color: C.muted, height: 1.3),
          prefixIcon: const Icon(Icons.search, size: 20, color: C.muted),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close, size: 18, color: C.muted),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: C.raised,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: C.lineSoft),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: C.ink, width: 1.5),
          ),
        ),
      );
}

class FilterChips extends StatelessWidget {
  const FilterChips({super.key, required this.items, required this.selected, required this.onSelected});
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: pagePadding,
        child: Row(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: item == selected ? C.ink : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: item == selected ? C.ink : C.lineSoft),
                  ),
                  child: InkWell(
                    onTap: () => onSelected(item),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        item,
                        style: display(13, weight: 550, color: item == selected ? C.paper : C.ink, height: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class ProgressLine extends StatelessWidget {
  const ProgressLine(this.fraction, {super.key, this.height = 4, this.color = C.coral, this.track = C.lineSoft});
  final double fraction;
  final double height;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        color: track,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body, this.action, this.icon});
  final String title;
  final String body;
  final Widget? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(border: Border.all(color: C.lineSoft)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[Icon(icon, size: 26, color: C.muted), const SizedBox(height: 12)],
            Text(title, style: display(22)),
            const SizedBox(height: 8),
            Text(body, style: reading(15.5, color: C.muted, height: 1.5)),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      );
}

/// Opens a primary-source link in the browser. The texts themselves live on
/// the Marx/Engels Internet Archive, so this is the one thing that needs a
/// connection.
Future<void> openUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(const SnackBar(
      content: Text('Could not open the link. Source texts need a browser and an internet connection.'),
    ));
  }
}
