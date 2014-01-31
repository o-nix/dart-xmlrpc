part of xmlrpc;

/**
 * Represents an un/successful response.
 * See [RpcRequest] for the detailed description of parameter's types.
 */
class RpcResponse extends _ParamsIterationSupport {
	/**
	 * The main state of the request.
	 */
	bool isSuccess;

	@override
	Iterator<Object> get iterator =>
		new _ParamsIterator(this);

	XmlElement _root;
	List _params = [];

	/**
	 * Creates new response from scratch.
	 * Use [successful] flag for the initial state of the request.
	 */
	RpcResponse({this.isSuccess: true}) {
		_root = _makeRoot();
	}

	/**
	 * Parses an external response from text.
	 */
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
		_root = _makeRoot();

		var resultNode = _getResultNode();

		resultNode.children.clear();

		if (!isSuccess) {
			assert(_params.length < 2);
		}

		_params.forEach((Object param) {
			var transformedParam = RpcParam.valueToXml(param);

			if (isSuccess)
				resultNode.addChild(new XmlElement('param', elements: [new XmlElement(VALUE_NODE, elements: [transformedParam])]));
			else
				resultNode.addChild(new XmlElement('value', elements: [transformedParam]));
		});

		return RpcRequest._toStringInternal(XML_HEADER + _root.toString());
	}

	XmlElement _makeRoot() =>
		new XmlElement(RESPONSE_NODE, elements: [new XmlElement(isSuccess ? PARAMS_NODE : FAULT_NODE)]);

	XmlElement _getResultNode() =>
		_root.children.single;
}
