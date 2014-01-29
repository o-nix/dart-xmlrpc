part of xmlrpc;


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
class RpcRequest extends _ParamsIterationSupport {
	List _params = [];
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

	void set method(String method) {
		var methodNode = _getMethodNode();

		methodNode.children.clear();
		methodNode.addChild(new XmlText(method));
	}

	@override
	Iterator<Object> get iterator =>
		new _ParamsIterator(this);

	/**
	* Constructs an empty request.
	*/
	RpcRequest({String method, List params}) {
		_root = new XmlElement(METHOD_CALL_NODE, elements: [
			new XmlElement(METHOD_NAME_NODE),
			new XmlElement(PARAMS_NODE)
		]);

		if (method != null)
			this.method = method;

		if (params != null)
			this._params = params;
	}

	/**
	 * Constructs a request from the given text.
	 * The XML header `<?xml?>` is optional and ignored.
	 */
	RpcRequest.fromText(String body) {
		_root = XML.parse(body);

		_getParamsNode().children.forEach((XmlElement elem) {
			var value = RpcParam.fromParamNode(elem);

			_params.add(value);
		});
	}

	/**
	* Returns a string representation for the request.
	*/
	@override
	String toString() {
		var paramsNode = _getParamsNode();

		paramsNode.children.clear();

		_params.forEach((param) {
			paramsNode.addChild(new XmlElement(PARAM_NODE, elements: [
				new XmlElement(VALUE_NODE, elements: [RpcParam.valueToXml(param)])
			]));
		});

		return _toStringInternal(XML_HEADER + _root.toString());
	}

	static String _toStringInternal(String original) =>
		original.replaceAll('\r', '\n');

	XmlElement _getMethodNode() =>
		_root.query(METHOD_NAME_NODE).single;

	XmlElement _getParamsNode() =>
		_root.query(PARAMS_NODE).single;
}