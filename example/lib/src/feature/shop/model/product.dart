import 'package:example/src/feature/shop/model/category.dart' show CategoryID;
import 'package:meta/meta.dart';

typedef ProductID = int;

@immutable
class ProductEntity implements Comparable<ProductEntity> {
  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory ProductEntity.fromJson(Map<String, Object?> map) => ProductEntity(
        id: map['id']! as ProductID,
        title: map['title']! as String,
        description: map['description']! as String,
        price: (map['price']! as num).toInt(),
        discountPercentage: (map['discountPercentage']! as num).toDouble(),
        rating: (map['rating']! as num).toDouble(),
        stock: (map['stock']! as num).toInt(),
        brand: map['brand']! as String,
        category: map['category']! as CategoryID,
        thumbnail: map['thumbnail']! as String,
        images: (map['images']! as Iterable<Object?>).cast<String>().toList(),
      );

  final ProductID id;
  final String title;
  final String description;
  final int price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final CategoryID category;
  final String thumbnail;
  final List<String> images;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'brand': brand,
        'category': category,
        'thumbnail': thumbnail,
        'images': images,
      };

  @override
  String toString() => 'Product{'
      'id: $id, '
      'title: $title, '
      'description: $description, '
      'price: $price, '
      'discountPercentage: $discountPercentage, '
      'rating: $rating, '
      'stock: $stock, '
      'brand: $brand, '
      'category: $category, '
      'thumbnail: $thumbnail, '
      'images: $images'
      '}';

  @override
  int compareTo(covariant ProductEntity other) => title.compareTo(other.title);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProductEntity && other.id == id);
}
