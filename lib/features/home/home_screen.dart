import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/history_item.dart';
import '../../data/models/product.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../router.dart';
import 'widgets/allergen_chips.dart';
import 'widgets/health_summary_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_product_card.dart';
import 'widgets/home_product_carousel.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_section_header.dart';
import 'widgets/home_style.dart';
import 'widgets/section_state.dart';

// ---------------------------------------------------------------------------
// Veri: Firebase'e sadece repository'ler dokunur, burada onları çağırıyoruz.
// ---------------------------------------------------------------------------

/// Kullanıcının seçtiği alerjenler (giriş yoksa boş liste).
final _allergensProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <String>[]);
  return ref.watch(userRepositoryProvider).watchAllergens(user.uid);
});

/// Son 7 günde taranan ürünler, en yeni başta (giriş yoksa boş liste).
final _historyProvider = StreamProvider<List<HistoryItem>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <HistoryItem>[]);
  return ref.watch(userRepositoryProvider).watchHistory(user.uid);
});

/// Geçmişteki bir kayıt + o ürünün veritabanındaki bilgisi (yoksa null).
class _Scan {
  const _Scan(this.item, this.product);

  final HistoryItem item;
  final Product? product;
}

final _scansProvider = FutureProvider<List<_Scan>>((ref) async {
  final history = await ref.watch(_historyProvider.future);
  final products = ref.watch(productRepositoryProvider);
  final found = await Future.wait(
    history.map((h) => products.getByBarcode(h.barcode)),
  );
  return [
    for (var i = 0; i < history.length; i++) _Scan(history[i], found[i]),
  ];
});

final _trendingProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).getTrending(),
);

/// Arama kutusuna yazılan metne göre bulunan ürünler.
final _searchProvider = FutureProvider.family<List<Product>, String>(
  (ref, query) => ref.watch(productRepositoryProvider).searchByName(query),
);

// ---------------------------------------------------------------------------
// Ekran
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double _pad = 20;

  final TextEditingController _searchController = TextEditingController();

  /// Aranan kelime (boşsa arama sonuçları gösterilmez).
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Alttaki yüzen menünün içeriği örtmemesi için.
  static const double _bottomSpace = 110;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final allergens = ref.watch(_allergensProvider);
    final scans = ref.watch(_scansProvider);
    final trending = ref.watch(_trendingProvider);

    final myAllergens = allergens.value ?? const <String>[];

    // Alerjenler yüklenmeden ürünler "güvenli" görünmesin diye, onlara bağlı
    // bölümler alerjenler hazır olana kadar yükleniyor/hata gösterir.
    Widget needsAllergens(double height, Widget Function() child) {
      if (allergens.hasError) {
        return SectionError(
          height: height,
          onRetry: () => ref.invalidate(_allergensProvider),
        );
      }
      if (!allergens.hasValue) return SectionLoading(height: height);
      return child();
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 12, bottom: _bottomSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _padded(
              HomeHeader(
                name: user?.name,
                onNotificationsPressed: () =>
                    _notConnected(context, 'Bildirimler'),
              ),
            ),
            const SizedBox(height: 16),
            _padded(
              HomeSearchBar(
                controller: _searchController,
                onSubmitted: (q) => _onSearch(context, q),
                onChanged: (q) {
                  if (q.trim().isEmpty && _query.isNotEmpty) {
                    setState(() => _query = '');
                  }
                },
                onScanPressed: () => context.go(AppRoutes.scanner),
              ),
            ),
            if (_query.isNotEmpty) ...[
              const SizedBox(height: 22),
              _padded(
                HomeSectionHeader(
                  title: 'Arama sonuçları',
                  leading: const Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: HomeColors.primaryDark,
                  ),
                  actionLabel: 'Temizle',
                  onAction: _clearSearch,
                ),
              ),
              const SizedBox(height: 10),
              _padded(
                ref.watch(_searchProvider(_query)).when(
                      skipLoadingOnReload: true,
                      data: (list) => needsAllergens(
                        120,
                        () => _resultsGrid(context, list, myAllergens),
                      ),
                      loading: () => const SectionLoading(),
                      error: (_, __) => SectionError(
                        onRetry: () => ref.invalidate(_searchProvider(_query)),
                      ),
                    ),
              ),
            ],
            const SizedBox(height: 22),
            _padded(
              HomeSectionHeader(
                title: 'Alerjenlerin',
                actionLabel: 'Düzenle',
                onAction: () => context.go(AppRoutes.profile),
              ),
            ),
            const SizedBox(height: 8),
            allergens.when(
              skipLoadingOnReload: true,
              data: (list) => AllergenChips(allergens: list),
              loading: () => const SectionLoading(height: 44),
              error: (_, __) => _padded(
                SectionError(
                  height: 80,
                  onRetry: () => ref.invalidate(_allergensProvider),
                ),
              ),
            ),
            const SizedBox(height: 22),
            _padded(
              const HomeSectionHeader(
                title: 'Günlük Sağlık Özetin',
                leading: Text('📊', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 10),
            _padded(
              scans.when(
                skipLoadingOnReload: true,
                data: (list) => needsAllergens(
                  132,
                  () => HealthSummaryCard(
                    todayPercent: _safePercent(
                      list.where((s) => _isToday(s.item.scannedAt)),
                      myAllergens,
                    ),
                    weeklyPercent: _safePercent(list, myAllergens),
                  ),
                ),
                loading: () => const SectionLoading(height: 132),
                error: (_, __) => SectionError(
                  height: 132,
                  onRetry: () => ref.invalidate(_scansProvider),
                ),
              ),
            ),
            const SizedBox(height: 22),
            _padded(
              HomeSectionHeader(
                title: 'Son Aratılanlar',
                leading: const Icon(
                  Icons.schedule_rounded,
                  size: 24,
                  color: HomeColors.primaryDark,
                ),
                actionLabel: 'Tümünü Gör',
                onAction: () => _notConnected(context, 'Tarama geçmişi'),
              ),
            ),
            const SizedBox(height: 6),
            scans.when(
              skipLoadingOnReload: true,
              data: (list) => needsAllergens(
                160,
                () => HomeProductCarousel(
                  emptyMessage: 'Henüz tarama yok.',
                  cards: [
                    for (final s in list.take(10))
                      _scanCard(context, s, myAllergens),
                  ],
                ),
              ),
              loading: () => const SectionLoading(height: 160),
              error: (_, __) => _padded(
                SectionError(
                  height: 140,
                  onRetry: () => ref.invalidate(_scansProvider),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _padded(
              HomeSectionHeader(
                title: 'Trend Ürünler',
                leading: const Text('🔥', style: TextStyle(fontSize: 20)),
                actionLabel: 'Tümünü Gör',
                onAction: () => _notConnected(context, 'Trend ürünler'),
              ),
            ),
            const SizedBox(height: 6),
            trending.when(
              skipLoadingOnReload: true,
              data: (list) => needsAllergens(
                160,
                () => HomeProductCarousel(
                  emptyMessage: 'Şu an gösterilecek ürün yok.',
                  cards: [
                    for (final p in list)
                      _productCard(context, p, myAllergens, width: 184),
                  ],
                ),
              ),
              loading: () => const SectionLoading(height: 160),
              error: (_, __) => _padded(
                SectionError(
                  height: 140,
                  onRetry: () => ref.invalidate(_trendingProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Kartları hazırlayan yardımcılar ----

  /// Arama sonuçları: ekran genişliğine göre yan yana iki kart.
  Widget _resultsGrid(
    BuildContext context,
    List<Product> products,
    List<String> allergens,
  ) {
    if (products.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HomeColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HomeColors.border),
        ),
        child: const Text(
          'Sonuç bulunamadı. Ürünün baş harflerini yazmayı dene.',
          textAlign: TextAlign.center,
          style: TextStyle(color: HomeColors.textSecondary),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final p in products)
              _productCard(context, p, allergens, width: width),
          ],
        );
      },
    );
  }

  Widget _scanCard(BuildContext context, _Scan scan, List<String> allergens) {
    final product = scan.product;
    if (product == null) {
      // Ürün veritabanında bulunamadı: yine de geçmişte görünsün.
      return HomeProductCard(
        name: scan.item.name,
        descriptor: 'Bilgi bulunamadı',
        status: ProductStatus.unknown,
        width: 150,
        imageHeight: 84,
        onTap: () => _openProduct(context, scan.item.barcode),
      );
    }
    return _productCard(context, product, allergens, width: 150);
  }

  Widget _productCard(
    BuildContext context,
    Product product,
    List<String> allergens, {
    required double width,
  }) {
    final risky = product.conflictsWith(allergens);
    return HomeProductCard(
      name: product.name,
      descriptor: risky
          ? 'Alerjen İçerir'
          : (product.brand.isNotEmpty ? product.brand : 'Alerjen yok'),
      status: risky ? ProductStatus.risky : ProductStatus.safe,
      width: width,
      imageHeight: width > 160 ? 86 : 84,
      novaGroup: product.novaGroup,
      imageUrl: product.imageUrl,
      onTap: () => _openProduct(context, product.barcode),
    );
  }

  // ---- Özet hesabı ----

  /// Taranan ürünlerden "güvenli ve temiz" olanların yüzdesi.
  /// Güvenli: kullanıcının alerjeni yok ve NOVA 4 (ultra işlenmiş) değil.
  /// Veritabanında bulunamayan ürünler hesaba katılmaz. Hiç ürün yoksa null.
  static int? _safePercent(Iterable<_Scan> scans, List<String> allergens) {
    final known = scans.where((s) => s.product != null).toList();
    if (known.isEmpty) return null;
    final safe = known.where((s) {
      final p = s.product!;
      final nova = p.novaGroup;
      return !p.conflictsWith(allergens) && (nova == null || nova <= 3);
    }).length;
    return (safe * 100 / known.length).round();
  }

  static bool _isToday(DateTime t) {
    final now = DateTime.now();
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }

  // ---- Tıklamalar ----

  /// Ürün sayfasına sadece barkod taşınır (ARCHITECTURE.md: /product/:barcode).
  void _openProduct(BuildContext context, String barcode) {
    context.push('/product/$barcode');
  }

  void _onSearch(BuildContext context, String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    if (RegExp(r'^\d{8,14}$').hasMatch(q)) {
      _openProduct(context, q); // barkod yazıldı: doğrudan ürüne git
    } else {
      setState(() => _query = q); // isim yazıldı: sonuçları listele
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _notConnected(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what henüz bağlanmadı.')));
  }

  static Widget _padded(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _pad),
        child: child,
      );
}
