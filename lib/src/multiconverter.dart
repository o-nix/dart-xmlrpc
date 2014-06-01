library multiconverter;

import 'dart:mirrors';


class Multiconverter {
  final Map<Object, Function> _converters;

  Multiconverter(this._converters);

  Function _detectApplicableClass(ClassMirror currentClass) {
    if (currentClass == null || currentClass.reflectedType == Object)
      return null;

    var converter =  _converters[currentClass.reflectedType];

    if (converter == null) {
      if (currentClass.superclass != currentClass)
        converter = _detectApplicableClass(currentClass.superclass);

      if (converter == null) {
        if (currentClass.mixin != currentClass)
          converter = _detectApplicableClass(currentClass.mixin);
      }

      if (converter == null) {
        for (var iface in currentClass.superinterfaces) {
          if (iface != currentClass) {
            converter = _detectApplicableClass(iface);

            if (converter != null)
              return converter;
          }
        }

        return null;
      }
    }

    return converter;
  }

  Function getConverter(Object value) {
    var converter = _converters[value];

    if (converter == null)
      converter = _detectApplicableClass(reflect(value).type);

    return converter;
  }
}
