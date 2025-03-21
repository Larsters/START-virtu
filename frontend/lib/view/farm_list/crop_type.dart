enum CropType {
  soybean(
    displayName: 'Soybean',
    imagePath: 'assets/images/soybean.jpg',
    color: 0xFFF0F7EA,
  ),
  corn(
    displayName: 'Corn',
    imagePath: 'assets/images/corn.jpg',
    color: 0xFFFFF9E6,
  ),
  cotton(
    displayName: 'Cotton',
    imagePath: 'assets/images/cotton.jpg',
    color: 0xFFF5F5F5,
  );

  final String displayName;
  final String imagePath;
  final int color;

  const CropType({
    required this.displayName,
    required this.imagePath,
    required this.color,
  });

  String localized() => displayName;
}
