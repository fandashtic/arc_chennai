Create Procedure [dbo].[sp_Get_InvoiceDetailReceived_Items_MUOM] (@InvoiceID Int, @VendorId as nVarchar(250))  
As          
  
Declare @Locality Int  
Select @Locality = Isnull(Locality,1) From Vendors Where VendorId = @VendorId  
  
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
  InvoiceDetailReceived.TaxPartOff,  
  Case @Locality When 1 Then  
  (Select Top 1 Tax_Code From Tax  Where Percentage = InvoiceDetailReceived.TaxCode And  
   LSTApplicableOn= InvoiceDetailReceived.TaxApplicableOn And  
   LSTPartOff= InvoiceDetailReceived.TaxPartOff)  
  Else  
  (Select Top 1 Tax_Code From Tax Where Percentage = InvoiceDetailReceived.TaxCode And  
   CSTApplicableOn= InvoiceDetailReceived.TaxSuffApplicableOn And  
   CSTPartOff= InvoiceDetailReceived.TaxSuffPartOff)  
  End  As "TaxPercentage"   
    
 From InvoiceDetailReceived, Items, ItemCategories          
 Where InvoiceDetailReceived.InvoiceID = @InvoiceID          
  And InvoiceDetailReceived.ForumCode = Items.Alias          
  And Items.CategoryID = ItemCategories.CategoryID          
 Group By Items.Product_Code, Items.ProductName, Items.Virtual_Track_Batches,          
  ItemCategories.Price_Option, Items.TrackPKD, InvoiceDetailReceived.UOM,  
  InvoiceDetailReceived.TaxCode,    
  InvoiceDetailReceived.TaxApplicableOn,    
  InvoiceDetailReceived.TaxPartOff,
  InvoiceDetailReceived.TaxSuffApplicableOn,
  InvoiceDetailReceived.TaxSuffPartOff              
  Order by Min(ItemOrder)      

