library rpc_request_test;

import 'package:unittest/unittest.dart';
import 'package:xmlrpc/xmlrpc.dart';


main() {
	test('Name and structure', () {
		var req = new RpcRequest.fromXmlString(
			'''
        <methodCall>
					<methodName>blah</methodName>
					<params />
				</methodCall>
      '''
		);

		expect(req.method, equals('blah'));
		expect(req.toString(), equals('<?xml version="1.0"?><methodCall><methodName>blah</methodName><params /></methodCall>'));
	});

	test('Parse string parameter', () {
		var req = new RpcRequest.fromXmlString(
			'''
				<methodCall>
					<methodName>blah</methodName>
					<params>
						<param>
							<value>
								<string>hello</string>
							</value>
						</param>
						<param>
							<value>
								<int>4</int>
							</value>
						</param>
					</params>
				</methodCall>
			'''
		);

		expect(req.params, hasLength(2));
		expect(req.params[0], new isInstanceOf<String>());
		expect(req.params[0], equals('hello'));
		expect(req.params[1], new isInstanceOf<int>());
		expect(req.params[1], equals(4));
	});

	test('From scratch', () {
		var req = new RpcRequest();

		req.method = 'blah2';
		req.params.add(2);
		req.params.add('yep');
		req.params.add({'hello': 'there'});

		expect(req.toString(), equals('<?xml version="1.0"?><methodCall><methodName>blah2</methodName><params><param><value><int>2</int></value></param><param><value><string>yep</string></value></param><param><value><struct><member><name>hello</name><value><string>there</string></value></member></struct></value></param></params></methodCall>'));
	});
}