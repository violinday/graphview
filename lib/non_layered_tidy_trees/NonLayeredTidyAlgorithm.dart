/* The extended Reingold-Tilford algorithm as described in the paper
 * "Drawing Non-layered Tidy Trees in Linear Time" by Atze van der Ploeg
 * Accepted for publication in Software: Practice and Experience, to Appear.
 * 
 * This code is in the public domain, use it any way you wish. A reference to the paper is 
 * appreciated!
 */

import 'Marshall.dart';

class NonLayeredTidyAlgorithm {

  Marshall m = Marshall();

  static void layout(Tree t) {
    firstWalk(t);
    secondWalk(t, 0);
  }

  static void firstWalk(Tree t) {
    if (t.cs == 0) {
      setExtremes(t);
      return;
    }
    firstWalk(t.c[0]);
    // ^{\normalfont Create siblings in contour minimal vertical coordinate and index list.}^
    IYL ih = updateIYL(bottom(t.c[0].el!), 0, null);
    for (int i = 1; i < t.cs; i++) {
      firstWalk(t.c[i]);
      //^{\normalfont Store lowest vertical coordinate while extreme nodes still point in current subtree.}^
      double minY = bottom(t.c[i].er!);
      seperate(t, i, ih);
      ih = updateIYL(minY, i, ih);
    }
    positionRoot(t);
    setExtremes(t);
  }

  static void setExtremes(Tree t) {
    if (t.cs == 0) {
      t.el = t;
      t.er = t;
      t.msel = t.mser = 0;
    } else {
      t.el = t.c[0].el;
      t.msel = t.c[0].msel;
      t.er = t.c[t.cs - 1].er;
      t.mser = t.c[t.cs - 1].mser;
    }
  }

  static void seperate(Tree t, int i, IYL ih) {
    // ^{\normalfont Right contour node of left siblings and its sum of modfiers.}^
    Tree sr = t.c[i - 1];
    double mssr = sr.mod;
    // ^{\normalfont Left contour node of current subtree and its sum of modfiers.}^
    Tree cl = t.c[i];
    double mscl = cl.mod;
    while (sr != null && cl != null) {
      if (bottom(sr) > ih.lowY) ih = ih.nxt!;
      // ^{\normalfont How far to the left of the right side of sr is the left side of cl?}^
      double dist = (mssr + sr.prelim + sr.w) - (mscl + cl.prelim);
      if (dist > 0) {
        mscl += dist;
        moveSubtree(t, i, ih.index, dist);
      }
      double sy = bottom(sr), cy = bottom(cl);
      // ^{\normalfont Advance highest node(s) and sum(s) of modifiers}^
      if (sy <= cy) {
        sr = nextRightContour(sr);
        if (sr != null) mssr += sr.mod;
      }
      if (sy >= cy) {
        cl = nextLeftContour(cl);
        if (cl != null) mscl += cl.mod;
      }
    }
    // ^{\normalfont Set threads and update extreme nodes.}^
    // ^{\normalfont In the first case, the current subtree must be taller than the left siblings.}^
    if (sr == null && cl != null)
      setLeftThread(t, i, cl, mscl);
    // ^{\normalfont In this case, the left siblings must be taller than the current subtree.}^
    else if (sr != null && cl == null) setRightThread(t, i, sr, mssr);
  }

  static void moveSubtree(Tree t, int i, int si, double dist) {
    // ^{\normalfont Move subtree by changing mod.}^
    t.c[i].mod += dist;
    t.c[i].msel += dist;
    t.c[i].mser += dist;
    distributeExtra(t, i, si, dist);
  }

  static Tree nextLeftContour(Tree t) {
    return t.cs == 0 ? t.tl! : t.c[0];
  }

  static Tree nextRightContour(Tree t) {
    return t.cs == 0 ? t.tr! : t.c[t.cs - 1];
  }

  static double bottom(Tree t) {
    return t.y + t.h;
  }

  static void setLeftThread(Tree t, int i, Tree cl, double modsumcl) {
    Tree li = t.c[0].el!;
    li.tl = cl;
    // ^{\normalfont Change mod so that the sum of modifier after following thread is correct.}^
    double diff = (modsumcl - cl.mod) - t.c[0].msel;
    li.mod += diff;
    // ^{\normalfont Change preliminary x coordinate so that the node does not move.}^
    li.prelim -= diff;
    // ^{\normalfont Update extreme node and its sum of modifiers.}^
    t.c[0].el = t.c[i].el;
    t.c[0].msel = t.c[i].msel;
  }

  // ^{\normalfont Symmetrical to setLeftThread.}^
  static void setRightThread(Tree t, int i, Tree sr, double modsumsr) {
    Tree ri = t.c[i].er!;
    ri.tr = sr;
    double diff = (modsumsr - sr.mod) - t.c[i].mser;
    ri.mod += diff;
    ri.prelim -= diff;
    t.c[i].er = t.c[i - 1].er;
    t.c[i].mser = t.c[i - 1].mser;
  }

  static void positionRoot(Tree t) {
    // ^{\normalfont Position root between children, taking into account their mod.}^
    t.prelim =
        (t.c[0].prelim + t.c[0].mod + t.c[t.cs - 1].mod + t.c[t.cs - 1].prelim + t.c[t.cs - 1].w) /
                2 -
            t.w / 2;
  }

  static void secondWalk(Tree t, double modsum) {
    modsum += t.mod;
    // ^{\normalfont Set absolute (non-relative) horizontal coordinate.}^
    t.x = t.prelim + modsum;
    addChildSpacing(t);
    for (int i = 0; i < t.cs; i++) secondWalk(t.c[i], modsum);
  }

  static void distributeExtra(Tree t, int i, int si, double dist) {
    // ^{\normalfont Are there intermediate children?}^
    if (si != i - 1) {
      double nr = (i - si) as double;
      t.c[si + 1].shift += dist / nr;
      t.c[i].shift -= dist / nr;
      t.c[i].change -= dist - dist / nr;
    }
  }

  // ^{\normalfont Process change and shift to add intermediate spacing to mod.}^
  static void addChildSpacing(Tree t) {
    double d = 0, modsumdelta = 0;
    for (int i = 0; i < t.cs; i++) {
      d += t.c[i].shift;
      modsumdelta += d + t.c[i].change;
      t.c[i].mod += modsumdelta;
    }
  }

  static IYL updateIYL(double minY, int i, IYL? ih) {
    // ^{\normalfont Remove siblings that are hidden by the new subtree.}^
    while (ih != null && minY >= ih.lowY) ih = ih.nxt;
    // ^{\normalfont Prepend the new subtree.}^
    return IYL(minY, i, ih);
  }
}

// ^{\normalfont A linked list of the indexes of left siblings and their lowest vertical coordinate.}^
class IYL {
  double lowY;
  int index;
  IYL? nxt;

  IYL(this.lowY, this.index, this.nxt);
}

class Tree {
  // ^{\normalfont Width and height.}^
  double w, h;

  double y;
  double x = 0, prelim = 0, mod = 0, shift = 0, change = 0;

  // ^{\normalfont Left and right thread.}^
  Tree? tl, tr;

  // ^{\normalfont Extreme left and right nodes.}^
  Tree? el, er;

  // ^{\normalfont Sum of modifiers at the extreme nodes.}^
  late double msel, mser;

  // ^{\normalfont Array of children and number of children.}^
  List<Tree> c;
  late int cs;

  Tree(this.w, this.h, this.y, this.c) : cs = c.length;
}
