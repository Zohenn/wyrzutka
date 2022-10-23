dynamic deepCopy(dynamic value){
  if(value is Iterable){
    return value.map((e) => deepCopy(e));
  }
  if(value is Map){
    return value.map((key, value) => MapEntry(key, deepCopy(value)));
  }
  return value;
}