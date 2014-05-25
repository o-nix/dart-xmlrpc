library rpc_param_test;

import 'package:unittest/unittest.dart';
import 'package:xmlrpc/xmlrpc.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert' show UTF8;


main() {
	group('To XML', () {
		test('String', () {
			XmlElement param = RpcParam.valueToXml('hello');

			expect(param.toString(), equals('<string>hello</string>'));
		});

		test('int', () {
			XmlElement param = RpcParam.valueToXml(5);

			expect(param.toString(), equals('<int>5</int>'));
		});

		test('double', () {
			XmlElement param = RpcParam.valueToXml(3.14159);

			expect(param.toString(), equals('<double>3.14159</double>'));
		});

		test('null', () {
			XmlElement param = RpcParam.valueToXml(null);

			expect(param.toString(), equals('<nil />'));
		});

		test('bool', () {
			XmlElement param = RpcParam.valueToXml(true);
			expect(param.toString(), equals('<boolean>true</boolean>'));

			param = RpcParam.valueToXml(false);
			expect(param.toString(), equals('<boolean>false</boolean>'));
		});

		test('DateTime', () {
			var now = new DateTime.now();
			XmlElement param = RpcParam.valueToXml(now);
			var formatter = new DateFormat(RpcParam.DATE_FORMAT);

			expect(param.toString(), equals('<ISO_8601_NODE>${formatter.format(now)}</ISO_8601_NODE>'));
		});

		test('Array', () {
			XmlElement param = RpcParam.valueToXml([5, 'hello']);

			expect(param.toString(), equals('<array><data><value><int>5</int></value><value><string>hello</string></value></data></array>'));
		});

		test('Map', () {
			var map = new Map();

			map[5] = 'hello';
			map['there'] = 7;

			XmlElement param = RpcParam.valueToXml(map);

			expect(param.toString(), equals('<struct><member><name>5</name><value><string>hello</string></value></member><member><name>there</name><value><int>7</int></value></member></struct>'));
		});

		test('Base64', () {
			var str = 'Just a test';
			var bytes = UTF8.encode(str);
			var base64 = CryptoUtils.bytesToBase64(bytes);

			XmlElement param = RpcParam.valueToXml(bytes);

			expect(param.toString(), equals('<base64>$base64</base64>'));
		});
	});

	group('From XML', () {
		test('String', () {
		  var param = RpcParam.fromParamNode(parse('''
        <param>
          <value>
            <string>hello</string>
          </value>
        </param>
      ''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<String>());
			expect(param, equals('hello'));
		});

		test('null', () {
		  var param = RpcParam.fromParamNode(parse('''
        <param>
          <value>
            <nil />
          </value>
        </param>
      ''').rootElement);

			expect(param, isNull);
		});

		test('double', () {
		  var param = RpcParam.fromParamNode(parse('''
        <param>
          <value>
            <double>-3.14159</double>
          </value>
        </param>
      ''').rootElement);

			expect(param, new isInstanceOf<double>());
			expect(param, equals(-3.14159));
		});

		test('ISO_8601_NODE', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<ISO_8601_NODE>19980717T14:08:55</ISO_8601_NODE>
					</value>
				</param>
			''').rootElement);

			expect(param, new isInstanceOf<DateTime>());
			expect((param as DateTime).year, equals(1998));
			expect((param as DateTime).hour, equals(14));
		});

		test('int', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<int>1</int>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<int>());
			expect(param, equals(1));

			param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<i4>2</i4>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<int>());
			expect(param, equals(2));
		});

		test('Array', () {
			var param = (RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<array>
							<data>
								<value><i4>1404</i4></value>
								<value><string>Something here</string></value>
								<value><boolean>true</boolean></value>
							</data>
						</array>
					</value>
				</param>
			''').rootElement) as Iterable).toList();

			expect(param, isNotNull);
			expect(param, new isInstanceOf<Iterable>());
			expect(param[0], new isInstanceOf<int>());
			expect(param[0], equals(1404));
			expect(param[1], new isInstanceOf<String>());
			expect(param[1], equals('Something here'));
			expect(param[2], new isInstanceOf<bool>());
			expect(param[2], equals(true));
		});

		test('Map', () {
			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<struct>
							<member>
								<name>foo</name>
								<value><i4>1</i4></value>
							</member>
							<member>
								<name>bar</name>
								<value><string>Another value</string></value>
							</member>
						</struct>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<Map>());
			expect(param['foo'], new isInstanceOf<int>());
			expect(param['foo'], equals(1));
			expect(param['bar'], new isInstanceOf<String>());
			expect(param['bar'], equals('Another value'));
		});

		test('Base64', () {
			var str = 'Some data';
			var bytes = UTF8.encode(str);
			var base64 = CryptoUtils.bytesToBase64(bytes);

			var param = RpcParam.fromParamNode(parse('''
				<param>
					<value>
						<base64>$base64</base64>
					</value>
				</param>
			''').rootElement);

			expect(param, isNotNull);
			expect(param, new isInstanceOf<List<int>>());
			expect(UTF8.decode(param), equals(str));
		});
	});
}