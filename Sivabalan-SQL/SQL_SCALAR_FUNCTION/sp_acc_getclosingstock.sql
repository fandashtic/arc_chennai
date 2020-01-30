CREATE Function sp_acc_getclosingstock()  
Returns Decimal(18,6)  
As  
Begin  
 Declare @BatchStockValue Decimal(18,6),@PendingValue Decimal(18,6),@BatchCode Int,@CLStock Decimal(18,6),@IssueValue Decimal(18,6)
 Select @PendingValue=Sum(IsNULL(Pending,0)*IsNULL(PurchasePrice,0)) from VanStatementDetail  
 Select @BatchStockValue=Sum(Quantity*PurchasePrice) from Batch_Products, Items Where Batch_Products.Product_Code = Items.Product_Code  
 If Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[IssueDetail]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1)
  Begin
   Select @IssueValue=Sum((IsNULL(IssuedQty,0)-IsNULL(ReturnedQty,0))*IsNULL(PurchasePrice,0)) 
   from IssueDetail,IssueAbstract,JobcardAbstract
   Where IssueDetail.IssueID=IssueAbstract.IssueID
   And IssueAbstract.JobCardID=JobCardAbstract.JobCardID
   And IsNULL(IssueAbstract.Status,0) & 192 = 0
   And IsNULL(JobCardAbstract.Status,0) & 192 = 0
   And IsNULL(JobCardAbstract.ServiceInvoiceID,0) = 0
  End
 Set @CLStock = (IsNULL(@BatchStockValue,0)+IsNULL(@PendingValue,0))+IsNULL(@IssueValue,0)
 Return @CLStock  
End 

