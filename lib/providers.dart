import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fr_sdk_bac/domain/transfer.dart';
import 'package:fr_sdk_bac/fr_sdk.dart';

final frSdkProvider = Provider<FRSdk>(
  (_) => throw UnimplementedError('FRSdk is not initialized'),
);

final transferRepoProvider = Provider<TransferRepo>(
  (_) => throw UnimplementedError('TransferRepo is not initialized'),
);
