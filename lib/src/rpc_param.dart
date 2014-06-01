part of xmlrpc;

_isElement(XmlNode node) => node is XmlElement;

XmlElement _firstElementChild(XmlNode node) =>
  node.children.firstWhere(_isElement);

XmlElement _parse(String xml) =>
    parse(xml.replaceAll(new RegExp(r'>\s+<'), '><').trim()).rootElement;

class RpcParam {
  /**
   * The date format for the `<dateTime.iso8601 />` tag.
   */
  static String DATE_FORMAT = 'yMdTHH:mm:ss';

  static final _converter = new Multiconverter({
    int: (int value) =>
      new XmlElement(new XmlName('int'), [], [new XmlText(value.toString())]),

    bool: (bool value) =>
      new XmlElement(new XmlName('boolean'), [], [new XmlText(value.toString())]),

    double: (double value) =>
      new XmlElement(new XmlName('double'), [], [new XmlText(value.toString())]),

    DateTime: (DateTime value) =>
      new XmlElement(new XmlName(ISO_8601_NODE), [], [new XmlText(new DateFormat(DATE_FORMAT).format(value))]),

    UTF8.encode('').runtimeType: (List<int> binaryData) =>
      new XmlElement(new XmlName(BASE64_NODE), [], [new XmlText(CryptoUtils.bytesToBase64(binaryData))]),

    'boolean': (XmlElement elem) =>
      elem.text == 'true',

    'int': (XmlElement elem) =>
      int.parse(elem.text),

    'i4': (XmlElement elem) =>
      int.parse(elem.text),

    'double': (XmlElement elem) =>
      double.parse(elem.text),

    ISO_8601_NODE: (XmlElement elem) =>
      DateTime.parse(elem.text),

    'nil': (XmlElement elem) =>
      null,

    'base64': (XmlElement elem) =>
      CryptoUtils.base64StringToBytes(elem.text),

     // <array><data><value>1</value><value>2</value></data></array>
    'array': (XmlElement elem) {
      return elem.findElements('data').single.children
          .where(_isElement)
          .map((XmlElement elem) {
            return fromXmlElement(elem.children.single);
          }).toList();
    },

     // <struct><member><name>some</name><value><string>value</string></value></member></struct>
    'struct': (XmlElement elem) {
      var result = {};

      elem.children
        .where(_isElement)
        .forEach((XmlElement member) {
          var name = member.findElements(NAME_NODE).single.text;
          XmlElement valueNode = member.findElements(VALUE_NODE).single;

          result[name] = fromXmlElement(valueNode.children.single);
        });

      return result;
    },

    String: (String value) =>
      new XmlElement(new XmlName('string'), [], [new XmlText(value)]),

    'string': (XmlElement elem) =>
      elem.text,

    Iterable: (Iterable list) =>
      new XmlElement(new XmlName(ARRAY_NODE), [], [
        new XmlElement(new XmlName(DATA_NODE), [],
          list.map((Object item) =>
            new XmlElement(new XmlName(VALUE_NODE), [], [RpcParam.valueToXml(item)])
          )
        )
      ]),

    {}.runtimeType: (Map map) =>
      new XmlElement(new XmlName(STRUCT_NODE), [], map.keys.map((Object key) =>
        new XmlElement(new XmlName(MEMBER_NODE), [], [
          new XmlElement(new XmlName(NAME_NODE), [], [
            new XmlText(key.toString())
          ]),
          new XmlElement(new XmlName(VALUE_NODE), [], [
            RpcParam.valueToXml(map[key])
          ])
        ])
      )),

    null: (bool value) =>
      new XmlElement(new XmlName('nil'), [], [])
  });

  /**
   * Returns an Object representation for a value from an XML node which wraps an XML-RPC param.
   *
   * The node should have a structure like:
   *
   *     <param>
   *         <value>...</value>
   *     </param>
   */
  static Object fromParamNode(XmlElement node) {
    assert(node.name.local == PARAM_NODE);

    XmlElement valueNodeElem = _firstElementChild(node);

    assert(valueNodeElem.name.local == VALUE_NODE);

    return fromXmlElement(_firstElementChild(valueNodeElem));
  }

  /**
   * Returns an Object representation for a value from an XML node.
   *
   * The node should have a structure like:
   *
   *     <int>...</int>
   */
  static Object fromXmlElement(XmlElement node) {
    Function converter = _converter.getConverter(node.name.local);

    assert(converter != null);

    return converter(node);
  }

  /**
   * Returns an XML node which wraps all the nodes generated for the value.
   */
  static XmlElement valueToXml(Object value) {
    Function converter = _converter.getConverter(value);

    assert(converter != null);

    return converter(value);
  }
}
