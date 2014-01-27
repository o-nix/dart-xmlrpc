library xmlrpc_test;

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
		expect(req.toString(), equals('<?xml version="1.0"?>\r<methodCall>\r   <methodName>blah</methodName>\r   <params></params>\r</methodCall>'));
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

		expect(req.toString(), equals('<?xml version="1.0"?>\r<methodCall>\r   <methodName>blah2</methodName>\r   <params>\r      <param>\r         <value>\r            <int>2</int>\r         </value>\r      </param>\r      <param>\r         <value>\r            <string>yep</string>\r         </value>\r      </param>\r      <param>\r         <value>\r            <struct>\r               <member>\r                  <name>hello</name>\r                  <value>\r                     <string>there</string>\r                  </value>\r               </member>\r            </struct>\r         </value>\r      </param>\r   </params>\r</methodCall>'));
	});
}