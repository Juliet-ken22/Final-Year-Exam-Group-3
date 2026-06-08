class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final String formattedPrice;
  final String formattedSubtotal;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.formattedPrice,
    required this.formattedSubtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product']?['name'] ?? json['product_name'] ?? '',
      productImage: json['product']?['main_image'] ?? json['product_image'],
      quantity: json['quantity'] ?? 1,
      formattedPrice: json['formatted_price'] ?? json['price']?.toString() ?? '',
      formattedSubtotal: json['formatted_subtotal'] ?? json['subtotal']?.toString() ?? '',
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final String formattedTotal;
  final String createdAt;
  final List<OrderItem> items;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? notes;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.formattedTotal,
    required this.createdAt,
    this.items = const [],
    this.shippingAddress,
    this.paymentMethod,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] ?? json['order_items'] ?? [];
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? json['reference'] ?? '#${json['id']}',
      status: json['status'] ?? 'pending',
      formattedTotal: json['formatted_total'] ?? json['total']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      items: (itemsList as List).map((e) => OrderItem.fromJson(e)).toList(),
      shippingAddress: json['shipping_address'] ?? json['address'],
      paymentMethod: json['payment_method'],
      notes: json['notes'],
    );
  }

  // Status helpers
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isProcessing => status.toLowerCase() == 'processing';
  bool get isShipped => status.toLowerCase() == 'shipped';
  bool get isDelivered => status.toLowerCase() == 'delivered';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'processing': return 'Processing';
      case 'shipped': return 'Shipped';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}