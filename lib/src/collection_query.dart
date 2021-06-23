part of model_notifier;

/// Class for sending queries to the collection.
///
/// Basically, it allows you to send the same query as Firestore.
///
/// Can be converted to a [String] by passing [value].
@immutable
class CollectionQuery {
  /// Class for sending queries to the collection.
  ///
  /// Basically, it allows you to send the same query as Firestore.
  ///
  /// Can be converted to a [String] by passing [value].
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

  /// Class for sending queries to the collection.
  ///
  /// Basically, it allows you to send the same query as Firestore.
  ///
  /// Can be converted to a [String] by passing [value].
  factory CollectionQuery.fromPath(String path) {
    if (path.isEmpty) {
      return CollectionQuery(path);
    }
    final uri = Uri.tryParse(path);
    if (uri == null) {
      return CollectionQuery(path);
    }
    final query = uri.queryParameters;

    return CollectionQuery(
      uri.path,
      key: _parseQuery(query, "key"),
      isEqualTo: _parseQuery(query, "equalTo"),
      isNotEqualTo: _parseQuery(query, "notEqualTo"),
      isLessThanOrEqualTo: _parseQuery(query, "endAt"),
      isGreaterThanOrEqualTo: _parseQuery(query, "startAt"),
      arrayContains: _parseQuery(query, "contains"),
      arrayContainsAny: _parseQuery(query, "containsAny", true),
      whereIn: _parseQuery(query, "whereIn", true),
      whereNotIn: _parseQuery(query, "whereNotIn", true),
      orderBy: () {
        if (query.containsKey("orderByDesc")) {
          return query["orderByDesc"];
        } else if (query.containsKey("orderByAsc")) {
          return query["orderByAsc"];
        }
      }(),
      order: () {
        if (query.containsKey("orderByDesc")) {
          return CollectionQueryOrder.desc;
        } else {
          return CollectionQueryOrder.asc;
        }
      }(),
      limit: _parseQuery(query, "limitToFirst"),
    );
  }

  static dynamic _parseQuery(Map<String, String> query, String key,
      [bool isArray = false]) {
    if (!query.containsKey(key)) {
      return null;
    }
    final value = query[key];
    if (value.isEmpty) {
      return null;
    }
    if (isArray) {
      return value!.split(",").mapAndRemoveEmpty((item) => item.toAny());
    }
    return value.toAny();
  }

  /// Query path.
  final String path;

  /// Key for comparison.
  final String? key;

  /// Key to change the order.
  final String? orderBy;

  /// If the value of [key] is equal to this value, `true`.
  final dynamic isEqualTo;

  /// If the value of [key] is not equal to this value, `true`.
  final dynamic isNotEqualTo;
  // final dynamic isLessThan;
  /// If the value of [key] is less than this value, `true`.
  final dynamic isLessThanOrEqualTo;
  // final dynamic isGreaterThan;
  /// If the value of [key] is greater than this value, `true`.
  final dynamic isGreaterThanOrEqualTo;

  /// If this value is in the [key] array, `true`.
  final dynamic arrayContains;

  /// If the [key] array contains one of these values, `true`.
  final DynamicList? arrayContainsAny;

  /// If the value of [key] is equal to one of these values, `true`.
  final DynamicList? whereIn;

  /// If the value of [key] is not equal to all of these values, `true`.
  final DynamicList? whereNotIn;
  // final bool? isNull;
  /// Specify ascending or descending order.
  final CollectionQueryOrder order;

  /// Limit the number to be acquired.
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

  /// Convert all Query to [String] parameters.
  String get value {
    assert(
      (key == null &&
              (isEqualTo == null &&
                  isNotEqualTo == null &&
                  isLessThanOrEqualTo == null &&
                  isGreaterThanOrEqualTo == null &&
                  arrayContains == null &&
                  arrayContainsAny == null &&
                  whereIn == null &&
                  whereNotIn == null)) ||
          (key != null &&
              (isEqualTo != null ||
                  isNotEqualTo != null ||
                  isLessThanOrEqualTo != null ||
                  isGreaterThanOrEqualTo != null ||
                  arrayContains != null ||
                  arrayContainsAny != null ||
                  whereIn != null ||
                  whereNotIn != null)),
      "If you want to specify a condition, please specify [key].",
    );
    if (key.isEmpty) {
      return path;
    }
    final tmp = "$path?key=$key";
    if (isEqualTo != null) {
      return _limit(_order("$tmp&equalTo=$isEqualTo"));
    } else if (isNotEqualTo != null) {
      return _limit(_order("$tmp&notEqualTo=$isNotEqualTo"));
    } else if (isLessThanOrEqualTo != null) {
      return _limit(_order("$tmp&endAt=$isLessThanOrEqualTo"));
    } else if (isGreaterThanOrEqualTo != null) {
      return _limit(_order("$tmp&startAt=$isGreaterThanOrEqualTo"));
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

  static bool _filter(
    Map<String, String> parameters,
    DynamicMap? data,
  ) {
    if (data.isEmpty) {
      return false;
    }
    if (!parameters.containsKey("key")) {
      return true;
    }
    final key = parameters["key"]!;
    if (!data.containsKey(key)) {
      return false;
    }
    if (parameters.containsKey("equalTo")) {
      return data![key] == parameters["equalTo"].toAny();
    }
    if (parameters.containsKey("notEqualTo")) {
      return data![key] != parameters["noteEqualTo"].toAny();
    }
    if (parameters.containsKey("startAt")) {
      return data![key] >= parameters["startAt"].toAny();
    }
    if (parameters.containsKey("endAt")) {
      return data![key] <= parameters["endAt"].toAny();
    }
    if (parameters.containsKey("contains")) {
      final list = data![key];
      if (list is! List) {
        return false;
      }
      return list.contains(parameters["contains"].toAny());
    }
    if (parameters.containsKey("containsAny")) {
      final list = data![key];
      if (list is! List) {
        return false;
      }
      final any = parameters["contains"]
          .toString()
          .split(",")
          .mapAndRemoveEmpty((item) => item.toAny());
      return list.any((e) => e == any);
    }
    if (parameters.containsKey("whereIn")) {
      final val = data![key];
      final any = parameters["whereIn"]
          .toString()
          .split(",")
          .mapAndRemoveEmpty((item) => item.toAny());
      return any.contains(val);
    }
    if (parameters.containsKey("whereNotIn")) {
      final val = data![key];
      final any = parameters["whereNotIn"]
          .toString()
          .split(",")
          .mapAndRemoveEmpty((item) => item.toAny());
      return !any.contains(val);
    }
    return true;
  }

  /// Convert the collection query from [DynamicMap].
  static CollectionQuery? _fromMap(DynamicMap map) {
    if (map.isEmpty || !map.containsKey("path")) {
      return null;
    }

    return CollectionQuery(
      map.get("path", ""),
      key: map.get<String?>("key", null),
      isEqualTo: map.get<dynamic>("equalTo", null),
      isNotEqualTo: map.get<dynamic>("notEqualTo", null),
      isLessThanOrEqualTo: map.get<dynamic>("endAt", null),
      isGreaterThanOrEqualTo: map.get<dynamic>("startAt", null),
      arrayContains: map.get<dynamic>("contains", null),
      arrayContainsAny: map.get<List?>("containsAny", null),
      whereIn: map.get<List?>("whereIn", null),
      whereNotIn: map.get<List?>("whereNotIn", null),
      order: CollectionQueryOrder.values.firstWhere(
          (e) => e.index == map.get("order", CollectionQueryOrder.asc.index)),
      limit: map.get<int?>("limit", null),
      orderBy: map.get<String?>("orderBy", null),
    );
  }

  /// Convert the collection query to [DynamicMap].
  DynamicMap toMap() {
    return <String, dynamic>{
      "path": path,
      if (key.isNotEmpty) "key": key,
      if (isEqualTo != null) "equalTo": isEqualTo,
      if (isNotEqualTo != null) "notEqualTo": isNotEqualTo,
      if (isLessThanOrEqualTo != null) "endAt": isLessThanOrEqualTo,
      if (isGreaterThanOrEqualTo != null) "startAt": isGreaterThanOrEqualTo,
      if (arrayContains != null) "contains": arrayContains,
      if (arrayContainsAny.isNotEmpty) "containsAny": arrayContainsAny,
      if (whereIn.isNotEmpty) "whereIn": whereIn,
      if (whereNotIn.isNotEmpty) "whereNotIn": whereNotIn,
      "order": order.index,
      if (limit != null) "limit": limit,
      if (orderBy.isNotEmpty) "orderBy": orderBy,
    };
  }
}

/// Specifies the order in which queries are ordered.
enum CollectionQueryOrder {
  /// Ascending order.
  asc,

  /// Descending order.
  desc,
}

extension CollectionQueryDynamicMapExtensions on DynamicMap {
  /// Convert the collection query from [DynamicMap].
  CollectionQuery? toCollectionQuery() {
    return CollectionQuery._fromMap(this);
  }
}
