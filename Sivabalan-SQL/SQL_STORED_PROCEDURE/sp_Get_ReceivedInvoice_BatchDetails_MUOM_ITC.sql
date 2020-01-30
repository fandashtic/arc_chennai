CREATE Procedure sp_Get_ReceivedInvoice_BatchDetails_MUOM_ITC (@InvoiceID Int,              
       @Product_Code nvarchar(20), @UOM int)              
As              
Declare @Forum_Code nvarchar(20)          
Select @Forum_Code = Alias From Items Where Product_Code = @Product_Code          
          
Select IDR.PKD, IDR.Batch_Number, IDR.Expiry,               
"Quantity" = Sum(Case (Case IDR.UOM When 0 Then IDR.SalePrice Else IDR.UOMPrice END)            
                 When 0 Then 0             
                 Else (Case IDR.UOM When 0 Then IDR.Quantity Else IDR.UOMQty END)            
   End),            
"Free" = Sum(Case (Case IDR.UOM When 0 Then IDR.SalePrice Else IDR.UOMPrice END)            
                 When 0 Then (Case IDR.UOM When 0 Then IDR.Quantity Else IDR.UOMQty END)            
                 Else 0
   End),            
IDR.PTS,             
I.PTR,             
I.ECP,     
IDR.TaxCode,        
IDR.TaxApplicableOn,        
IDR.TaxPartOff,     
I.Company_Price       
From InvoiceDetailReceived IDR, Items I             
Where IDR.InvoiceID = @InvoiceID And IDR.UOM = @UOM And            
IDR.ForumCode = @Forum_Code And         
IDR.Product_Code= I.Product_Code And         
Not (IDR.PTS = 0 And I.PTR = 0 and I.ECP = 0 And (Case IDR.UOM When 0 Then SalePrice Else UOMPrice END) = 0)              
Group By IDR.PKD, IDR.Batch_Number,               
IDR.Expiry, IDR.PTS, I.PTR, I.ECP, IDR.UOM, IDR.TaxCode,        
IDR.TaxApplicableOn,IDR.TaxPartOff, I.Company_Price      
        
            
Union              
              
Select IDR.PKD, IDR.Batch_Number, IDR.Expiry,               
"Quantity" = Sum(Case (Case IDR.UOM When 0 Then IDR.SalePrice Else IDR.UOMPrice END)            
                 When 0 Then 0             
                 Else (Case IDR.UOM When 0 Then IDR.Quantity Else IDR.UOMQty END)            
   End),               
"Free" = Sum(Case (Case IDR.UOM When 0 Then IDR.SalePrice Else IDR.UOMPrice END)            
                 When 0 Then (Case IDR.UOM When 0 Then IDR.Quantity Else IDR.UOMQty END)            
                 Else 0
   End),               
IDR.PTS ,             
I.PTR ,             
I.ECP,     
IDR.TaxCode,        
IDR.TaxApplicableOn,        
IDR.TaxPartOff,     
I.Company_Price        
From InvoiceDetailReceived IDR, Items I                         
Where IDR.InvoiceID = @InvoiceID And               
IDR.ForumCode = @Forum_Code And IDR.UOM = @UOM And              
IDR.Product_Code = I.Product_Code And         
IDR.ForumCode Not In (Select a.ForumCode              
From InvoiceDetailReceived a     
Where a.InvoiceID = @InvoiceID And              
a.ForumCode = @Forum_Code And         
(((a.PKD Is Null) And (IDR.PKD Is Null)) Or a.PKD = IDR.PKD)             
and a.Batch_Number = IDR.Batch_Number And IDR.UOM = A.UOM And             
(((a.Expiry Is Null) And (IDR.Expiry Is Null)) Or a.Expiry = IDR.Expiry)               
And (a.PTS <> 0 Or a.PTR <> 0 Or a.MRP <> 0 Or (Case a.UOM When 0 Then a.SalePrice Else a.UOMPrice END) <> 0))              
Group By IDR.PKD, IDR.Batch_Number, IDR.Expiry, IDR.PTS, I.PTR, I.ECP, IDR.UOM, IDR.TaxCode,        
IDR.TaxApplicableOn,IDR.TaxPartOff, I.Company_Price      
Having min(IDR.PTS) = max(IDR.PTS) And min(IDR.PTS) = 0 And              
min(I.PTR) = max(I.PTR) And min(I.PTR) = 0 And              
min((Case IDR.UOM When 0 Then SalePrice Else UOMPrice END)) = max((Case IDR.UOM When 0 Then SalePrice Else UOMPrice END)) And             
min((Case IDR.UOM When 0 Then SalePrice Else UOMPrice END)) = 0 And              
min(I.ECP) = max(I.ECP) And min(I.ECP) = 0       
      
