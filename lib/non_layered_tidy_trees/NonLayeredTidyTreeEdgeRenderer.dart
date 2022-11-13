part of graphview;

class NonLayeredTidyTreeEdgeRender extends EdgeRenderer {

  NonLayeredTidyConfiguration configuration;
  NonLayeredTidyTreeEdgeRender(this.configuration);

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

        switch (configuration.orientation) {
          case NonLayeredTidyConfiguration.ORIENTATION_TOP_BOTTOM:
            linePath.moveTo((child.x + child.width / 2), child.y);
            linePath.lineTo(node.x + node.width / 2, node.y + node.height);
            break;
          case NonLayeredTidyConfiguration.ORIENTATION_BOTTOM_TOP:
            linePath.moveTo((child.x + child.width / 2), child.y + child.height);
            linePath.lineTo(node.x + node.width / 2, node.y);
            break;
          case NonLayeredTidyConfiguration.ORIENTATION_LEFT_RIGHT:
            linePath.moveTo(child.x, child.y + child.height/2);
            linePath.lineTo(node.x + node.width, node.y + node.height/2);
            break;
          case NonLayeredTidyConfiguration.ORIENTATION_RIGHT_LEFT:
            linePath.moveTo(child.x + child.width, child.y + child.height/2);
            linePath.lineTo(node.x, node.y + node.height/2);
            break;
          default:
            if(node.x < child.x) {
              linePath.moveTo(child.x, child.y + child.height/2);
              linePath.lineTo(node.x + node.width, node.y + node.height/2);
            } else {
              linePath.moveTo(child.x + child.width, child.y + child.height/2);
              linePath.lineTo(node.x, node.y + node.height/2);
            }
        }


        canvas.drawPath(linePath, edgePaint);
      });
    });
  }
}
