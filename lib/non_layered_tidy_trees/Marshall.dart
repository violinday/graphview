part of graphview;

class Marshall{

	Tree? convert(NonLayeredTidyTreeNode? root) {
		if(root == null) return null;
		List<Tree> children = [];
		for(int i = 0 ; i < root.children.length ; i++){
			children.add(convert(root.children[i]) as Tree);
		}
		return Tree(root.width, root.height, root.y, children);
	}


	void convertBack(Object converted, NonLayeredTidyTreeNode root) {
		Tree conv = converted as Tree;
		root.x = conv.x;
		for(int i = 0 ; i < conv.c.length ; i++){
			convertBack(conv.c[i], root.children[i]);
		}
		
	}

	void runOnConverted(NonLayeredTidyAlgorithm algorithm, Object root) {
		algorithm.layout(root as Tree);
	}
}
