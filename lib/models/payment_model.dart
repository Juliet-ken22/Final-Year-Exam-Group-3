class PaymentModel {
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double total;

  PaymentModel({
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  factory PaymentModel.fromJson(
      Map<String, dynamic> json) {
    return PaymentModel(
      paymentMethod: json['paymentMethod'],
      subtotal: json['subtotal'].toDouble(),
      deliveryFee: json['deliveryFee'].toDouble(),
      total: json['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
    };
  }
}