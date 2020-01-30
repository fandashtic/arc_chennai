CREATE Procedure sp_Get_ReceivedInvoice_BatchDetails (@InvoiceID Int,      
       @Product_Code nvarchar(20))      
As      
Declare @Forum_Code nvarchar(20)    
Select @Forum_Code = Alias From Items Where Product_Code = @Product_Code    
    
Select InvoiceDetailReceived.PKD, InvoiceDetailReceived.Batch_Number,       
InvoiceDetailReceived.Expiry,       
"Quantity" = Sum(Case InvoiceDetailReceived.SalePrice When 0 Then 0 Else InvoiceDetailReceived.Quantity End),       
"Free" = IsNull((Select Sum(Quantity) From InvoiceDetailReceived a Where       
a.InvoiceID = @InvoiceID And      
(((a.PKD Is Null) And (InvoiceDetailReceived.PKD Is Null)) Or a.PKD = InvoiceDetailReceived.PKD) And      
a.Batch_Number = InvoiceDetailReceived.Batch_Number And       
(((a.Expiry Is Null) And (InvoiceDetailReceived.Expiry Is Null)) Or a.Expiry = InvoiceDetailReceived.Expiry)       
And a.PTS = 0 And a.PTR = 0 And a.MRP = 0 And a.FreePTS = InvoiceDetailReceived.PTS And a.SalePrice = 0 And      
a.FreePTR = InvoiceDetailReceived.PTR And a.FreeMRP = InvoiceDetailReceived.MRP), 0),       
InvoiceDetailReceived.PTS, InvoiceDetailReceived.PTR,      
InvoiceDetailReceived.MRP, InvoicedetailReceived.TaxCode,    
InvoiceDetailReceived.TaxApplicableOn,  
InvoiceDetailReceived.TaxPartOff, InvoiceDetailReceived.Company_Price
From InvoiceDetailReceived      
Where InvoiceDetailReceived.InvoiceID = @InvoiceID And       
InvoiceDetailReceived.ForumCode = @Forum_Code And      
Not (PTS = 0 And PTR = 0 and MRP = 0 And SalePrice = 0)      
Group By InvoiceDetailReceived.PKD, InvoiceDetailReceived.Batch_Number,       
InvoiceDetailReceived.Expiry, InvoiceDetailReceived.PTS, InvoiceDetailReceived.PTR,      
InvoiceDetailReceived.MRP, InvoicedetailReceived.TaxCode,    
InvoiceDetailReceived.TaxApplicableOn,  
InvoiceDetailReceived.TaxPartOff,InvoiceDetailReceived.Company_Price          
      
Union      
      
Select InvoiceDetailReceived.PKD, InvoiceDetailReceived.Batch_Number,       
InvoiceDetailReceived.Expiry,       
"Quantity" = Sum(Case InvoiceDetailReceived.SalePrice When 0 Then 0 Else InvoiceDetailReceived.Quantity End),       
"Free" = IsNull((Select Sum(Quantity) From InvoiceDetailReceived a Where       
a.InvoiceID = @InvoiceID And      
(((a.PKD Is Null) And (InvoiceDetailReceived.PKD Is Null)) Or a.PKD = InvoiceDetailReceived.PKD) And      
a.Batch_Number = InvoiceDetailReceived.Batch_Number And       
(((a.Expiry Is Null) And (InvoiceDetailReceived.Expiry Is Null)) Or a.Expiry = InvoiceDetailReceived.Expiry)       
And a.PTS = 0 And a.PTR = 0 And a.MRP = 0 And a.FreePTS <> InvoiceDetailReceived.PTS And a.SalePrice = 0 And      
a.FreePTR <> InvoiceDetailReceived.PTR And a.FreeMRP <> InvoiceDetailReceived.MRP), 0),       
InvoiceDetailReceived.PTS, InvoiceDetailReceived.PTR,      
InvoiceDetailReceived.MRP, InvoicedetailReceived.TaxCode,  
InvoiceDetailReceived.TaxApplicableOn,  
InvoiceDetailReceived.TaxPartOff, InvoiceDetailReceived.Company_Price
From InvoiceDetailReceived      
Where InvoiceDetailReceived.InvoiceID = @InvoiceID And       
InvoiceDetailReceived.ForumCode = @Forum_Code And      
InvoiceDetailReceived.ForumCode Not In (Select a.ForumCode      
From InvoiceDetailReceived a       
Where a.InvoiceID = @InvoiceID And      
a.ForumCode = @Forum_Code And      
(((a.PKD Is Null) And (InvoiceDetailReceived.PKD Is Null)) Or a.PKD = InvoiceDetailReceived.PKD) And      
a.Batch_Number = InvoiceDetailReceived.Batch_Number And       
(((a.Expiry Is Null) And (InvoiceDetailReceived.Expiry Is Null)) Or a.Expiry = InvoiceDetailReceived.Expiry)       
And (a.PTS <> 0 Or a.PTR <> 0 Or a.MRP <> 0 Or a.SalePrice <> 0))      
Group By InvoiceDetailReceived.PKD, InvoiceDetailReceived.Batch_Number,       
InvoiceDetailReceived.Expiry, InvoiceDetailReceived.PTS, InvoiceDetailReceived.PTR,      
InvoiceDetailReceived.MRP, InvoicedetailReceived.TaxCode,  
InvoiceDetailReceived.TaxApplicableOn,  
InvoiceDetailReceived.TaxPartOff, InvoiceDetailReceived.Company_Price
Having min(PTS) = max(PTS) And min(PTS) = 0 And      
min(PTR) = max(PTR) And min(PTR) = 0 And      
min(SalePrice) = max(SalePrice) And min(SalePrice) = 0 And      
min(MRP) = max(MRP) And min(MRP) = 0      
    
    
  
  

