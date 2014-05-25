library rpc_response_test;

import 'package:unittest/unittest.dart';
import 'package:xmlrpc/xmlrpc.dart';


void main() {
	test('From text success', () {
		var resp = new RpcResponse.fromXmlString('''
			<methodResponse>
				<params>
					<param>
						<value>
							<string>South Dakota</string>
						</value>
					</param>
				</params>
			</methodResponse>
		''');

		expect(resp.isSuccess, equals(true));
		expect(resp.params, hasLength(1));
		expect(resp.params[0], new isInstanceOf<String>());

		resp = new RpcResponse.fromXmlString('''
			<methodResponse>
				<params>
					<param>
						<value>
							<array>
								<data>
									<value>
										<string>abcd</string>
									</value>
								</data>
							</array>
						</value>
					</param>
				</params>
			</methodResponse>
		''');

		expect(resp.isSuccess, equals(true));
		expect(resp.params, hasLength(1));
		expect(resp.params[0], new isInstanceOf<List>());
		expect(resp.params[0][0], new isInstanceOf<String>());
		expect(resp.params[0][0], equals('abcd'));
	});

	test('From text failure', () {
		var resp = new RpcResponse.fromXmlString('''
			<methodResponse>
				<fault>
					<value>
						<struct>
							<member>
								<name>faultCode</name>
								<value><int>4</int></value>
							</member>
							<member>
								<name>faultString</name>
								<value><string>Too many parameters.</string></value>
							</member>
						</struct>
					</value>
				</fault>
			</methodResponse>
		''');

		expect(resp.isSuccess, equals(false));
		expect(resp.params, hasLength(1));
		expect(resp.params[0], new isInstanceOf<Map>());
	});

	test('From scratch success', () {
		var resp = new RpcResponse();

		resp.params.add(1);
		resp.params.add('hello');

		expect(resp.toString(), equals('<?xml version="1.0"?><methodResponse><params><param><value><int>1</int></value></param><param><value><string>hello</string></value></param></params></methodResponse>'));
	});

	test('From scratch failure', () {
		var resp = new RpcResponse(false);

		resp.isSuccess = false;
		resp.params.add([2, 'hello2']);

		expect(resp.toString(), equals('<?xml version="1.0"?><methodResponse><fault><value><array><data><value><int>2</int></value><value><string>hello2</string></value></data></array></value></fault></methodResponse>'));

		resp = new RpcResponse();

		resp.isSuccess = false;
		resp.params.add({'hello3': 'there'});

		expect(resp.toString(), equals('<?xml version="1.0"?><methodResponse><fault><value><struct><member><name>hello3</name><value><string>there</string></value></member></struct></value></fault></methodResponse>'));
	});
}