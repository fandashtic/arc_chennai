CREATE Procedure sp_Get_InvoiceDetailReceived_Items_MUOM_Pidilite (@InvoiceID Int)          
As          
Select Count(*)      
from GrnAbstract, InvoiceAbstractReceived IAR Where     
GrnAbstract.RecdInvoiceID = IAR.InvoiceID and    
IAR.DocumentID = Isnull((Select DocumentId from InvoiceAbstractReceived IAR2     
Where IAR2.InvoiceID = @InvoiceID),N'')    
    
Select Items.Product_Code, Items.ProductName,           
 Sum(Case (Case InvoiceDetailReceived.UOM When 0 Then SalePrice Else UOMPrice End)         
    When 0 Then 0         
    Else (Case InvoiceDetailReceived.UOM When 0 Then Quantity Else UOMQty End)        
 End),           
 Sum(Case (Case InvoiceDetailReceived.UOM When 0 Then SalePrice Else UOMPrice End)         
    When 0 Then (Case InvoiceDetailReceived.UOM When 0 Then Quantity Else UOMQty End)         
    Else 0        
    End),            
  Items.Virtual_Track_Batches, ItemCategories.Price_Option, Items.TrackPKD,      
  InvoiceDetailReceived.UOM,  
  InvoiceDetailReceived.TaxCode,    
  InvoiceDetailReceived.TaxApplicableOn,    
  InvoiceDetailReceived.TaxPartOff,"ItemOrder" = Min(ItemOrder)              
 From InvoiceDetailReceived, Items, ItemCategories          
 Where InvoiceDetailReceived.InvoiceID = @InvoiceID          
  And InvoiceDetailReceived.ForumCode = Items.Alias          
  And Items.CategoryID = ItemCategories.CategoryID          
 Group By Items.Product_Code, Items.ProductName, Items.Virtual_Track_Batches,          
  ItemCategories.Price_Option, Items.TrackPKD, InvoiceDetailReceived.UOM,  
  InvoiceDetailReceived.TaxCode,    
  InvoiceDetailReceived.TaxApplicableOn,    
  InvoiceDetailReceived.TaxPartOff              
 Order by Min(ItemOrder)      
    
  
  


