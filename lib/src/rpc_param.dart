part of xmlrpc;

class RpcParam {
	/**
	 * The date format for the `<dateTime.iso8601 />` tag.
	 */
	static String DATE_FORMAT = 'yMdTHH:mm:ss';

	static final _converter = new Multiconverter({
		int: (int value) =>
			new XmlElement('int', elements: [new XmlText(value.toString())]),

		bool: (bool value) =>
			new XmlElement('boolean', elements: [new XmlText(value.toString())]),

		double: (double value) =>
			new XmlElement('double', elements: [new XmlText(value.toString())]),

		DateTime: (DateTime value) =>
			new XmlElement(ISO_8601_NODE, elements: [new XmlText(new DateFormat(DATE_FORMAT).format(value))]),

		new List<int>().runtimeType: (List<int> binaryData) =>
			new XmlElement(BASE64_NODE, elements: [new XmlText(CryptoUtils.bytesToBase64(binaryData))]),

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
			var result = [];
			XmlElement dataNode = elem.children.single;

			dataNode.children.forEach((XmlElement elem) =>
				result.add(fromXmlElement(elem.children.single))
			);

			return result;
		},

		 // <struct><member><name>some</name><value><string>value</string></value></member></struct>
		'struct': (XmlElement elem) {
			var result = {};

			elem.children.forEach((XmlElement member) {
				var name = (member.query(NAME_NODE).single as XmlElement).text;
				XmlElement valueNode = member.query(VALUE_NODE).single;

				result[name] = fromXmlElement(valueNode.children.single);
			});

			return result;
		},

		String: (String value) =>
			new XmlElement('string', elements: [new XmlText(value)]),

		'string': (XmlElement elem) =>
			elem.text,

		List: (List list) =>
			new XmlElement(ARRAY_NODE, elements: [
				new XmlElement(DATA_NODE,
					elements: list.map((Object item) =>
						new XmlElement(VALUE_NODE, elements: [RpcParam.valueToXml(item)])
					)
				)
			]),

		Map: (Map map) =>
			new XmlElement(STRUCT_NODE, elements: map.keys.map((Object key) =>
				new XmlElement(MEMBER_NODE, elements: [
					new XmlElement(NAME_NODE, elements: [
						new XmlText(key.toString())
					]),
					new XmlElement(VALUE_NODE, elements: [
						RpcParam.valueToXml(map[key])
					])
				])
			)),

		null: (bool value) =>
			new XmlElement('nil')
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
		assert(node.name == 'param');

		XmlElement valueNodeElem = node.children.single;

		assert(valueNodeElem.name == 'value');

		return fromXmlElement(valueNodeElem.children.single);
	}

	/**
	 * Returns an Object representation for a value from an XML node.
	 *
	 * The node should have a structure like:
	 *
	 *     <int>...</int>
	 */
	static Object fromXmlElement(XmlElement node) {
		Function converter = _converter.getConverter(node.name);

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
