class KeenASRException implements Exception {
  final String operation;

  const KeenASRException({required this.operation});

  @override
  String toString() => "KeenASR operation failed: $operation";

  static Future<void> wrap(Future<bool> Function() block, {required String operation}) async {
    if(!await block()) {
      throw KeenASRException(operation: operation);
    }
  }
}
