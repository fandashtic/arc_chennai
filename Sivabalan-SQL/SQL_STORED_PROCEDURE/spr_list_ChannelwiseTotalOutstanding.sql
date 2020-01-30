CREATE Procedure spr_list_ChannelwiseTotalOutstanding (@Date DateTime)    
As          
          
Create Table #temp(ChannelType Int, Value Decimal(18,6))          
-- Invoice          
Insert #temp(ChannelType, Value) 
Select ChannelType, IsNull(Sum(Balance),0) 
From Customer cu Join InvoiceAbstract ia On cu.CustomerID = ia.CustomerID 
Where (IsNull(Status,0) & 192) = 0 And InvoiceType In (1,3) And IsNull(Balance,0) > 0     
and dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date)  
Group By ChannelType          

-- Debit Note          
Insert #temp(ChannelType, Value) 
Select ChannelType, IsNull(Sum(Balance),0) 
From Customer cu Join DebitNote dr On cu.CustomerID = dr.CustomerID 
Where IsNull(Balance,0) > 0  and dbo.stripdatefromtime(DocumentDate) <= dbo.stripdatefromtime(@Date) 
Group By ChannelType          
  
-- Credit Note          
Insert #temp(ChannelType, Value) 
Select ChannelType, 0 - IsNull(Sum(Balance),0) 
From Customer cu Join CreditNote cr On cu.CustomerID = cr.CustomerID 
Where IsNull(Balance,0) > 0 and dbo.stripdatefromtime(DocumentDate) <= dbo.stripdatefromtime(@Date) 
Group By ChannelType               
  
-- Sales Return  
Insert #temp(ChannelType, Value)   
Select ChannelType, 0 - IsNull(Sum(Balance),0)   
From Customer cu Join InvoiceAbstract ia On cu.CustomerID = ia.CustomerID   
Where IsNull(Balance,0) > 0   
And (IsNull(Status,0) & 192) = 0   
And InvoiceType in (4)           
and dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date)  
Group By ChannelType          
  
-- Invoice Collections made after the given date is Added.  
Insert #temp(ChannelType, Value)  
Select Customer.ChannelType, Isnull(Sum(CollectionDetail.AdjustedAmount), 0)   
From Collections, Customer, CollectionDetail, InvoiceAbstract  
Where Collections.CustomerID = Customer.CustomerID   
and dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)  
and Collections.DocumentID = CollectionDetail.CollectionID  
and InvoiceAbstract.CustomerID = Customer.CustomerID  
and CollectionDetail.DocumentID = InvoiceAbstract.InvoiceID   
and DocumentType = 4  
and dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date)  
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by Customer.ChannelType  
  
-- Debit Note Collections made after the given date is Added   
Insert #temp(ChannelType, Value)  
Select Customer.ChannelType, Isnull(Sum(CollectionDetail.AdjustedAmount), 0)   
From Collections, Customer, CollectionDetail, DebitNote  
Where Collections.CustomerID = Customer.CustomerID   
and dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)  
and Collections.DocumentID = CollectionDetail.CollectionID  
and DebitNote.CustomerID = Customer.CustomerID  
and CollectionDetail.DocumentID = DebitNote.DocumentID  
and DocumentType = 5  
and dbo.stripdatefromtime(DebitNote.DocumentDate) <= dbo.stripdatefromtime(@Date)  
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by Customer.ChannelType   
  
-- Credit Note Collection made after the given date is Deducted   
Insert #temp(ChannelType, Value)  
Select Customer.ChannelType, 0-(Isnull(Sum(CollectionDetail.AdjustedAmount), 0))   
From Collections, Customer, CollectionDetail, CreditNote  
Where Collections.CustomerID = Customer.CustomerID   
and dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)  
and Collections.DocumentID = CollectionDetail.CollectionID  
and CreditNote.CustomerID = Customer.CustomerID  
and CollectionDetail.DocumentID = CreditNote.DocumentID  
and DocumentType = 2  
and dbo.stripdatefromtime(CreditNote.DocumentDate) <= dbo.stripdatefromtime(@Date)  
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by Customer.ChannelType  
  
-- Sales Return made after the given date is Deducted   
Insert #temp(ChannelType, Value)  
Select Customer.ChannelType, 0-(Isnull(Sum(CollectionDetail.AdjustedAmount), 0))  
From Collections, Customer, CollectionDetail, InvoiceAbstract  
Where Collections.CustomerID = Customer.CustomerID   
and dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)  
and Collections.DocumentID = CollectionDetail.CollectionID  
and InvoiceAbstract.CustomerID = Customer.CustomerID  
and CollectionDetail.DocumentID = InvoiceAbstract.InvoiceID   
and DocumentType = 1  
and dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date)  
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by Customer.ChannelType  
  
-- Advance Collections Deducted.
Insert #temp(ChannelType, Value) Select ChannelType, 0 - IsNull(Sum(Balance),0) From      
Customer cu Join Collections cl On cu.CustomerID = cl.CustomerID Where       
IsNull(Balance,0) > 0 And (IsNull(Status,0) & 192) = 0 
and dbo.stripdatefromtime(DocumentDate) <= dbo.stripdatefromtime(@Date) 
Group By ChannelType 

Select NULL, ChannelDesc "Channel Name", IsNull(Sum(Value),0) "Total Outstanding (%c)" From        
Customer_Channel cc Join #temp te on cc.ChannelType = te.ChannelType           
Group By te.ChannelType, cc.ChannelDesc    
  
Drop Table #temp   
  



