---
title: tree学习
date: 2018-11-12 13:36:55
tags: 数据结构
---

# tree

## 构造

树的构造很简单，节点的思想。

```
class TreeNode{
	Object element;
	TreeNode firstChild;
	TreeNode nextSibling;
}
```

## 示意图

![树示意图](/images/数据结构/tree图1.png)

## 先序遍历

先序遍历的思想是对节点的处理工作在他的子节点处理之前执行，显示结果为D->L->R
对示意图的先序遍历，结果为：ABDECFG


## 中序遍历

中序遍历的思想是先对左节点优先处理，之后在处理自己，最后处理右节点，显示结果为 L->D->R
对示意图的中序遍历，结果为：DBEAFCG

## 后序遍历

后序遍历的思想是优先处理子节点，最后处理自己，子节点的处理优先是左节点，显示结果为L->R->D
对示意图的后序遍历，结果为：DEBFGCA

# 二叉树

## 构造

```
class BinaryNode{
	Object element;
	BinaryNode left;
	BinaryNode right;
}
```

二叉树是一棵树，每个节点都不能有多于两个的儿子，平均深度为O(根号N)

# 二叉查找树

二叉查找树对于树中的每个节点X，它的左子树中所有的项的值小于X中的项，右子树种所有项的值大于X的值

## 构造

```
public class BinarySearchTree<T extends Comparable<? super T>>{
	/*
	* 构造函数
	*/
	private static class BinaryNode<T>{
		BinaryNode(T element){
			this(element, null, null);
		}
		BinaryNode(T element, Binary<T> left, BinaryNode<T> right){
			this.element = element;
			this.left = left;
			this.right = right;
		}
		T element;
		Binary<T> left;
		Binary<T> right;
	}

	/*
	* 初始节点
	*/
	private BinaryNode<T> root;

	/*
	* 初始化
	*/
	public BinarySearchTree(){
		root = null;
	}

	/*
	* 置空操作
	*/
	public void makeEmpty(){
		root = null;
	}

	/*
	* 判空操作
	*/
	public void isEmpty(){
		return root == null;
	}

	/*
	* 判断是否包含
	*/
	public boolean contains(T x){
		return contains(x, root);
	}
	/*
	* 判断思想：先和root对比，小就和左节点比较，大就和右节点比较，相同就true，核心思想是递归，递归到最后空的时候就会判false
	*/
	private boolean contains(T x, BinaryNode<T> t){
		if(t == null){
			return false;
		}

		int compareResult = x.compareTo(t.element);

		if( compareResult < 0){
			return contains(x, left);
		}else if( compareResult > 0){
			return contains(x, right);
		}else{
			return true;
		}
	}

	/*
	* 寻找最小子节点
	*/
	public T findMin(){
		if (isEmpty()){
			throw new UnderflowException();
		}
		return findMin(root).element;
	}

	/*
	* 寻找思想：查找是否有左节点，如果有就继续遍历左节点，直到某个节点的左节点为null，此时该节点就是最小节点
	*/
	private BinaryNode<T> findMin(BinaryNode<T> t){
		if (t == null){
			return null;
		}else if(t.left == null){
			return t;
		}else{
			return findMin(t.left);
		}
	}

	/*
	* 寻找最大子节点
	*/
	public T findMax(){
		if(isEmpty()){
			throw new UnderflowException();
		}
		return findMax(root).element;
	}

	/*
	* 思想和寻找最小子节点一样
	*/
	private BinaryNode<T> findMax(BinaryNode<T> t){
		if (t == null){
			return null;
		}else if(t.right == null){
			return t;
		}else {
			return findMax(t.right);
		}
	}

	/*
	* 插入
	*/
	public void insert(T x){
		root = insert(x, root);
	}

	/*
	* 插入数值思想:仍然是和当前节点做比较，如果小就递归左节点，大就递归右节点，直到某个节点的左节点或者右节点不存在，此时就新建一个节点，插入。
	*/
	private BinaryNode<T> insert(T x, BinaryNode<T> t){
		if (t == null){
			return new BinaryNode<>(x, null, null);
		}
		int compareResult = x.compareTo(t.element);
		if (compareResult < 0){
			t.left = insert(x, t.left);
		}else if (compareResult > 0){
			t.right = insert(x, t.right);
		}else{
			;
		}
		return t;
	}

	/*
	* 删除
	*/
	public void remove(T x){
		root = remove(x, root);
	}

	/*
	* 删除的机制：当删除某个节点的时候，如果两个子节点都在，就需要将右侧的最小子节点放到该位置上面来，并且遍历删除右侧的最小子节点
	*/
	private BinaryNode<T> remove(T x, BinaryNode<T> t){
		if(t == null){
			return t;
		}
		int compareResult = x.compareTo(t.element);
		if (compareResult < 0){
			t.left = remove(x, t.left);
		}else if(compareResult > 0){
			t.right = remove(x, t.right);
		}else if(t.left != null && t.right != null){
			t.element = findMin(t.right).element;
			t.right = remove(t.element, t.right);
		}else{
			t = (t.left != null)? t.left : t.right;
		}
		return t;
	}

	public void printTree(){
		if (isEmpty()){
			System.out.println("Empty tree");
		}else{
			printTree(root);
		}
	}
	//中序遍历
	private void printTree(BinaryNode<T> t){
		if(t != null){
			printTree(t.left);
			System.out.println(t.element);
			printTree(t.right);
		}
	}
	
	//先序遍历
	private void printBeforeTree(BinaryNode<T> t){
		if(t != null){
			System.out.println(t.element);
			printBeforeTree(t.left);
			printBeforeTree(t.right);
		}
	}

	//后序遍历
	private void printAfterTree(BinaryNode<T> t){
		if(t != null){
			printAfterTree(t.left);
			printAfterTree(t.right);
			System.out.println(t.element);
		}
	}
	
	//层级遍历
	public void levelTravel(TreeNode<T> root){
		Queue<TreeNode<T>> q = new LinkedList<TreeNode<T>>();
		q.offer(root);
		while(!q.isEmpty()){
			TreeNode<T> temp = q.poll();
			System.out.println(temp);
			if(temp.leftChild != null){
				q.offer(temp.leftChild);
			}
			if(temp.rightChild != null){
				q.offer(temp.rightChild);
			}
		}
	}

	//求K层节点总数
	public int getNumForKLevel(TreeNode<T> root, int k){
		if(root == null || k < 1){
			return 0;
		}
		if(k == 1){
			return 1;
		}
		int leftNum = getNumForKLevel(root.left, k-1);
		int rightNum = getNumForKLevel(root.right, k-1);
		return leftNum + rightNum;
	}

	//求二叉树中叶子节点的个数
	public int getLeafNum(TreeNode<T> root){
		if(root == null){
			return 0;
		}
		if(root.leftChild == null && root.rightChild == null){
			return 1;
		}
		int leftNum = getLeafNum(root.leftChild);
		int rightNum = getLeafNum(root.rightChild);
		return leftNum + rightNum;
	}

	//交换根节点的左右子树
	public TreeNode<T> exchange(TreeNode<T> root){
		if(root == null){
			return null;
		}
		TreeNode<T> left = exchange(root.left);
		TreeNode<T> right = exchange(root.right);
		root.leftChild = right;
		root.rightChild = left;
		return root;
	}

	//查看node是否是root的子节点
	public boolean nodeIsChild(TreeNode<T> root, TreeNode<T> node){
		if(root == null || node == null){
			return false;
		}
		if(root == node){
			return true;
		}
		boolean isFind = nodeIsChild(root.leftChild, node);
		if(!isFind){
			isFind = nodeIsChild(root.rightChild, node);
		}
		return isFind;
	}

	//根据前序和中序构建二叉树
	public TreeNode<T> getTreeFromPreAndMid(List<T> pre, List<T> mid){
		if(pre == null || mid == null || pre.size() == 0 || mid.size == 0){
			return null;
		}
		if(pre.size() == 1){
			return new TreeNode<T>(pre.get(0));
		}
		TreeNode<T> root = new TreeNode<T>(pre.get(0));
		int index = 0;
		while(!mid.get(index ++).equals(pre.get(0)));//挪动到root的位置
		List<T> preLeft = new ArrayList<T>(index);
		List<T> midLeft = new ArrayList<T>(index);
		for(int i = 1; i < index; i ++){
			preLeft.add(pre.get(i));
		}
		for(int i = 0; i < index -1; i ++){
			midLeft.add(mid.get())
		}
		root.leftChild = getTreeFromPreAndMid(preLeft, midLeft);
		List<T> preRight = new ArrayList<T>(pre.size() - index - 1);
		List<T> midRight = new ArrayList<T>(pre.size() - index - 1);
		for(int i = 0; i <= pre.size() - index - 1; i ++){
			preRight.add(pre.get(index + i));
		}
		for(int i = 0; i <= pre.size() - index - 1; i ++){
			midRight.add(mid.get(index + i));
		}
		root.rightChild = getTreeFromPreAndMid(preRight, midRight);
		return root;
	}

	public boolean equals(TreeNode<T> node1, TreeNode<T> node2){
		if(node1 == null && node2 == null){
			return true;
		} else if(node1 == null || node2 == null){
			return false;
		}
		boolean isEqual = node1.value.equals(node2.value);
		boolean isLeftEqual = equals(node1.leftChild, node2.leftChild);
		boolean isRightEqual = equals(node1.rightChild, node2.rightChild);
		return isEqual && isLeftEqual && isRightEqual;
	}
}
```

# AVL树

平衡二叉树，即左右节点高度差不超过1的二叉树

## 构造函数

```
private static class AvlNode<AnyType>{
	AnyType element;
	AvlNode<AnyType> left;
	AvlNode<AnyType> right;
	int height;
	AvlNode(AnyType theElement){
		this(theElement, null, null);
	}
	AvlNode(AnyType theElement, AvlNode<AnyType> lt, AvlNode<AnyType> rt){
		element = theElement;
		left = lt;
		right = rt;
		height = 0;
	}
}
```

## 单旋过程

```
private AvlNode<AnyType> rotateWithLeftChild(AvlNode<AnyType> k2){
	AvlNode<AnyType> k1 = k2.left;
	k2.left = k1.right;
	k1.right = k2;
	k2.height = Math.max(height(k2.left), height(k2.right)) + 1;
	k1.height = Math.max(height(k1.left), k2.height) +1;
	return k1;
}
```

## 双旋过程

```
private AvlNode<AnyType> doubleWithLeftChild(AvlNode<AnyType> k3){
	k3.left = rotateWithRightChild(k3.left);
	return rotateWthLeftChild(k3);
}
```























