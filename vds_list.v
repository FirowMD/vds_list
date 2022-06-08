module vds_list

struct VdsListNode<T> {
mut:
	data T
	next &VdsListNode<T> = 0
	prev &VdsListNode<T> = 0
}

struct VdsListIter<T> {
mut:
	node &VdsListNode<T> = 0
}

pub struct VdsList<T> {
mut:
	head &VdsListNode<T> = 0
	tail &VdsListNode<T> = 0
	iter &VdsListIter<T> = 0
	len i64
}

pub fn (list VdsList<T>) is_empty() bool {
	return list.len == 0
}

pub fn (list VdsList<T>) len() i64 {
	return list.len
}

pub fn (mut list VdsList<T>) first() ?T {
	if list.is_empty() {
		return error('List is empty')
	}

	if list.iter == voidptr(0) {
		list.iter = &VdsListIter<T>{}
	}

	list.iter.node = list.head
	return list.next()
}

pub fn (mut list VdsList<T>) next() ?T {
	if list.iter == voidptr(0) || list.iter.node == voidptr(0) {
		return none
	}

	defer {
		list.iter.node = list.iter.node.next
	}

	return list.iter.node.data
}

//
// Legacy
//

pub fn (mut list VdsList<T>) push_back(item T) {
	mut new_node := &VdsListNode<T>{
		data: item
	}

	if list.is_empty() {
		list.head = new_node
		list.tail = new_node
	} else {
		list.tail.next = new_node
		new_node.prev = list.tail
		list.tail = new_node
	}

	list.len += 1
}

pub fn (mut list VdsList<T>) push_front(item T) {
	mut new_node := &VdsListNode<T>{
		data: item
	}

	if list.is_empty() {
		list.head = new_node
		list.tail = new_node
	} else {
		list.head.prev = new_node
		new_node.next = list.head
		list.head = new_node
	}

	list.len += 1
}

pub fn (mut list VdsList<T>) pop_back() ?T {
	if list.is_empty() {
		return error('List is empty')
	}

	defer {
		list.len -= 1
	}

	if list.len == 1 {
		value := list.tail.data
		list.head = voidptr(0)
		list.tail = voidptr(0)
		return value
	}

	value := list.tail.data
	list.tail.prev.next = voidptr(0)
	list.tail = list.tail.prev

	return value
}

pub fn (mut list VdsList<T>) pop_front() ?T {
	if list.is_empty() {
		return error('List is empty')
	}

	defer {
		list.len -= 1
	}

	if list.len == 1 {
		value := list.head.data
		list.head = voidptr(0)
		list.tail = voidptr(0)
		return value
	}

	value := list.head.data
	list.head.next.prev = voidptr(0)
	list.head = list.head.next

	return value
}

pub fn (mut list VdsList<T>) insert(idx i64, item T) ? {
	if idx < 0 || idx > list.len {
		return error('Index out of bounds')
	} else if idx == list.len {
		list.push_front(item)
	} else if idx == list.len {
		list.push_back(item)
	} else if idx <= list.len / 2 {
		list.insert_front(idx, item)
	} else {
		list.insert_back(idx, item)
	}
}

fn (mut list VdsList<T>) insert_back(idx i64, item T) {
	mut node := list.node(idx + 1)
	mut prev := node.prev

	new := &VdsListNode<T>{
		data: item
		next: node
		prev: prev
	}

	node.prev = new
	prev.next = new
	list.len += 1
}

fn (mut list VdsList<T>) insert_front(idx i64, item T) {
	mut node := list.node(idx - 1)
	mut next := node.next

	new := &VdsListNode<T>{
		data: item
		next: next
		prev: node
	}

	node.next = new
	node.prev = new
	list.len += 1
}

fn (list &VdsList<T>) node(idx i64) &VdsListNode<T> {
	if idx <= list.len / 2 {
		mut node := list.head
		for h := 0; h < idx; h += 1 {
			node = node.next
		}
		return node
	}

	mut node := list.tail
	for t := list.len - 1; t >= idx; t -= 1 {
		node = node.prev
	}
	
	return node
}

pub fn (list &VdsList<T>) index(item T) ?i64 {
	mut hn := list.head
	mut tn := list.tail
	for h, t := 0, list.len - 1; h <= t; {
		if hn.data == item {
			return h
		} else if tn.data == item {
			return t
		}
		h += 1
		hn = hn.next
		t -= 1
		tn = tn.prev
	}
	return none
}

pub fn (mut list VdsList<T>) delete(idx i64) {
	if idx < 0 || idx >= list.len {
		return
	} else if idx == 0 {
		list.pop_front() or {}
		return
	} else if idx == list.len - 1 {
		list.pop_back() or {}
		return
	}

	mut node := list.node(idx)
	node.prev.next = node.next
	node.next.prev = node.prev
	list.len -= 1
}

pub fn (list VdsList<T>) str() string {
	mut result_array := []T{}
	mut node := list.head
	for unsafe { node != 0 } {
		result_array << node.data
		node = node.next
	}
	return result_array.str()
}

//
// Initialization
//

fn init() {
	// Initialize the module.
	// This is called once when the module is loaded.
}
