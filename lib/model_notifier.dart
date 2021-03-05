// Copyright 2021 mathru. All rights reserved.

/// Package that defines and notifies the model.
///
/// To use, import `package:model_notifier/model_notifier.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library model_notifier;

import 'dart:async';
import "dart:collection";
import 'dart:convert';
import "dart:math";

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katana/katana.dart';
import 'package:http/http.dart';
import "package:meta/meta.dart";
import "package:flutter/material.dart";
import 'package:riverpod/riverpod.dart';
// ignore: implementation_imports
import "package:riverpod/src/framework.dart";
export 'package:riverpod/riverpod.dart';
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:hooks_riverpod/hooks_riverpod.dart';
export 'package:katana/katana.dart';

part 'src/extensions.dart';
part 'src/functions.dart';
part "src/model.dart";
part "src/listened_model.dart";
part "src/stored_model.dart";
part "src/value_model.dart";
part "src/list_model.dart";
part "src/map_model.dart";
part "src/model_provider.dart";
part "src/reference_model.dart";
part "src/reference_list_model.dart";
part "src/reference_map_model.dart";

part "src/map_notifier.dart";
part "src/list_notifier.dart";
part "src/map_model_mixin.dart";
part "src/list_model_mixin.dart";
part "src/change_notifier_listener.dart";

part "src/document_model.dart";
part "src/dynamic_document_model.dart";

part "local/extensions.dart";
part "local/local_database.dart";
part "local/local_document_model.dart";
part "local/local_collection_model.dart";
part "local/local_dynamic_document_model.dart";
part "local/local_dynamic_collection_model.dart";
part "local/local_document_meta_mixin.dart";

part "remote/api_document_model.dart";
part "remote/api_collection_model.dart";
part "remote/api_dynamic_document_model.dart";
part "remote/api_dynamic_collection_model.dart";
