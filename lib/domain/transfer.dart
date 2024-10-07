abstract class TransferRepo {
  Future<void> startTransaction(
    String authnType,
    String srcAccount,
    String destAccount,
    double amount,
  );
}

class StartTransactinError implements Exception {
  StartTransactinError(this.e);

  final Exception e;
}
