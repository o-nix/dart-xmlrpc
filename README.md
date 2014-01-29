# XML-RPC library for Dart

This library contains simple wrapper classes for responses and requests sent via [XML-RPC](http://en.wikipedia.org/wiki/XML-RPC) protocol.

Use [**RpcRequest**](lib/src/rpc_request.dart) and [**RpcResponse**](lib/src/rpc_response.dart) classes for bidirectional conversions from/to XML.

For example a call to some external endpoint:

    import 'package:http/http.dart' as http;
    import 'package:xmlrpc/xmlrpc.dart';

    var request = new RpcRequest();

    request.method = 'echo';
    request.addParam(true);
    request.addParam('an argument');

    http.post('http://example.com', body: request.toString())
            .then((httpResponse) {
                var response = new RpcResponse.fromText(httpResponse.body);

                print(response.isSuccess);
                print(response.length);
            });

See the full API documentation [here](http://o-nix.me/dart-xmlrpc/xmlrpc.html).