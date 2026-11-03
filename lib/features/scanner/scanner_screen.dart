import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Kamerayla barkod okur ve `/product/:barcode` adresine yönlendirir.
/// Firebase'e dokunmaz; ürünü getirmek ProductScreen'in işi.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  // Kamerayı kendimiz başlatıp durduracağız (autoStart: false),
  // çünkü sekme değişince ve uygulama arka plana gidince kapatmamız lazım.
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  bool _tabActive = false; // Scanner sekmesi şu an görünür mü?
  bool _appResumed = true; // Uygulama ön planda mı?
  bool _handling = false; // Bir barkod işleniyor / ürün ekranı açık mı?
  bool _running = false; // Kamera şu an çalışıyor mu?

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // Sekme aktif/pasif olunca TickerMode değişir, Flutter burayı çağırır.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabActive = TickerMode.of(context);
    _syncCamera();
  }

  // Uygulama arka plana gidince / geri gelince.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _syncCamera();
  }

  /// Üç koşulun hepsi doğruysa kamera çalışır, biri bozulursa durur.
  Future<void> _syncCamera() async {
    final shouldRun = _tabActive && _appResumed && !_handling;
    if (shouldRun == _running) return;
    _running = shouldRun;
    try {
      if (shouldRun) {
        await _controller.start();
      } else {
        await _controller.stop();
      }
    } on MobileScannerException {
      // Hata (örn. izin verilmedi) errorBuilder'da kullanıcıya gösterilir.
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return; // aynı barkodu ikinci kez işleme
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    _handling = true;
    await _syncCamera(); // kamerayı durdur

    if (!mounted) return;
    // Ürün ekranı kapanana (geri dönülene) kadar burada bekler.
    await context.push('/product/$code');

    _handling = false;
    if (mounted) await _syncCamera(); // kamerayı tekrar başlat
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Kamera açılamadı. Ayarlardan kamera iznini kontrol et.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // Hedefleme çerçevesi
        Center(
          child: Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'Barkodu çerçevenin içine getir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}