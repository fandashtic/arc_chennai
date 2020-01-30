CREATE Procedure Sp_CheckSchemeClaimed(@InvoiceID int)  
as  
Select Isnull((Select Count(Serial) "Claimed" from SchemeSale   
Where (Claimed = 1 Or 
(Claimed = 0 and Isnull((Select Case When Max(Free) = 1 Then Sum(Quantity) - SchemeSale.Pending Else 0 End  
from stocktransferoutdetail stk 
Where stk.DocSerial = SchemeSale.InvoiceID and  
Serial = Isnull(SchemeSale.Serial,0)),0) <> 0 ))  
And InvoiceID = @InvoiceID),0) + 
isnull((Select IsNull(Status,0) From StockTransferOutAbstract 
Where DocSerial = @InvoiceID),0) & 192


