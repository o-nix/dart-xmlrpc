library xmlrpc_test;

import 'unit/rpc_param_test.dart' as rpc_param_test;
import 'unit/rpc_request_test.dart' as rpc_request_test;
import 'unit/rpc_response_test.dart' as rpc_response_test;

void main() {
	rpc_param_test.main();
	rpc_request_test.main();
	rpc_response_test.main();
}