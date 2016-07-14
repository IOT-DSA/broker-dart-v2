import "package:test/test.dart";
import "../lib/common.dart";

void main() {
  test('iteration', () {
    var list = new RefList<int, int>(0);
    List<RefListRef<int, int>> nodes = [];
    for (var i = 0; i < 5; ++i) {
      nodes.add(list.add(i));
    }
    var expected = 0;
    list.forEach((val) {
      expect(val, equals(expected));
      expected++;
    });
    expected = 0;
    list.forEachRef((node) {
      expect(node.value, expected, reason: "forEachNode");
      expected++;
    });

    expected = 0;
    list.forEachRef((node) {
      expect(node.value, expected, reason: "forEachNode Remove");
      node.remove();
      expected++;
    });
    expect(list.isEmpty(), true, reason: "list empty after remove");
    for (var i = 0; i < 5; ++i) {
      expect(nodes[i].removed, true, reason: "node has no list after remove");
    }
  });
  test('add remove during iteration 1', () {
    var list = new RefList<int, int>(0);
    List<RefListRef<int, int>> nodes = [];
    for (var i = 0; i < 10; ++i) {
      nodes.add(list.add(i));
    }

    var removeOrder = [0, 3, 2, 4, 7, 1, 9];
    var expectedValues = [0, 1, 2, 4, 5, 6, 8];
    var expectedIdx = 0;
    list.forEach((val) {
      expect(
          val, expectedValues[expectedIdx],
          reason: "forEachNode random Remove Add");
      nodes[removeOrder[expectedIdx]].remove();
      list.add(expectedIdx + 10);
      expectedIdx++;
    });

    expectedIdx = 0;
    expectedValues = [5, 6, 8, 10, 11, 12, 13, 14, 15, 16];
    list.forEach((val) {
      expect(
          val, expectedValues[expectedIdx],
          reason: "forEachNode random Remove Add");
      expectedIdx++;
    });
  });

  test('add remove during iteration 2', () {
    var list = new RefList<int, int>(0);
    List<RefListRef<int, int>> nodes = [];
    for (var i = 0; i < 10; ++i) {
      nodes.add(list.add(i));
    }

    // different order to check the last value
    var removeOrder = [0, 3, 2, 4, 7, 9, 8];
    var expectedValues = [0, 1, 2, 4, 5, 6, 8];
    var expectedIdx = 0;
    list.forEach((val) {
      expect(
          val, expectedValues[expectedIdx],
          reason: "forEachNode random Remove Add");
      nodes[removeOrder[expectedIdx]].remove();
      list.add(expectedIdx + 10);
      expectedIdx++;
    });

    expectedIdx = 0;
    expectedValues = [1, 5, 6, 10, 11, 12, 13, 14, 15, 16];
    list.forEach((val) {
      expect(
          val, expectedValues[expectedIdx],
          reason: "forEachNode random Remove Add");
      expectedIdx++;
    });
  });
}
