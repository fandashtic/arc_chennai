CREATE Function sp_acc_getTaxonclosingstock()
Returns Decimal(18,6)
As
Begin
 Declare @TaxonBatchStockValue Decimal(18,6),@PendingTaxValue Decimal(18,6),@BatchCode Int,@TaxonCLStock Decimal(18,6),@IssueValue Decimal(18,6)
 
 Select @PendingTaxValue = Sum((IsNULL(Pending,0)*IsNULL(VanStatementDetail.PurchasePrice,0))*(IsNULL(Batch_Products.TaxSuffered,0)/100)) from VanStatementDetail,Batch_Products,Items
 Where VanStatementDetail.Batch_Code = Batch_Products.Batch_Code And Batch_Products.Product_Code = Items.Product_Code 
 And ((IsNULL(Items.VAT,0) = 0) Or (IsNULL(Items.VAT,0) = 1 And isNull(TaxType,0)=2))--IsNULL(VAT_Locality,0) = 2))
	
 Select @TaxonBatchStockValue = Sum((Quantity*PurchasePrice)*(IsNULL(Batch_Products.TaxSuffered,0)/100)) from Batch_Products, Items
 Where Batch_Products.Product_Code = Items.Product_Code And ((IsNULL(Items.VAT,0) = 0) Or
 (IsNULL(Items.VAT,0) = 1 And isNull(TaxType,0)=2))--IsNULL(VAT_Locality,0) = 2))

 If Exists(Select * from dbo.SysObjects Where ID = Object_ID(N'[dbo].[IssueDetail]') And OBJECTPROPERTY(ID, N'IsUserTable') = 1)
  Begin
   Select @IssueValue=Sum(((IsNULL(IssuedQty,0)-IsNULL(ReturnedQty,0))*IsNULL(IssueDetail.PurchasePrice,0))*(IsNULL(Batch_Products.TaxSuffered,0)/100)) 
   from IssueDetail,IssueAbstract,JobcardAbstract,Batch_Products,Items
   Where IssueDetail.IssueID=IssueAbstract.IssueID
   And IssueAbstract.JobCardID=JobCardAbstract.JobCardID
   And IssueDetail.SpareCode = Items.Product_Code 
   And IssueDetail.Batch_Code = Batch_Products.Batch_Code
   And Batch_Products.Product_Code = Items.Product_Code 
   And ((IsNULL(Items.VAT,0) = 0) Or	(IsNULL(Items.VAT,0) = 1 And isNull(TaxType,0)=2))--IsNULL(VAT_Locality,0) = 2))
   And IsNULL(IssueAbstract.Status,0) & 192 = 0
   And IsNULL(JobCardAbstract.Status,0) & 192 = 0
   And IsNULL(JobCardAbstract.ServiceInvoiceID,0) = 0
  End

 Set @TaxonCLStock = (isnull(@TaxonBatchStockValue,0)+isnull(@PendingTaxValue,0))+IsNULL(@IssueValue,0)
 Return @TaxonCLStock
End
