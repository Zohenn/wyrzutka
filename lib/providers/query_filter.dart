import 'package:cloud_firestore/cloud_firestore.dart';

enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull
}

class QueryFilter {
  QueryFilter(this.field, this.operator, this.value);

  String field;
  FilterOperator operator;
  Object? value;

  List<Object?> get _valueAsList => value as List<Object?>;

  Query<T> apply<T>(Query<T> query){
    switch(operator){
      case FilterOperator.isEqualTo:
        return query.where(field, isEqualTo: value);
      case FilterOperator.isNotEqualTo:
        return query.where(field, isNotEqualTo: value);
      case FilterOperator.isLessThan:
        return query.where(field, isLessThan: value);
      case FilterOperator.isLessThanOrEqualTo:
        return query.where(field, isLessThanOrEqualTo: value);
      case FilterOperator.isGreaterThan:
        return query.where(field, isGreaterThan: value);
      case FilterOperator.isGreaterThanOrEqualTo:
        return query.where(field, isGreaterThanOrEqualTo: value);
      case FilterOperator.arrayContains:
        return query.where(field, arrayContains: value);
      case FilterOperator.arrayContainsAny:
        return query.where(field, arrayContainsAny: _valueAsList);
      case FilterOperator.whereIn:
        return query.where(field, whereIn: _valueAsList);
      case FilterOperator.whereNotIn:
        return query.where(field, whereNotIn: _valueAsList);
      case FilterOperator.isNull:
        return query.where(field, isNull: value as bool?);
    }
  }
}
