CREATE procedure [dbo].[sp_View_PurchaseReturnDetail] (@DocSerial int) As              
Select max(AdjustmentReturnDetail.Product_Code) as Product_Code, 
max(Items.ProductName) as ProductName,               
max(AdjustmentReturnDetail.BatchNumber) as BatchNumber,
max(Batch_Products.Expiry) as Expiry,              
Case max(IsNull(BillAbstract.BillReference, N''))             
When N'' then              
max(BPrefix.Prefix)              
Else              
max(BAPrefix.Prefix)              
End +               
max(Cast(BillAbstract.DocumentID as nvarchar)) + N'-' +              
max(Cast(BillAbstract.InvoiceReference as nVarchar)) + N'-' +              
max(Cast(BillAbstract.BillDate as nVarchar)),              
max(AdjustmentReturnDetail.Rate) as Rate,
Sum(AdjustmentReturnDetail.Quantity) as Quantity,               
max(StockAdjustmentReason.Message) as Message  ,            
max(AdjustmentReturnDetail.Tax) as Tax,           
(Sum(AdjustmentReturnDetail.Quantity) * (max(AdjustmentReturnDetail.Rate)) + Sum(AdjustmentReturnDetail.Quantity) * (max(AdjustmentReturnDetail.Rate)) * IsNull(max(AdjustmentReturnDetail.Tax),0)/100) Total_Value,          
"Reasonid"=max(StockAdjustmentReason.MessageID), 
Max(AdjustmentReturnDetail.BatchCode) as BatchCode,        
max(AdjustmentReturnDetail.TaxSuffApplicableOn) as TaxSuffApplicableOn,
max(AdjustmentReturnDetail.TaxSuffPartOff) as TaxSuffPartOff,      
max(AdjustmentReturnDetail.VAT) as VAT,
max(AdjustmentReturnDetail.TaxAmount) as TaxAmount, 
Avg(AdjustmentReturnDetail.BatchPrice) as BatchPrice,  
Avg(AdjustmentReturnDetail.BatchTax) as BatchTax,  
Avg(AdjustmentReturnDetail.BatchTaxApplicableOn) as BatchTaxApplicableOn,  
Avg(AdjustmentReturnDetail.BatchTaxPartOff)  as BatchTaxPartOff      

From AdjustmentReturnDetail, BillAbstract, VoucherPrefix as BPrefix,               
VoucherPrefix as BAPrefix, StockAdjustmentReason, Items, Batch_Products             
 
Where AdjustmentReturnDetail.AdjustmentID = @DocSerial And              
AdjustmentReturnDetail.Product_Code = Items.Product_Code And              
AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code And              
AdjustmentReturnDetail.BillID *= BillAbstract.DocumentID And              
Batch_Products.GRN_ID *= BillAbstract.GRNID And
(BillAbstract.Status & 128) = 0 And
BPrefix.TranID = N'BILL' And BAPrefix.TranID = N'BILL AMENDMENT' And              
AdjustmentReturnDetail.ReasonID *= StockAdjustmentReason.MessageID And              
AdjustmentReturnDetail.Quantity > 0              

Group By 
	AdjustmentReturnDetail.SerialNo
Order By
	AdjustmentReturnDetail.SerialNo
