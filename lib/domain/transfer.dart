abstract class TransferRepo {
  Future<void> startTransaction(
    String authnType,
    String srcAccount,
    String destAccount,
    double amount,
  );
}

extension type StartTransactinError(Exception e) implements Exception {}
