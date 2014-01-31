library rpc_response_test;

import 'package:unittest/unittest.dart';
import 'package:xmlrpc/xmlrpc.dart';
import 'package:xml/xml.dart';


void main() {
	test('From text success', () {
		var resp = new RpcResponse.fromText('''
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
		expect(resp, hasLength(1));
		expect(resp[0], new isInstanceOf<String>());

		resp = new RpcResponse.fromText('''
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
		expect(resp, hasLength(1));
		expect(resp[0], new isInstanceOf<List>());
		expect(resp[0][0], new isInstanceOf<String>());
		expect(resp[0][0], equals('abcd'));
	});

	test('From text failure', () {
		var resp = new RpcResponse.fromText('''
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
		expect(resp, hasLength(1));
		expect(resp[0], new isInstanceOf<Map>());
	});

	test('From scratch success', () {
		var resp = new RpcResponse();

		resp.addParam(1);
		resp.addParam('hello');

		expect(resp.toString(), equals('<?xml version="1.0"?>\n<methodResponse>\n   <params>\n      <param>\n         <value>\n            <int>1</int>\n         </value>\n      </param>\n      <param>\n         <value>\n            <string>hello</string>\n         </value>\n      </param>\n   </params>\n</methodResponse>'));
	});

	test('From scratch failure', () {
		var resp = new RpcResponse(isSuccess: false);

		resp.isSuccess = false;
		resp.addParam([2, 'hello2']);

		expect(resp.toString(), equals('<?xml version="1.0"?>\n<methodResponse>\n   <fault>\n      <value>\n         <array>\n            <data>\n               <value>\n                  <int>2</int>\n               </value>\n               <value>\n                  <string>hello2</string>\n               </value>\n            </data>\n         </array>\n      </value>\n   </fault>\n</methodResponse>'));

		resp = new RpcResponse();

		resp.isSuccess = false;
		resp.addParam({'hello3': 'there'});

		expect(resp.toString(), equals('''<?xml version="1.0"?>
<methodResponse>
   <fault>
      <value>
         <struct>
            <member>
               <name>hello3</name>
               <value>
                  <string>there</string>
               </value>
            </member>
         </struct>
      </value>
   </fault>
</methodResponse>'''
		));
	});
}