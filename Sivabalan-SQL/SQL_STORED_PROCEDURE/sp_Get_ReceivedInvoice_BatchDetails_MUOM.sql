CREATE Procedure sp_Get_ReceivedInvoice_BatchDetails_MUOM (@InvoiceID Int,        
       @Product_Code nvarchar(20), @UOM int)        
As        
Declare @Forum_Code nvarchar(20)    
Select @Forum_Code = Alias From Items Where Product_Code = @Product_Code    
    
Select IDR.PKD, IDR.Batch_Number, IDR.Expiry,         
"Quantity" = Sum(Case (Case IDR.UOM When 0 Then IDR.SalePrice Else IDR.UOMPrice END)      
                 When 0 Then 0       
                 Else (Case IDR.UOM When 0 Then IDR.Quantity Else IDR.UOMQty END)      
   End),      
"Free" = IsNull((Select Sum((Case UOM When 0 Then Quantity Else UOMQty END)) From InvoiceDetailReceived a Where         
 a.InvoiceID = @InvoiceID And        
 (((a.PKD Is Null) And (IDR.PKD Is Null)) Or a.PKD = IDR.PKD) And        
 a.Batch_Number = IDR.Batch_Number And a.UOM = IDR.UOM And       
 (((a.Expiry Is Null) And (IDR.Expiry Is Null)) Or a.Expiry = IDR.Expiry)         
 And a.PTS = 0 And a.PTR = 0 And a.MRP = 0 And a.FreePTS = IDR.PTS And        
 (Case a.UOM When 0 Then a.SalePrice Else a.UOMPrice END) = 0 And        
 a.FreePTR = IDR.PTR And a.FreeMRP = IDR.MRP), 0),          
IDR.PTS,       
IDR.PTR,       
IDR.MRP, IDR.TaxCode,  
IDR.TaxApplicableOn,  
IDR.TaxPartOff, IDR.Company_Price 
From InvoiceDetailReceived IDR       
Where IDR.InvoiceID = @InvoiceID And IDR.UOM = @UOM And      
IDR.ForumCode = @Forum_Code And        
Not (PTS = 0 And PTR = 0 and MRP = 0 And (Case UOM When 0 Then SalePrice Else UOMPrice END) = 0)        
Group By IDR.PKD, IDR.Batch_Number,         
IDR.Expiry, IDR.PTS, IDR.PTR, IDR.MRP, IDR.UOM, IDR.TaxCode,  
IDR.TaxApplicableOn,IDR.TaxPartOff, IDR.Company_Price
  
      
Union        
        
Select IDR.PKD, IDR.Batch_Number, IDR.Expiry,         
"Quantity" = Sum(Case (Case IDR.UOM When 0 Then IDR.SalePrice Else IDR.UOMPrice END)      
                 When 0 Then 0       
                 Else (Case IDR.UOM When 0 Then IDR.Quantity Else IDR.UOMQty END)      
   End),         
"Free" = IsNull((Select Sum((Case UOM When 0 Then Quantity Else UOMQty END)) From InvoiceDetailReceived a Where      
 a.InvoiceID = @InvoiceID And       
 (((a.PKD Is Null) And (IDR.PKD Is Null)) Or a.PKD = IDR.PKD) And        
 a.Batch_Number = IDR.Batch_Number And IDR.UOM = A.UOM And      
 (((a.Expiry Is Null) And (IDR.Expiry Is Null)) Or a.Expiry = IDR.Expiry)         
 And a.PTS = 0 And a.PTR = 0 And a.MRP = 0 And a.FreePTS = IDR.PTS And (Case a.UOM When 0 Then a.SalePrice Else a.UOMPrice END) = 0 And        
 a.FreePTR = IDR.PTR And a.FreeMRP = IDR.MRP), 0),         
IDR.PTS ,       
IDR.PTR ,       
IDR.MRP, IDR.TaxCode,  
IDR.TaxApplicableOn,  
IDR.TaxPartOff, IDR.Company_Price  
From InvoiceDetailReceived IDR        
Where IDR.InvoiceID = @InvoiceID And         
IDR.ForumCode = @Forum_Code And IDR.UOM = @UOM And        
IDR.ForumCode Not In (Select a.ForumCode        
 From InvoiceDetailReceived a         
 Where a.InvoiceID = @InvoiceID And        
 a.ForumCode = @Forum_Code And        
 (((a.PKD Is Null) And (IDR.PKD Is Null)) Or a.PKD = IDR.PKD)       
 and a.Batch_Number = IDR.Batch_Number And IDR.UOM = A.UOM And       
 (((a.Expiry Is Null) And (IDR.Expiry Is Null)) Or a.Expiry = IDR.Expiry)         
 And (a.PTS <> 0 Or a.PTR <> 0 Or a.MRP <> 0 Or (Case a.UOM When 0 Then a.SalePrice Else a.UOMPrice END) <> 0))        
Group By IDR.PKD, IDR.Batch_Number, IDR.Expiry, IDR.PTS, IDR.PTR, IDR.MRP, IDR.UOM, IDR.TaxCode,  
IDR.TaxApplicableOn,IDR.TaxPartOff, IDR.Company_Price
Having min(PTS) = max(PTS) And min(PTS) = 0 And        
min(PTR) = max(PTR) And min(PTR) = 0 And        
min((Case UOM When 0 Then SalePrice Else UOMPrice END)) = max((Case UOM When 0 Then SalePrice Else UOMPrice END)) And       
min((Case UOM When 0 Then SalePrice Else UOMPrice END)) = 0 And        
min(MRP) = max(MRP) And min(MRP) = 0 



