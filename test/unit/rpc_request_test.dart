library rpc_request_test;

import 'package:unittest/unittest.dart';
import 'package:xmlrpc/xmlrpc.dart';
import 'package:xml/xml.dart';


main() {
	test('Name and structure', () {
		var req = new RpcRequest.fromText(
			'''
				<methodCall>
					<methodName>blah</methodName>
					<params />
				</methodCall>
			'''
		);

		expect(req.method, equals('blah'));
		expect(req.toString(), equals('<?xml version="1.0"?>\n<methodCall>\n   <methodName>blah</methodName>\n   <params></params>\n</methodCall>'));
	});

	test('Parse string parameter', () {
		var req = new RpcRequest.fromText(
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

		expect(req, hasLength(2));
		expect(req[0], new isInstanceOf<String>());
		expect(req[0], equals('hello'));
		expect(req[1], new isInstanceOf<int>());
		expect(req[1], equals(4));
	});

	test('From scratch', () {
		var req = new RpcRequest();

		req.method = 'blah2';
		req.addParam(2);
		req.addParam('yep');
		req.addParam({'hello': 'there'});

		expect(req.toString(), equals('<?xml version="1.0"?>\n<methodCall>\n   <methodName>blah2</methodName>\n   <params>\n      <param>\n         <value>\n            <int>2</int>\n         </value>\n      </param>\n      <param>\n         <value>\n            <string>yep</string>\n         </value>\n      </param>\n      <param>\n         <value>\n            <struct>\n               <member>\n                  <name>hello</name>\n                  <value>\n                     <string>there</string>\n                  </value>\n               </member>\n            </struct>\n         </value>\n      </param>\n   </params>\n</methodCall>'));
	});
}