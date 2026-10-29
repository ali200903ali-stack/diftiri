class DemoProduct {
  const DemoProduct({
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
  });

  final String name;
  final String sku;
  final double price;
  final int stock;
}

abstract final class DemoStore {
  static const products = <DemoProduct>[
    DemoProduct(name: 'مياه معدنية', sku: '10001', price: 250, stock: 46),
    DemoProduct(name: 'عصير برتقال', sku: '10002', price: 700, stock: 18),
    DemoProduct(name: 'أرز 5 كجم', sku: '10003', price: 7200, stock: 9),
    DemoProduct(name: 'وجبة برجر', sku: '20001', price: 2500, stock: 999),
    DemoProduct(name: 'شاورما عربي', sku: '20002', price: 1800, stock: 999),
    DemoProduct(name: 'بطاطس', sku: '20003', price: 900, stock: 999),
  ];
}
