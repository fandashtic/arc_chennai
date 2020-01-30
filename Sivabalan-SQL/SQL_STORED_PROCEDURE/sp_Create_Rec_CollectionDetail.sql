CREATE procedure sp_Create_Rec_CollectionDetail(@CollectionID as int)      
as      
select "CollectionID" =OriginalID, "PaymentDate" =PaymentDate, "DocumentValue" =DocumentValue,"AdjustedAmount" = AdjustedAmount,   
"DocumentType" =DocumentType, "ExtraCollection" =ExtraCollection, "DocRef" =DocRef,   
"Adjustment" =Adjustment, "DocumentID" =DocumentID, "Balance" = 0 - AdjustedAmount, 0,"Discount" = Discount 
from CollectionDetailreceived  
where CollectionID = @CollectionID    
And DocumentType <> 4  
UNION  
select "CollectionID" = 
(case InvoiceType  
when 1 then  
  VoucherPrefix.Prefix   
when 3 then  
  InvPrefix.Prefix  
end ) 
+ CAST(InvoiceAbstract.DocumentID as nvarchar),
"PaymentDate" = CollectionDetailreceived.PaymentDate, "DocumentValue" =DocumentValue,  
"AdjustedAmount" = CollectionDetailreceived.AdjustedAmount,   
"DocumentType" =DocumentType, "ExtraCollection" =ExtraCollection, "DocRef" =DocRef,   
"Adjustment" =Adjustment, "DocumentID" = CollectionDetailreceived.DocumentID, "Balance" = InvoiceAbstract.Balance, 
"AddlDiscount" = AdditionalDiscount, "Discount" = Discount from CollectionDetailreceived, InvoiceAbstract, VoucherPrefix, VoucherPrefix as InvPrefix  
where CollectionID = @CollectionID    
And InvoiceAbstract.InvoiceID = CollectionDetailreceived.DocumentID  
And DocumentType = 4 and VoucherPrefix.TranID = 'INVOICE' and  
InvPrefix.TranID = 'INVOICE AMENDMENT'  



