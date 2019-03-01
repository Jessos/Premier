public interface AwardBuilderInterface {
  String createTransactionForTSE(Set<ID> tseIDs);
  String getErrorString();
  String createTransactionForExpense(Set<Id> tseIDs);
  List<tc9_ti__Transaction__c> simulateTransactionsForTSE(Set<Id> tseIDs);
}