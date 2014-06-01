part of xmlrpc;

/**
 * Represents an un/successful response.
 * See [RpcRequest] for the detailed description of parameter's types.
 */
class RpcResponse {
  /**
   * The main state of the request.
   */
  bool isSuccess;

  List params = [];

  /**
   * Creates new response from scratch.
   * Use [successful] flag for the initial state of the request.
   */
  RpcResponse([this.isSuccess=true]);

  factory RpcResponse.fault(int faultCode, String faultString) {
    new RpcResponse(false)
       ..params.add({
          faultCode: faultCode,
          faultString: faultString
        });
  }

  /**
   * Parses an external response from text.
   */
  factory RpcResponse.fromXmlString(String body) {
    var resultNode = _parse(body).children.single;
    var res = new RpcResponse(resultNode.name.local != FAULT_NODE);

    if (res.isSuccess) {
      res.params.addAll(resultNode.children.map(RpcParam.fromParamNode));
    }
    else {
      XmlElement valueNode = resultNode.children.single;
      XmlElement typeNode = valueNode.children.single;

      res.params.add(RpcParam.fromXmlElement(typeNode));
    }
    return res;
  }

  @override
  String toString() {
    List<XmlElement> content = [];

    if (!isSuccess) {
      assert(params.length < 2);
    }

    if (params.length > 0) {
      Iterable<XmlElement> res = params.map((param) {
        var transformedParam = RpcParam.valueToXml(param);

        if (isSuccess) {
          return new XmlElement(new XmlName('param'), [], [
            new XmlElement(new XmlName('value'), [], [transformedParam])
          ]);
        } else {
          return new XmlElement(new XmlName('value'), [], [transformedParam]);
        }
      });

      content.add(
          new XmlElement(new XmlName(isSuccess ? 'params' : 'fault'), [], res)
      );
    }

    return new XmlDocument([
      new XmlProcessing('xml', XML_HEADER),
      new XmlElement(new XmlName('methodResponse'), [], content)
    ]).toString();
  }
}
