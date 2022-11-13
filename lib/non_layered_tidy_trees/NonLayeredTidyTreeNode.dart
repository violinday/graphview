part of graphview;

typedef EachNode = void Function(NonLayeredTidyTreeNode node);

class NonLayeredTidyTreeNode {
// input
  double width, height;

  List<NonLayeredTidyTreeNode> children = [];
  double hgap = 10, vgap = 10;

// output
  double x = 0, y = 0;

  int depth = 0;

  NonLayeredTidyTreeNode(this.width, this.height, this.children);

  BoundingBox getBoundingBox() {
    var result = BoundingBox(0, 0);
    getNodeBoundingBox(this, result);
    return result;
  }

  int size() {
    int res = 1;
    for (NonLayeredTidyTreeNode node in children) {
      res += node.size();
    }
    return res;
  }

  bool hasChildren() {
    return children.isNotEmpty;
  }

  final double tolerance = 0.0;

  bool overlap(double xStart, double xEnd, double xStart2, double xEnd2) {
    return (xStart2 + tolerance < xEnd - tolerance && xEnd2 - tolerance > xStart + tolerance) ||
        (xStart + tolerance < xEnd2 - tolerance && xEnd - tolerance > xStart2 + tolerance);
  }

  bool overlapsWith(NonLayeredTidyTreeNode other) {
    return overlap(x, x + width, other.x, other.x + other.width) &&
        overlap(y, y + height, other.y, other.y + other.height);
  }

  void allNodes(List<NonLayeredTidyTreeNode> nodes) {
    nodes.add(this);
    for (NonLayeredTidyTreeNode node in children) {
      node.allNodes(nodes);
    }
  }

  void eachNode(EachNode callback) {
    Queue<NonLayeredTidyTreeNode> nodes = QueueList();
    nodes.add(this);
    while (nodes.isNotEmpty) {
      var current = nodes.removeFirst();
      callback(current);
      nodes.addAll(current.children);
    }
  }

  void translate({double tx = 0, double ty = 0}) {
    eachNode((node) {
      node.x += tx;
      node.y += ty;
    });
  }

  void right2left() {
    BoundingBox bb = getBoundingBox();
    eachNode((node) => {node.x = node.x - (node.x - bb.left) * 2 - node.width});
    translate(tx: bb.width, ty: 0);
  }

  void down2up() {
    BoundingBox bb = getBoundingBox();
    eachNode((node) => {node.y = node.y - (node.y - bb.top) * 2 - node.height});
    translate(tx: 0, ty: bb.height);
  }

  int getDepth() {
    int res = 1;
    for (NonLayeredTidyTreeNode child in children) {
      res = max(res, child.getDepth() + 1);
    }
    return res;
  }

  bool isRoot () {
    return depth == 0;
  }

  void addGap(double hgap, double vgap) {
    this.hgap += hgap;
    this.vgap += vgap;
    this.width += 2 * hgap;
    this.height += 2 * vgap;
    for (NonLayeredTidyTreeNode child in children) {
      child.addGap(hgap, vgap);
    }
  }

  void addSize(double hsize, double vsize) {
    this.width += hsize;
    this.height += vsize;
    for (NonLayeredTidyTreeNode child in children) {
      child.addSize(hsize, vsize);
    }
  }

  void addGapPerDepth(int gapPerDepth, int depth, int maxDepth) {
    this.hgap += (maxDepth - depth) * gapPerDepth;
    this.width += 2 * (maxDepth - depth) * gapPerDepth;
    for (NonLayeredTidyTreeNode child in children) {
      child.addGapPerDepth(gapPerDepth, depth + 1, maxDepth);
    }
  }

  void print() {
    debugPrint("TreeNode($x, $y $width, $height");
    for (NonLayeredTidyTreeNode child in children) {
      debugPrint(", ");
      child.print();
    }
    debugPrint(")");
  }

  void mul(double w, double h) {
    width *= w;
    height *= h;
    for (NonLayeredTidyTreeNode child in children) {
      child.mul(w, h);
    }
  }

  void randExpand(NonLayeredTidyTreeNode t, Random r) {
    t.y += height;
    int i = r.nextInt(children.length + 1);
    if (i == children.length) {
      addKid(t);
    } else {
      children[i].randExpand(t, r);
    }
  }

  void addKid(NonLayeredTidyTreeNode t) {
    children.add(t);
  }

  /// Node Utils

  static void convertBack(Object converted, NonLayeredTidyTreeNode root, bool isHorizontal) {
    Tree conv = converted as Tree;
    if (isHorizontal) {
      root.y = converted.x;
    } else {
      root.x = converted.x;
    }
    for (int i = 0; i < conv.c.length; i++) {
      convertBack(conv.c[i], root.children[i], isHorizontal);
    }
  }

  static void getNodeBoundingBox(NonLayeredTidyTreeNode tree, BoundingBox b) {
    b.left = min(b.left, tree.x);
    b.top = min(b.top, tree.y);
    b.width = max(b.width, tree.x + tree.width);
    b.height = max(b.height, tree.y + tree.height);
    for (var child in tree.children) {
      getNodeBoundingBox(child, b);
    }
  }

  static void layer(NonLayeredTidyTreeNode node, bool isHorizontal, double d) {
    if (isHorizontal) {
      node.x = d;
      d += node.width;
    } else {
      node.y = d;
      d += node.height;
    }

    for (var child in node.children) {
      layer(child, isHorizontal, d);
    }
  }

  static void moveRight(NonLayeredTidyTreeNode node, double move, bool isHorizontal) {
    if (isHorizontal) {
      node.y += move;
    } else {
      node.x += move;
    }
    for (var child in node.children) {
      moveRight(child, move, isHorizontal);
    }
  }

  static double getMin(NonLayeredTidyTreeNode node, bool isHorizontal) {
    var res = isHorizontal ? node.y : node.x;
    for (var child in node.children) {
      res = min(getMin(child, isHorizontal), res);
    }
    return res;
  }

  static void normalize(NonLayeredTidyTreeNode node, bool isHorizontal) {
    var min = getMin(node, isHorizontal);
    moveRight(node, -min, isHorizontal);
  }
}
