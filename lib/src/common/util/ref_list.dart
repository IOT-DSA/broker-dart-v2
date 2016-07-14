part of dsa.common;

typedef RemoveRefCallback<OwnerType, ValueType>(
    RefListRef<OwnerType, ValueType> ref);

/// a set type implemented as linked list
class RefListBase<OwnerType, ValueType> {
  OwnerType _owner;

  OwnerType get owner => _owner;
  RemoveRefCallback _removeCallback;

  RefListRef<OwnerType, ValueType> _head;

  bool isEmpty() {
    return _head._next == _head;
  }

  bool isNotEmpty() {
    return _head._next != _head;
  }

  RefListRef<OwnerType, ValueType> add(ValueType val) {
    RefListRef<OwnerType, ValueType> ref =
    new RefListRef<OwnerType, ValueType>(this, val);
    _add(ref);
    return ref;
  }

  void _add(RefListRef<OwnerType, ValueType> ref) {
    ref._next = _head;
    ref._prev = _head._prev;
    _head._prev._next = ref;
    _head._prev = ref;
  }

  RefListRef<OwnerType, ValueType> _iter;
  RefListRef<OwnerType, ValueType> _iterEnd;

  void _remove(RefListRef<OwnerType, ValueType> ref) {
    if (ref._list != this) return;

    if (ref == this._iter) {
      if (this._iter == this._iterEnd) {
        this._iter = null;
        this._iterEnd = null;
      } else {
        this._iter = this._iter._next;
      }
    } else if (ref == this._iterEnd) {
      if (this._iter == this._iterEnd) {
        this._iter = null;
        this._iterEnd = null;
      } else {
        this._iterEnd = this._iterEnd._prev;
      }
    }
    ref._next._prev = ref._prev;
    ref._prev._next = ref._next;
    ref._list = null;

    if (_removeCallback != null) {
      _removeCallback(ref);
    }
  }

  void forEach(callback(ValueType ValueType)) {
    if (_iter != null) throw 'Concurrent RefLink Iteration';

    if (_head._next == _head) {
      return;
    }
    _iter = _head._next;
    _iterEnd = _head._prev;

    while (_iter != null) {
      var current = this._iter;
      if (_iter == _iterEnd) {
        _iter = null;
        _iterEnd = null;
      } else {
        _iter = _iter._next;
      }
      callback.call(current.value);
    }
  }

  void forEachRef(callback(RefListRef<OwnerType, ValueType> ref)) {
    if (_iter != null) throw 'Concurrent RefLink Iteration';

    if (_head._next == _head) {
      return;
    }
    _iter = _head._next;
    _iterEnd = _head._prev;

    while (_iter != null) {
      var current = this._iter;
      if (_iter == _iterEnd) {
        _iter = null;
        _iterEnd = null;
      } else {
        _iter = _iter._next;
      }
      callback.call(current);
    }
    _iter = null;
  }

  /// [callback] returns true when target node is found
  /// [firstWhere] return the node that's found, or null if not found
  RefListRef<OwnerType, ValueType> firstWhere(
      bool predicate(RefListRef<OwnerType, ValueType> ref)) {
    if (_iter != null) throw 'Concurrent RefLink Iteration';

    if (_head._next == _head) {
      return null;
    }
    _iter = _head._next;
    _iterEnd = _head._prev;

    while (_iter != null) {
      var current = this._iter;
      if (_iter == _iterEnd) {
        _iter = null;
        _iterEnd = null;
      } else {
        _iter = _iter._next;
      }
      if (predicate.call(current)) {
        _iter = null;
        return current;
      }
    }
    _iter = null;
    return null;
  }

  // fast way to remove ref, because its prev and next no longer need to be maintained
  void _clearNode(RefListRef<OwnerType, ValueType> ref) {
    ref._list = null;
  }

  void clear() {
    if (_iter != null)
      throw 'clear() Ignored during RefLink Iteration';

    forEachRef(_clearNode);
    _head._prev = _head;
    _head._next = _head;
  }
}

class RefListRef<OwnerType, ValueType> {
  RefListBase<OwnerType, ValueType> _list;

  OwnerType get owner {
    if (_list != null) {
      return _list.owner;
    }
    return null;
  }

  bool get removed {
    return _list == null;
  }

  RefListRef<OwnerType, ValueType> _next;
  RefListRef<OwnerType, ValueType> _prev;
  ValueType value;

  RefListRef(this._list, this.value);

  void remove() {
    if (_list != null) {
      _list._remove(this);
    }
  }
}

class RefList<OwnerType, ValueType> extends Object
    with RefListBase<OwnerType, ValueType> {
  RefList(OwnerType owner,
      [removeCallback(RefListRef<OwnerType, ValueType> ref) = null]) {
    _owner = owner;
    _removeCallback = removeCallback;

    _head = new RefListRef<OwnerType, ValueType>(this, null);
    _head._prev = _head;
    _head._next = _head;
  }
}

/// ManagedSet maintains destroyable content, and destroy the content when it's removed
class ManagedRefList<OwnerType, ValueType extends IDestroyable> extends Object
    with RefListBase<OwnerType, ValueType> {
  ManagedRefList(OwnerType owner,
      [removeCallback(RefListRef<OwnerType, ValueType> ref) = null]) {
    _owner = owner;
    _removeCallback = removeCallback;

    _head = new RefListRef<OwnerType, ValueType>(this, null);
    _head._prev = _head;
    _head._next = _head;
  }

  @override
  void _remove(RefListRef<OwnerType, ValueType> ref) {
    super._remove(ref);
    ref.value.destroy();
  }

  @override
  void _clearNode(RefListRef<OwnerType, ValueType> ref) {
    ref._list = null;
    ref.value.destroy();
  }
}
