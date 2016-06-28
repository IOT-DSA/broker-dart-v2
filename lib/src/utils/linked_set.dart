part of dsa.broker.utils;

/// a set type implemented as linked list
class LinkedSetBase<OwnerType, ValueType> {
  OwnerType _owner;
  OwnerType get owner => _owner;

  LinkedSetNode<OwnerType, ValueType> _head;

  bool isEmpty() {
    return _head._next == _head;
  }

  bool isNotEmpty() {
    return _head._next != _head;
  }

  LinkedSetNode<OwnerType, ValueType> add(ValueType val) {
    LinkedSetNode<OwnerType, ValueType> node =
        new LinkedSetNode<OwnerType, ValueType>(this, val);
    _add(node);
    return node;
  }

  void _add(LinkedSetNode<OwnerType, ValueType> node) {
    node._next = _head;
    node._prev = _head._prev;
    _head._prev._next = node;
    _head._prev = node;
  }

  LinkedSetNode<OwnerType, ValueType> _iterator;
  void _remove(LinkedSetNode<OwnerType, ValueType> node) {
    if (node == _iterator) {
      _iterator = _iterator._next;
    }
    node._next._prev = node._next;
    node._prev._next = node._prev;
    node._list = null;
  }

  void forEach(callback(ValueType ValueType)) {
    if (_iterator != null) throw 'Concurrent LinkedSetBase Iteration';

    _iterator = _head._next;
    while (_iterator != _head) {
      LinkedSetNode<OwnerType, ValueType> current = _iterator;
      _iterator = _iterator._next;
      callback(current.value);
    }
    _iterator = null;
  }

  void forEachNode(callback(LinkedSetNode<OwnerType, ValueType> node)) {
    if (_iterator != null) throw 'Concurrent LinkedSetBase Iteration';

    _iterator = _head._next;
    while (_iterator != _head) {
      LinkedSetNode<OwnerType, ValueType> current = _iterator;
      _iterator = _iterator._next;
      callback(current);
    }
    ;
    _iterator = null;
  }

  // fast way to remove node, because its prev and next no longer need to be maintained
  void _clearNode(LinkedSetNode<OwnerType, ValueType> node) {
    node._list = null;
  }

  void clear() {
    if (_iterator != null)
      throw 'clear() Ignored during LinkedSetBase Iteration';

    forEachNode(_clearNode);
    _head._prev = _head;
    _head._next = _head;
  }
}

class LinkedSetNode<OwnerType, ValueType> {
  LinkedSetBase<OwnerType, ValueType> _list;

  OwnerType get owner {
    if (_list != null) {
      return _list.owner;
    }
    return null;
  }

  bool get removed {
    return _list == null;
  }

  LinkedSetNode<OwnerType, ValueType> _next;
  LinkedSetNode<OwnerType, ValueType> _prev;
  ValueType value;

  LinkedSetNode(this._list, this.value);

  void remove() {
    if (_list != null) {
      _list._remove(this);
      _list = null;
    }
  }
}

class LinkedSet<OwnerType, ValueType> extends Object
    with LinkedSetBase<OwnerType, ValueType> {
  LinkedSet(OwnerType owner) {
    _owner = owner;
    _head = new LinkedSetNode<OwnerType, ValueType>(this, null);
    _head._prev = _head;
    _head._next = _head;
  }
}

/// ManagedSet maintains destroyable content, and destroy the content when it's removed
class ManagedSet<OwnerType, ValueType extends IDestroyable> extends Object
    with LinkedSetBase<OwnerType, ValueType> {
  LinkedSet(OwnerType owner) {
    _owner = owner;
    _head = new LinkedSetNode<OwnerType, ValueType>(this, null);
    _head._prev = _head;
    _head._next = _head;
  }

  @override
  void _remove(LinkedSetNode<OwnerType, ValueType> node) {
    super._remove(node);
    node.value.destroy();
  }

  @override
  void _clearNode(LinkedSetNode<OwnerType, ValueType> node) {
    node._list = null;
    node.value.destroy();
  }
}
