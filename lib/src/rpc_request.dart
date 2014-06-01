part of xmlrpc;
/**
 * The method name.
*
 *     <methodCall>
 *         <methodName>...</methodName>
 *     </methodCall>
 */


/**
 * Represents all the data that is/should be passed.
 * The parameter list can be filled with any legal _Dart_ value.
 *
 * The conversion table is bidirectional:
 *
 * `string`, `int`, `bool`, `double` <-> `<type>value</type>`
 *
 * `new DateTime()` <-> `<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>`
 *
 * `null` <-> `<nil />`
 *
 * `new List()` <-> `<array><data><value>typeValue</value></data></array>`
 *
 * `Map<KeyType, ValueType>` <-> `<struct><member><name>keyType.toString()</name><value><string>valueType</string></value></member></struct>`
 *
 * `new List<int>()` <-> `<base64>somedata</base64>`
 */
class RpcRequest {
  List params = [];
  String method;

  /**
   * Constructs an empty request.
   */
  RpcRequest([String this.method, List this.params]) {
    if (this.params == null) {
      this.params = new List();
    }
  }

  /**
   * Constructs a request from the given text.
   * The XML header `<?xml?>` is optional and ignored.
   */
  factory RpcRequest.fromXmlString(String body) {
    XmlElement root = _parse(body);

    assert(root.name.local == METHOD_CALL_NODE);

    var req = new RpcRequest(_getMethodNode(root).children[0].text);
    req.params
          ..clear()
          ..addAll(_getParamsNode(root).children.map(RpcParam.fromParamNode));
    return req;
  }

  /**
   * Returns a string representation for the request.
   */
  @override
  String toString() {
    return new XmlDocument([
      new XmlProcessing('xml', XML_HEADER),
      new XmlElement(new XmlName(METHOD_CALL_NODE), [], [
        new XmlElement(new XmlName(METHOD_NAME_NODE), [], [
          new XmlText(method)
        ]),
        new XmlElement(new XmlName(PARAMS_NODE), [], params
            .map(RpcParam.valueToXml).map((XmlElement elem) {
                return new XmlElement(new XmlName(PARAM_NODE), [], [
                  new XmlElement(new XmlName(VALUE_NODE), [], [elem])
                ]);
            })
        )
      ])
    ]).toString();
  }

  static XmlElement _getMethodNode(XmlElement root) =>
      root.findElements(METHOD_NAME_NODE).single;

  static XmlElement _getParamsNode(XmlElement root) =>
      root.findElements(PARAMS_NODE).single;
}
