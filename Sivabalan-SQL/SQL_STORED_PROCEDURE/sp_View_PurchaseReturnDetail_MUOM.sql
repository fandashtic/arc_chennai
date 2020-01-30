Create Procedure sp_View_PurchaseReturnDetail_MUOM(@DocSerial int)              
As              
Begin  
select * from (
Select  AdjustmentReturnDetail.Product_Code, Items.ProductName,               
 AdjustmentReturnDetail.BatchNumber, Batch_Products.Expiry,              
 Case IsNull(BillAbstract.BillReference, N'')              
 When N'' then              
 BPrefix.Prefix              
 Else              
 BAPrefix.Prefix              
 End +               
 Cast(BillAbstract.DocumentID as nvarchar) + N'-' +              
 Cast(BillAbstract.InvoiceReference as nvarchar) + N'-' +              
 Cast(BillAbstract.BillDate as nvarchar) As Bill ,              
 AdjustmentReturnDetail.Rate,     
 AdjustmentReturnDetail.Quantity,               
 StockAdjustmentReason.Message  ,            
 AdjustmentReturnDetail.Tax,            
 AdjustmentReturnDetail.Total_Value,           
 "Reasonid"=StockAdjustmentReason.MessageID,          
 AdjustmentReturnDetail.TaxSuffApplicableOn,          
 AdjustmentReturnDetail.TaxSuffPartOff,        
 AdjustmentReturnDetail.VAT,    
 AdjustmentReturnDetail.TaxAmount,    
 AdjustmentReturnDetail.BatchPrice,      
 AdjustmentReturnDetail.BatchTax,    
 AdjustmentReturnDetail.BatchTaxApplicableOn,    
 AdjustmentReturnDetail.BatchTaxPartOff,    
 AdjustmentReturnDetail.uom as uomid,    
 AdjustmentReturnDetail.uomprice, AdjustmentReturnDetail.UOMQty,AdjustmentReturnDetail.MRPPerPack,Isnull(AdjustmentReturnDetail.TaxOnQty,0) TaxonQty ,AdjustmentReturnDetail.SerialNo  
,AdjustmentReturnDetail.Tax_Code, AdjustmentReturnDetail.CS_TaxCode, AdjustmentReturnDetail.HSNNumber, AdjustmentReturnDetail.BillOrgID
, AdjustmentReturnDetail.GSTTaxType, AdjustmentReturnDetail.GSTFlag  
 From AdjustmentReturnDetail
 Left Outer Join  BillAbstract On AdjustmentReturnDetail.BillID = BillAbstract.DocumentID
 Inner Join  VoucherPrefix as BPrefix On BPrefix.TranID = N'BILL'               
 Inner Join VoucherPrefix as BAPrefix On BAPrefix.TranID = N'BILL AMENDMENT'
 Left Outer Join StockAdjustmentReason On  AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID 
 Inner Join  Items On AdjustmentReturnDetail.Product_Code = Items.Product_Code
 Left Outer Join  Batch_Products On AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code 
 Inner Join (Select Max(BillID) BillID, DocumentID from BillAbstract where Status & 192 = 0 Group By DocumentID) LBA  On LBA.BillID = BillAbstract.BillID And LBA.DocumentID = BillAbstract.DocumentID 
 Where AdjustmentReturnDetail.AdjustmentID = @DocSerial And              
 (BillAbstract.Status & 192 = 0) And    
 AdjustmentReturnDetail.uomqty > 0     
Union 
 Select AdjustmentReturnDetail.Product_Code, Items.ProductName,               
 AdjustmentReturnDetail.BatchNumber, Batch_Products.Expiry,'' As Bill ,                      
 AdjustmentReturnDetail.Rate,     
 AdjustmentReturnDetail.Quantity,               
 StockAdjustmentReason.Message  ,            
 AdjustmentReturnDetail.Tax,            
 AdjustmentReturnDetail.Total_Value,           
 "Reasonid"=StockAdjustmentReason.MessageID,          
 AdjustmentReturnDetail.TaxSuffApplicableOn,          
 AdjustmentReturnDetail.TaxSuffPartOff,        
 AdjustmentReturnDetail.VAT,    
 AdjustmentReturnDetail.TaxAmount,    
 AdjustmentReturnDetail.BatchPrice,      
 AdjustmentReturnDetail.BatchTax,    
 AdjustmentReturnDetail.BatchTaxApplicableOn,    
 AdjustmentReturnDetail.BatchTaxPartOff,    
 AdjustmentReturnDetail.uom as uomid,    
 AdjustmentReturnDetail.uomprice, AdjustmentReturnDetail.UOMQty,AdjustmentReturnDetail.MRPPerPack,Isnull(AdjustmentReturnDetail.TaxOnQty,0) TaxonQty ,AdjustmentReturnDetail.SerialNo  
,AdjustmentReturnDetail.Tax_Code, AdjustmentReturnDetail.CS_TaxCode, AdjustmentReturnDetail.HSNNumber, AdjustmentReturnDetail.BillOrgID
, AdjustmentReturnDetail.GSTTaxType, AdjustmentReturnDetail.GSTFlag 
 From AdjustmentReturnDetail
Inner Join Batch_Products On  AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code
 Inner Join  VoucherPrefix as BPrefix On BPrefix.TranID = N'BILL'
 Inner Join VoucherPrefix as BAPrefix On BAPrefix.TranID = N'BILL AMENDMENT' 
 Left Outer Join  StockAdjustmentReason On AdjustmentReturnDetail.ReasonID = StockAdjustmentReason.MessageID 
 Inner Join  Items On AdjustmentReturnDetail.Product_Code = Items.Product_Code 
 Where AdjustmentReturnDetail.AdjustmentID = @DocSerial And              
  Isnull(AdjustmentReturnDetail.BillID,0) = 0  And 
 AdjustmentReturnDetail.uomqty > 0    ) As Purchase_Return_Amendment  ORder by SerialNo 
End  
