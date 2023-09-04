class FoodItem {
  String name;
  String? userName;
  String image;
  String? uid;
  String? status;
  String? address;
  num? total;
  num? price;

  FoodItem(
      {this.address,
      required this.name,
      required this.image,
      this.price,
      this.status,
      this.total,
      this.uid,
      this.userName});
}
