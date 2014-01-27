part of xmlrpc;

/**
 * The main class.
 */
class RpcRequest {
	/**
	 * The parameter list.
	 * Can be filled with any legal _Dart_ value.
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
	List params = [];

	static const _METHOD_CALL = 'methodCall';
	static const _METHOD_NAME = 'methodName';
	static const _PARAMS_NODE = 'params';
	static const _XML_HEADER = '<?xml version="1.0"?>';

	XmlElement _root;

	/**
	* The method name.
	*
	*     <methodCall>
	*         <methodName>...</methodName>
	*     </methodCall>
	*/
	String get method =>
		_getMethodNode().text;

	set method(String method) {
		var methodNode = _getMethodNode();

		methodNode.children.clear();
		methodNode.addChild(new XmlText(method));
	}

	XmlElement _getMethodNode() =>
		_root.query(_METHOD_NAME).single;

	XmlElement _getParamsNode() =>
		_root.query(_PARAMS_NODE).single;

	/**
	* Constructs an empty request.
	*/
	RpcRequest() {
		_root = new XmlElement(_METHOD_CALL, elements: [
			new XmlElement(_METHOD_NAME),
			new XmlElement(_PARAMS_NODE)
		]);
	}

	/**
	 * Constructs a request from the given text.
	 * The XML header `<?xml?>` is optional and ignored.
	 */
	RpcRequest.fromText(String body) {
		_root = XML.parse(body);

		_getParamsNode().children.forEach((XmlElement elem) {
			var value = RpcParam.fromParamNode(elem);

			params.add(value);
		});
	}

	/**
	* Returns a string representation for the request.
	*/
	@override
	String toString() {
		var paramsNode = _getParamsNode();

		paramsNode.children.clear();

		params.forEach((param) {
			paramsNode.addChild(new XmlElement(RpcParam._PARAM_NODE, elements: [
				new XmlElement(RpcParam._VALUE_NODE, elements: [RpcParam.valueToXml(param)])
			]));
		});

		return _XML_HEADER + _root.toString();
	}
}