
part of graphview;

class BoundingBox {
  double width, height;
  double left = double.maxFinite;
  double top =  double.maxFinite;

  BoundingBox(this.width, this.height);

  BoundingBox merge(BoundingBox b) {
    return BoundingBox(max(b.width, width), max(b.height, height));
  }
}
