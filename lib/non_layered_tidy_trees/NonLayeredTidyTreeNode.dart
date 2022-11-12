import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'BoundingBox.dart';

class TreeNode {
// input
  double width, height;
  List<TreeNode> children = [];
  double hgap = 0, vgap = 0;

// output
  double x = 0, y = 0;

  TreeNode(this.width, this.height, List<TreeNode> children);

  BoundingBox getBoundingBox(TreeNode child) {
    BoundingBox result = BoundingBox(0, 0);
    _getBoundingBox(this, result);
    return result;
  }

  static void _getBoundingBox(TreeNode tree, BoundingBox b) {
    b.width = max(b.width, tree.x + tree.width);
    b.height = max(b.height, tree.y + tree.height);
    for (TreeNode child in tree.children) {
      _getBoundingBox(child, b);
    }
  }

  void moveRight(double move) {
    x += move;
    for (TreeNode child in children) {
      child.moveRight(move);
    }
  }

  void normalizeX() {
    double minX = getMinX();
    moveRight(-minX);
  }

  double getMinX() {
    double res = x;
    for (TreeNode child in children) {
      res = min(child.getMinX(), res);
    }
    return res;
  }

  int size() {
    int res = 1;
    for (TreeNode node in children) {
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

  bool overlapsWith(TreeNode other) {
    return overlap(x, x + width, other.x, other.x + other.width) &&
        overlap(y, y + height, other.y, other.y + other.height);
  }

  void allNodes(List<TreeNode> nodes) {
    nodes.add(this);
    for (TreeNode node in children) {
      node.allNodes(nodes);
    }
  }

  int getDepth() {
    int res = 1;
    for (TreeNode child in children) {
      res = max(res, child.getDepth() + 1);
    }
    return res;
  }

  void addGap(double hgap, double vgap) {
    this.hgap += hgap;
    this.vgap += vgap;
    this.width += 2 * hgap;
    this.height += 2 * vgap;
    for (TreeNode child in children) {
      child.addGap(hgap, vgap);
    }
  }

  void addSize(double hsize, double vsize) {
    this.width += hsize;
    this.height += vsize;
    for (TreeNode child in children) {
      child.addSize(hsize, vsize);
    }
  }

  void addGapPerDepth(int gapPerDepth, int depth, int maxDepth) {
    this.hgap += (maxDepth - depth) * gapPerDepth;
    this.width += 2 * (maxDepth - depth) * gapPerDepth;
    for (TreeNode child in children) {
      child.addGapPerDepth(gapPerDepth, depth + 1, maxDepth);
    }
  }

  void print() {
    debugPrint("TreeNode($x, $y $width, $height");
    for (TreeNode child in children) {
      debugPrint(", ");
      child.print();
    }
    debugPrint(")");
  }

  void mul(double w, double h) {
    width *= w;
    height *= h;
    for (TreeNode child in children) {
      child.mul(w, h);
    }
  }

  void layer() {
    _layer(0);
  }

  void _layer(double d) {
    y = d;
    d += height;
    for (TreeNode child in children) {
      child._layer(d);
    }
  }

  void randExpand(TreeNode t, Random r) {
    t.y += height;
    int i = r.nextInt(children.length + 1);
    if (i == children.length) {
      addKid(t);
    } else {
      children[i].randExpand(t, r);
    }
  }

  void addKid(TreeNode t) {
    children.add(t);
  }
}
