CREATE Procedure sp_Get_InvoiceDetailReceived_Items (@InvoiceID Int)      
As      
  
Select Count(*) from GrnAbstract, InvoiceAbstractReceived IAR Where 
GrnAbstract.RecdInvoiceID = IAR.InvoiceID and
IAR.DocumentID = Isnull((Select DocumentId from InvoiceAbstractReceived IAR2 
Where IAR2.InvoiceID = @InvoiceID),N'')

Select Items.Product_Code, Items.ProductName,       
Sum(Case SalePrice When 0 Then 0 Else Quantity End),      
Sum(Case SalePrice When 0 Then Quantity Else 0 End),      
Items.Virtual_Track_Batches, ItemCategories.Price_Option, Items.TrackPKD,
InvoiceDetailReceived.TaxCode,  
InvoiceDetailReceived.TaxApplicableOn,  
InvoiceDetailReceived.TaxPartOff            
From InvoiceDetailReceived, Items, ItemCategories  
Where InvoiceDetailReceived.InvoiceID = @InvoiceID  
And InvoiceDetailReceived.ForumCode = Items.Alias      
And Items.CategoryID = ItemCategories.CategoryID      
Group By Items.Product_Code, Items.ProductName, Items.Virtual_Track_Batches,      
ItemCategories.Price_Option, Items.TrackPKD,
InvoiceDetailReceived.TaxCode,  
InvoiceDetailReceived.TaxApplicableOn,  
InvoiceDetailReceived.TaxPartOff                
Order By Min(ItemOrder)    


