import 'package:quiver/core.dart';

import '../../general_algebraic_systems/number/base/number.dart';
import '../../general_algebraic_systems/number/exceptions/division_by_zero_exception.dart';
import 'base/tensor_base.dart';

/// Class for work with 4 dimensional tensor
class Tensor4 extends TensorBase {
  /// Creates [Tensor4] with data
  const Tensor4(this._data) : super(4);

  /// Generates [Tensor4] with [width], [length], [depth], [depth2]
  /// and values generated by [generator]
  factory Tensor4.generate(int width, int length, int depth, int depth2,
          num Function(num number) generator) =>
      TensorBase.generate(<String, int>{
        'width': width,
        'length': length,
        'depth': depth,
        'depth2': depth2
      }, generator)
          .toTensor4();

  final List<List<List<List<num>>>> _data;

  /// Gets width (columns) of this tensor
  int get width => _data[0].length;

  /// Gets length (rows) of this tensor
  int get length => _data.length;

  /// Gets depth of this tensor
  int get depth => _data[0][0].length;

  /// Gets depth2 of this tensor
  int get depth2 => _data[0][0][0].length;

  @override
  int get itemsCount => width * length * depth * depth2;

  @override
  Map<String, int> get shape => <String, int>{
        'width': width,
        'length': length,
        'depth': depth,
        'depth2': depth2
      };

  @override
  List<List<List<List<num>>>> get data => _data
      .map((r) => r.map((c) => c.map((h) => h.toList()).toList()).toList())
      .toList();

  @override
  Tensor4 map(num Function(num number) f) => Tensor4(data
      .map((r) =>
          r.map((c) => c.map((h) => h.map(f).toList()).toList()).toList())
      .toList());

  @override
  num reduce(num Function(num prev, num next) f) {
    var list = <num>[];
    for (final r in data) {
      for (final c in r) {
        for (final h in c) {
          list = list.followedBy(h).toList();
        }
      }
    }
    return list.reduce(f);
  }

  @override
  bool every(bool Function(num number) f) {
    var list = <num>[];
    for (final r in data) {
      for (final c in r) {
        for (final h in c) {
          list = list.followedBy(h).toList();
        }
      }
    }
    return list.every(f);
  }

  @override
  bool any(bool Function(num number) f) {
    var list = <num>[];
    for (final r in data) {
      for (final c in r) {
        for (final h in c) {
          list = list.followedBy(h).toList();
        }
      }
    }
    return list.any(f);
  }

  /// Gets item of this tensor from specific position
  ///
  /// - `length` -> row
  /// - `width` -> column
  /// - `depth` -> z axis
  /// - `depth2` -> u axis
  ///
  /// All positions may be in range from 1 to end inclusively.
  num itemAt(int length, int width, int depth, int depth2) =>
      data[length - 1][width - 1][depth - 1][depth2 - 1];

  /// Sets [value] to this tensor at specific position
  ///
  /// - `length` -> row
  /// - `width` -> column
  /// - `depth` -> z axis
  /// - `depth2` -> u axis
  ///
  /// All position may be in range from 1 to end inclusively.
  num setItem(int length, int width, int depth, int depth2, num value) =>
      _data[length - 1][width - 1][depth - 1][depth2 - 1] = value;

  /// Add values of [other] to corresponding values of this tensor
  ///
  /// The tensors should be of the same dimension.
  @override
  Tensor4 operator +(Tensor4 other) {
    final t4 = copy();
    for (var l = 1; l <= length; l++) {
      for (var w = 1; w <= width; w++) {
        for (var d = 1; d <= depth; d++) {
          for (var dd = 1; dd <= depth2; dd++) {
            t4.setItem(l, w, d, dd,
                t4.itemAt(l, w, d, dd) + other.itemAt(l, w, d, dd));
          }
        }
      }
    }
    return t4;
  }

  /// Subtract values of [other] from corresponding values of this tensor
  ///
  /// The tensors should be of the same dimension.
  @override
  Tensor4 operator -(Tensor4 other) => this + -other;

  @override
  Tensor4 operator -() => map((v) => -v);

  /// Multiply this tensor by [other]
  ///
  /// [other] may be one of three types:
  ///     1. num (and subclasses)
  ///     2. Tensor4 (and subclasses)
  ///     3. Number (and subclasses)
  ///
  /// Otherwise returns `null`.
  @override
  Tensor4 operator *(Object other) {
    Tensor4 m;
    if (other is num) {
      m = copy().map((v) => v * other);
    } else if (other is Tensor4) {
      final t4 = copy();
      for (var l = 1; l <= length; l++) {
        for (var w = 1; w <= width; w++) {
          for (var d = 1; d <= depth; d++) {
            for (var dd = 1; dd <= depth2; dd++) {
              t4.setItem(l, w, d, dd,
                  t4.itemAt(l, w, d, dd) * other.itemAt(l, w, d, dd));
            }
          }
        }
      }
      m = t4;
    } else if (other is Number) {
      m = copy().map((v) => v * other.data);
    }
    return m;
  }

  /// Divide this tensor by number of by [other]
  @override
  Tensor4 operator /(Object other) {
    Tensor4 m;
    if (other is num) {
      if (other == 0) {
        throw DivisionByZeroException();
      }
      m = this * (1 / other);
    } else if (other is Number) {
      if (other.data == 0) {
        throw DivisionByZeroException();
      }
      m = this * (1 / other.data);
    }
    return m;
  }

  @override
  bool operator ==(Object other) =>
      other is Tensor4 && hashCode == other.hashCode;

  @override
  int get hashCode => hashObjects(_data);

  @override
  List<num> toList() {
    var list = <num>[];
    for (final length in data) {
      for (final width in length) {
        for (final depth in width) {
          list = list.followedBy(depth).toList();
        }
      }
    }
    return list;
  }

  @override
  Tensor4 copy() {
    final data = _data
        .map((r) => r.map((z) => z.map((u) => u.toList()).toList()).toList())
        .toList();
    return Tensor4(data);
  }

  @override
  String toString() => '$_data';
}
