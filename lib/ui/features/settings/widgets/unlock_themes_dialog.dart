import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:queens/domain/models/app_settings.dart';
import 'package:queens/ui/providers.dart';

class UnlockThemesDialog extends ConsumerStatefulWidget {
  const UnlockThemesDialog({
    super.key,
    this.targetPreset,
    this.targetCrownSkin,
  });

  final AppThemePreset? targetPreset;
  final CrownSkin? targetCrownSkin;

  static Future<void> show(
    BuildContext context, {
    AppThemePreset? targetPreset,
    CrownSkin? targetCrownSkin,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => UnlockThemesDialog(
        targetPreset: targetPreset,
        targetCrownSkin: targetCrownSkin,
      ),
    );
  }

  @override
  ConsumerState<UnlockThemesDialog> createState() => _UnlockThemesDialogState();
}

class _UnlockThemesDialogState extends ConsumerState<UnlockThemesDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
  }

  Future<void> _handleUnlock() async {
    final code = _controller.text.trim().toLowerCase();
    if (code == 'thankyou') {
      HapticFeedback.mediumImpact();
      final success = await ref.read(settingsProvider.notifier).unlock(code);
      if (success) {
        if (widget.targetPreset != null) {
          await ref.read(settingsProvider.notifier).setTheme(widget.targetPreset!);
        }
        if (widget.targetCrownSkin != null) {
          await ref.read(settingsProvider.notifier).setCrownSkin(widget.targetCrownSkin!);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2027),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'UNLOCK THEME & SKINS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'UNLOCK ALL CUSTOM THEMES AND PREMIUM\nSTYLING OPTIONS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 13,
                    color: Color(0xFF8E92A0),
                    letterSpacing: 0.8,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _openUrl('https://buymeacoffee.com/sidhant947/e/574309');
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD600),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_cafe_rounded,
                            color: Colors.black,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'GET UNLOCK CODE',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF292B35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _hasError
                          ? const Color(0xFFFF5252)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _controller,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleUnlock(),
                    onChanged: (_) {
                      if (_hasError) {
                        setState(() => _hasError = false);
                      }
                    },
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'ENTER UNLOCK CODE',
                      hintStyle: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 15,
                        color: Color(0xFF656976),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                if (_hasError) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'INVALID UNLOCK CODE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 12,
                      color: Color(0xFFFF5252),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E92A0),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: _handleUnlock,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF76FF03),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'UNLOCK NOW',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
