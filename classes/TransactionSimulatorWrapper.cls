public class TransactionSimulatorWrapper {
  public List<String> breakpoints{get;set;}
  public Map<Date,Simulator> simMap{get;set;}
  
  public class Simulator{
    public Date workDate{get;set;}
    public Map<String, Decimal> type_Hours{get;set;}
    public Map<String, Decimal> type_BillVal{ get; set; }
    public Map<String, Decimal> type_PayVal { get; set; }
  }
  
}