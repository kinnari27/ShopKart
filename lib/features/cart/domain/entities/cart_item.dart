import 'package:equatable/equatable.dart';
import 'package:shop_kart/shared/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    this.size,
  });

  final Product product;
  final int quantity;
  final String? size;

  double get total => product.price * quantity;

  dynamic get cartKey => size != null ? '${product.id}_$size' : product.id;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? size,
  }) => CartItem(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    size: size ?? this.size,
  );

  @override
  List<Object?> get props => [product, quantity, size];
}
