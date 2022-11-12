
import 'NonLayeredTidyTreeNode.dart';
import 'NonLayeredTidyAlgorithm.dart';

class Marshall{

	dynamic convert(TreeNode? root) {
		if(root == null) return null;
		List<Tree> children = [];
		for(int i = 0 ; i < children.length ; i++){
			children.add(convert(root.children[i]) as Tree);
		}
		return Tree(root.width,root.height,root.y, children);
	}


	void convertBack(Object converted, TreeNode root) {
		Tree conv = converted as Tree;
		root.x = conv.x;
		for(int i = 0 ; i < conv.c.length ; i++){
			convertBack(conv.c[i], root.children[i]);
		}
		
	}

	void runOnConverted(Object root) {
		NonLayeredTidyAlgorithm.layout(root as Tree);
	}
}
