import 'package:fr_sdk_bac/domain/transfer.dart';
import 'package:fr_sdk_bac/fr_sdk.dart';

final class FRTranferRepo implements TransferRepo {
  FRTranferRepo(this.sdk);

  final FRSdk sdk;

  @override
  Future<void> startTransaction(
    String authnType,
    String srcAccount,
    String destAccount,
    double amount,
  ) async {
    try {
      //Call the default login tree.
      await sdk.callEndpoint(
        "https://bacciambl.encore.forgerock.com/transfer?authType=$authnType",
        HttpMethod.post,
        '{"srcAcct": $srcAccount, "destAcct": $destAccount, "amount": $amount}',
        true,
      );
    } on FRCallEndpointError catch (e) {
      throw StartTransactinError(e);
    }
  }
}
