bool fromJsonStringYn(String? yn) {
  return yn == "y";
}

String toJsonStringYn(bool? yn) {
  return yn == true ? "y" : "n";
}

DateTime fromJsonDateTime(String strDate) {
  return DateTime.parse(strDate);
}

int fromJsonInt(dynamic val) {
  if (val == null) return 0;

  if (val.runtimeType == int) {
    return val;
  } else if (val.runtimeType == bool) {
    return val == true ? 1 : 0;
  } else if (val.runtimeType == String) {
    return int.parse(val);
  }

  return int.parse(val);
}

String toJsonInt(int? n) {
  return n == null ? '0' : n.toString();
}

double fromJsonDouble(dynamic val) {
  if (val == null) return 0;

  if (val.runtimeType == double) {
    return val;
  }

  return double.parse(val.toString());
}

String toJsonDouble(double n) {
  return n.toString();
}
