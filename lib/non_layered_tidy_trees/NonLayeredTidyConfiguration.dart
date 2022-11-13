part of graphview;

class NonLayeredTidyConfiguration {
  static const int DEFAULT_HGAP = 10;
  static const int DEFAULT_VGAP = 10;

  static const int ORIENTATION_TOP_BOTTOM = 1;
  static const int ORIENTATION_BOTTOM_TOP = 2;
  static const int ORIENTATION_LEFT_RIGHT = 3;
  static const int ORIENTATION_RIGHT_LEFT = 4;
  static const int DEFAULT_ORIENTATION = ORIENTATION_LEFT_RIGHT;

  int vgap;
  int hgap;
  int orientation;

  NonLayeredTidyConfiguration({
    this.orientation = DEFAULT_ORIENTATION,
    this.vgap = DEFAULT_VGAP,
    this.hgap = DEFAULT_HGAP,
  });

  int getHgap() {
    return hgap;
  }

  int getVgap() {
    return vgap;
  }
}
