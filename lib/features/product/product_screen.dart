import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'widgets/allergen_section.dart';
import 'widgets/nutrition_table.dart';
import 'widgets/product_header.dart';
import 'widgets/product_style.dart';
import 'widgets/section_card.dart';

// ---------------------------------------------------------------------------
// Veri: Firebase'e sadece repository'ler dokunur, burada onları çağırıyoruz.
// ---------------------------------------------------------------------------

/// Barkoddan ürün (veritabanında yoksa null).
final _productProvider = FutureProvider.family<Product?, String>(
  (ref, barcode) => ref.watch(productRepositoryProvider).getByBarcode(barcode),
);

/// Kullanıcının seçtiği alerjenler (giriş yoksa boş liste).
final _allergensProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <String>[]);
  return ref.watch(userRepositoryProvider).watchAllergens(user.uid);
});

// ---------------------------------------------------------------------------
// Ekran
// ---------------------------------------------------------------------------

/// Router `/product/:barcode` adresinden barkodu ayıklayıp buraya verir.
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.barcode});

  final String barcode;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  void initState() {
    super.initState();
    // Ürün bulunup giriş yapılmışsa taramayı geçmişe yazar (home "son taramalar").
    ref.listenManual(_productProvider(widget.barcode), (_, next) {
      final product = next.value;
      final user = ref.read(authRepositoryProvider).currentUser;
      if (product == null || user == null) return;
      ref
          .read(userRepositoryProvider)
          .addToHistory(user.uid, barcode: product.barcode, name: product.name)
          .ignore(); // geçmiş yazılamazsa ürün sayfası yine de açılsın
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final barcode = widget.barcode;
    final product = ref.watch(_productProvider(barcode));
    final myAllergens = ref.watch(_allergensProvider).value ?? const <String>[];

    return Scaffold(
      backgroundColor: ProductColors.bg,
      appBar: AppBar(
        title: const Text('Ürün'),
        backgroundColor: ProductColors.bg,
        foregroundColor: ProductColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: product.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: ProductColors.primary),
        ),
        error: (_, __) => _Message(
          text: 'Ürün yüklenemedi.',
          actionLabel: 'Tekrar dene',
          onAction: () => ref.invalidate(_productProvider(barcode)),
        ),
        data: (p) => p == null
            ? _Message(text: 'Bu ürün ($barcode) veritabanında bulunamadı.')
            : _ProductBody(product: p, myAllergens: myAllergens),
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody({required this.product, required this.myAllergens});

  final Product product;
  final List<String> myAllergens;

  @override
  Widget build(BuildContext context) {
    final conflicts = product.conflictingWith(myAllergens);
    final mine = myAllergens.map((e) => e.trim().toLowerCase()).toSet();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        ProductHeader(product: product),
        if (myAllergens.isNotEmpty) ...[
          const SizedBox(height: 16),
          AllergenBanner(conflicts: conflicts),
        ],
        const SizedBox(height: 20),
        SectionCard(
          title: 'Alerjenler',
          child: ProductAllergens(product: product, mine: mine),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'İçindekiler',
          child: Text(
            product.ingredients.isEmpty
                ? 'İçerik bilgisi bulunamadı.'
                : product.ingredients,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: ProductColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Besin Değerleri (100 g)',
          child: NutritionTable(product),
        ),
      ],
    );
  }
}

/// Yüklenemedi / ürün bulunamadı mesajı (+ isteğe bağlı buton).
class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: ProductColors.textSecondary,
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(color: ProductColors.primaryDark),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
