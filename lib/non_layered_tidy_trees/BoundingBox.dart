
part of graphview;

class BoundingBox {
  double width, height;

  BoundingBox(this.width, this.height);

  BoundingBox merge(BoundingBox b) {
    return BoundingBox(max(b.width, width), max(b.height, height));
  }
}
