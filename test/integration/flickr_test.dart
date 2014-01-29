library flickr_test;

import 'package:http/http.dart' as http;
import 'package:xmlrpc/xmlrpc.dart';
import 'package:unittest/unittest.dart';

const String URL = 'http://api.flickr.com/services/xmlrpc';

void main() {
	test('Flickr echo', () {
		var req = new RpcRequest(
			method: 'flickr.panda.getList',
			params: [{
				'api_key': 'b7c10f5f6087e1d11478718bffdd5e19'
			}]
		);

		http.post(URL, body: req.toString()).then((resp) {
			var rpcResp = new RpcResponse.fromText(resp.body);

			expect(rpcResp.isSuccess, isTrue);
			expect(rpcResp, hasLength(1));
		});
	});
}

