import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_ui_preferences.dart';

typedef BarcodeAccepted = Future<bool> Function(String code);

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({
    super.key,
    this.onBarcode,
    this.title = 'مسح الباركود',
  });

  final BarcodeAccepted? onBarcode;
  final String title;

  bool get continuous => onBarcode != null;

  @override
  State<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState
    extends State<BarcodeScannerScreen> {
  final manualController = TextEditingController();
  final scannerController = MobileScannerController();

  String lastCode = '';
  int acceptedCount = 0;
  DateTime? lastDetectionAt;
  bool processing = false;

  bool get cameraSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void dispose() {
    manualController.dispose();
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleCode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty || processing) return;

    final now = DateTime.now();
    if (code == lastCode &&
        lastDetectionAt != null &&
        now.difference(lastDetectionAt!) <
            const Duration(milliseconds: 850)) {
      return;
    }

    processing = true;
    lastDetectionAt = now;

    var accepted = true;
    if (widget.onBarcode != null) {
      accepted = await widget.onBarcode!(code);
    }

    if (!mounted) return;

    if (accepted) {
      if (AppUiPreferences.instance.scannerSoundEnabled) {
        await SystemSound.play(SystemSoundType.click);
      }

      setState(() {
        lastCode = code;
        acceptedCount += 1;
      });

      if (!widget.continuous) {
        Navigator.of(context).pop<String>(code);
        return;
      }
    } else {
      setState(() => lastCode = code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الباركود غير مرتبط بصنف: $code'),
        ),
      );
    }

    processing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071E2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071E2F),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          if (cameraSupported)
            IconButton(
              tooltip: 'الفلاش',
              onPressed: scannerController.toggleTorch,
              icon: const Icon(Icons.flash_on_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: cameraSupported
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: scannerController,
                          onDetect: (capture) {
                            if (capture.barcodes.isEmpty) return;
                            final value =
                                capture.barcodes.first.rawValue;
                            if (value != null) {
                              _handleCode(value);
                            }
                          },
                        ),
                        const _ScannerFrame(),
                      ],
                    )
                  : _HardwareScannerPanel(
                      controller: manualController,
                      onSubmitted: _handleCode,
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.continuous
                              ? 'المسح المستمر مفعّل'
                              : 'وجّه الكاميرا نحو الباركود',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (widget.continuous)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius:
                                BorderRadius.circular(999),
                          ),
                          child: Text(
                            'تمت إضافة $acceptedCount',
                            style: const TextStyle(
                              color: AppColors.emeraldDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastCode.isEmpty
                        ? 'يمكنك مسح عدة أصناف متتالية، ويظل الماسح مفتوحًا حتى تغلقه يدويًا.'
                        : 'آخر باركود: $lastCode',
                    style: const TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                  if (widget.continuous) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('إنهاء المسح'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 270,
          height: 175,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              color: AppColors.emerald,
            ),
          ),
        ),
      ),
    );
  }
}

class _HardwareScannerPanel extends StatelessWidget {
  const _HardwareScannerPanel({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 86,
              ),
              const SizedBox(height: 18),
              const Text(
                'ماسح الباركود الخارجي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'في Windows استخدم قارئ USB/بلوتوث كلوحة مفاتيح ثم اضغط Enter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8CAD5),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  onSubmitted(value);
                  controller.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'امسح أو أدخل الباركود',
                  prefixIcon: Icon(Icons.barcode_reader),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
