part of model_notifier;

class CollectionQuery {
  const CollectionQuery(
    this.path, {
    this.key,
    this.isEqualTo,
    this.isNotEqualTo,
    // this.isLessThan,
    this.isLessThanOrEqualTo,
    // this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.order = CollectionQueryOrder.asc,
    this.limit,
    this.orderBy,
  });
  final String path;
  final String? key;
  final String? orderBy;
  final dynamic isEqualTo;
  final dynamic isNotEqualTo;
  // final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  // final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final List<dynamic>? whereNotIn;
  // final bool? isNull;
  final CollectionQueryOrder order;
  final int? limit;

  String _limit(String path) {
    if (limit == null) {
      return path;
    }
    return "$path&limitToFirst=$limit";
  }

  String _order(String path) {
    if (orderBy.isEmpty) {
      return path;
    }
    if (order == CollectionQueryOrder.asc) {
      return "$path&orderByAsc=$orderBy";
    } else {
      return "$path&orderByDesc=$orderBy";
    }
  }

  String get value {
    if (key.isEmpty) {
      return path;
    }
    final tmp = "$path?key=$key";
    if (isEqualTo != null) {
      return _limit(_order("$tmp&equalTo=$isEqualTo"));
    } else if (isNotEqualTo != null) {
      return _limit(_order("$tmp&notEqualTo=$isNotEqualTo"));
    } else if (isLessThanOrEqualTo != null) {
      return _limit(_order("$tmp&endAt=$value"));
    } else if (isGreaterThanOrEqualTo != null) {
      return _limit(_order("$tmp&startAt=$value"));
    } else if (arrayContains != null) {
      return _limit(_order("$tmp&contains=$arrayContains"));
    } else if (arrayContainsAny != null) {
      return _limit(_order(
          "$tmp&containsAny=${arrayContainsAny!.map((e) => e.toString()).join(",")}"));
    } else if (whereIn != null) {
      return _limit(_order(
          "$tmp&whereIn=${whereIn!.map((e) => e.toString()).join(",")}"));
    } else if (whereNotIn != null) {
      return _limit(_order(
          "$tmp&whereNotIn=${whereNotIn!.map((e) => e.toString()).join(",")}"));
    }
    return tmp;
  }
}

enum CollectionQueryOrder { asc, desc }
