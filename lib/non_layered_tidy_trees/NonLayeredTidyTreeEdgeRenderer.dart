part of graphview;

class Configuration {

}

class NonLayeredTidyTreeEdgeRender extends EdgeRenderer {

  NonLayeredTidyTreeEdgeRender();

  var linePath = Path();

  @override
  void render(Canvas canvas, Graph graph, Paint paint) {
    graph.nodes.forEach((node) {
      var children = graph.successorsOf(node);

      children.forEach((child) {
        var edge = graph.getEdgeBetween(node, child);
        var edgePaint = (edge?.paint ?? paint)..style = PaintingStyle.stroke;
        edgePaint.color = Colors.red;
        linePath.reset();
        // position at the middle-top of the child
        linePath.moveTo((child.x + child.width / 2), child.y);
        // // draws a line from the child's middle-top halfway up to its parent
        // linePath.lineTo(child.x + child.width / 2, child.y);
        // // draws a line from the previous point to the middle of the parents width
        // linePath.lineTo(node.x + node.width / 2, child.y);
        //
        // // position at the middle of the level separation under the parent
        // linePath.moveTo(node.x + node.width / 2, child.y);
        // draws a line up to the parents middle-bottom
        linePath.lineTo(node.x + node.width / 2, node.y + node.height);

        canvas.drawPath(linePath, edgePaint);
      });
    });
  }
}
