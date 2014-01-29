/**
 * Handy XML-RPC wrapper classes.
 *
 * The library uses the [xml](http://pub.dartlang.org/packages/xml) package.
 *
 * See [readme](https://github.com/o-nix/dart-xmlrpc/blob/master/README.md) for examples.
 *
 * Read [RpcRequest] for all the supported type conversions (I recommend you to *Hide inherited* method to understand the methods).

 * Take look at some simple tests inside [integration](https://github.com/o-nix/dart-xmlrpc/tree/master/test/integration) directory.
 *
 * Fork it on GitHub: <https://github.com/o-nix/dart-xmlrpc>
 */
library xmlrpc;

import 'package:xml/xml.dart';

import 'dart:mirrors';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

import 'src/multiconverter.dart';
import 'src/constants.dart';

part 'src/rpc_request.dart';
part 'src/rpc_param.dart';
part 'src/rpc_response.dart';
part 'src/params_iterator.dart';