part of xmlrpc;

/**
 *
 */
class RpcResponse extends _ParamsIterationSupport {
	bool isSuccess;

	@override
	Iterator<Object> get iterator =>
		new _ParamsIterator(this);

	XmlElement _root;
	List _params = [];

	RpcResponse({bool successful: true}) {
		isSuccess = successful;
		_root = new XmlElement(RESPONSE_NODE, elements: [new XmlElement(isSuccess ? PARAMS_NODE : FAULT_NODE)]);
	}

	RpcResponse.fromText(String body) {
		_root = XML.parse(body);
		var resultNode = _getResultNode();

		isSuccess = resultNode.name != FAULT_NODE;

		if (isSuccess) {
			resultNode.children.forEach((XmlElement paramNode) {
				_params.add(RpcParam.fromParamNode(paramNode));
			});
		}
		else {
			XmlElement valueNode = resultNode.children.single;
			XmlElement typeNode = valueNode.children.single;

			_params.add(RpcParam.fromXmlElement(typeNode));
		}
	}

	@override
	String toString() {
		var resultNode = _getResultNode();

		resultNode.children.clear();

		if (!isSuccess)
			assert(_params.length < 2);

		_params.forEach((Object param) {
			var transformedParam = RpcParam.valueToXml(param);

			if (isSuccess)
				resultNode.addChild(new XmlElement('param', elements: [transformedParam]));
			else
				resultNode.addChild(new XmlElement('value', elements: [transformedParam]));
		});

		return RpcRequest._toStringInternal(XML_HEADER + _root.toString());
	}

	XmlElement _getResultNode() =>
		_root.children.single;
}
