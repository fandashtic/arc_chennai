CREATE Procedure spr_list_BeatwiseTotalOutstanding (@Date DateTime)     
As      
      
Create Table #temp(BeatID Int, Value Decimal(18,6))      
-- Invoice      
Insert #temp(BeatID, Value) 
Select BeatID, IsNull(Sum(Balance),0) 
From InvoiceAbstract 
Where (IsNull(Status,0) & 192) = 0 And InvoiceType In (1,3) And       
IsNull(Balance,0) > 0 And dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date) 
Group By BeatID      

-- Debit note
Insert #temp(BeatID, Value) 
Select IsNull(BeatID,0), IsNull(Sum(Balance),0) 
From Beat_Salesman bs Right Join DebitNote dr On bs.CustomerID = dr.CustomerID 
Where IsNull(Balance,0) > 0 And dbo.stripdatefromtime(DocumentDate) <= dbo.stripdatefromtime(@Date) 
Group By BeatID      
      
-- Credit Note
Insert #temp(BeatID, Value) 
Select IsNull(BeatID,0), 0 - IsNull(Sum(Balance),0) From      
Beat_Salesman bs Right Join CreditNote cr On bs.CustomerID = cr.CustomerID 
Where IsNull(Balance,0) > 0 And dbo.stripdatefromtime(DocumentDate) <= dbo.stripdatefromtime(@Date) 
Group By BeatID           
  
-- Sales Return
Insert #temp(BeatID, Value) 
Select Isnull(BeatID,0), 0 - IsNull(Sum(Balance),0) 
From InvoiceAbstract 
Where (IsNull(Status,0) & 192) = 0 And InvoiceType In (4) And       
IsNull(Balance,0) > 0 And dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date) 
Group By BeatID      

-- Invoice Collections made after the given date is Added.
Insert #temp(Collections.BeatID, Value)
Select Isnull(InvoiceAbstract.BeatID, 0), Isnull(Sum(CollectionDetail.AdjustedAmount), 0) 
From Collections, CollectionDetail, InvoiceAbstract
Where dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)
and Collections.DocumentID = CollectionDetail.CollectionID
and CollectionDetail.DocumentID = InvoiceAbstract.InvoiceID 
and DocumentType = 4
and dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date)
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by InvoiceAbstract.BeatID      

-- Debit Note Collections made after the given date is Added 
Insert #temp(BeatID, Value)
Select IsNull(Collections.BeatID, 0), Isnull(Sum(CollectionDetail.AdjustedAmount), 0) 
From Collections, CollectionDetail, DebitNote
Where Collections.CustomerID = DebitNote.CustomerID
and dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)
and Collections.DocumentID = CollectionDetail.CollectionID
and CollectionDetail.DocumentID = DebitNote.DocumentID
and DocumentType = 5
and dbo.stripdatefromtime(DebitNote.DocumentDate) <= dbo.stripdatefromtime(@Date)
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by Collections.BeatID

-- Credit Note Collections made after the given date is Deducted.
Insert #temp(BeatID, Value)
Select Isnull(Collections.BeatID, 0), 0 - Isnull(Sum(CollectionDetail.AdjustedAmount), 0) 
From Collections, CollectionDetail, CreditNote
Where Collections.CustomerID = CreditNote.CustomerID
and dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)
and Collections.DocumentID = CollectionDetail.CollectionID
and CollectionDetail.DocumentID = CreditNote.DocumentID
and DocumentType = 2
and dbo.stripdatefromtime(CreditNote.DocumentDate) <= dbo.stripdatefromtime(@Date)
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by Collections.BeatID

-- Sales Return Collections made after the given date is Deducted.
Insert #temp(BeatID, Value)
Select Isnull(InvoiceAbstract.BeatID, 0), 0 - Isnull(Sum(CollectionDetail.AdjustedAmount), 0) 
From Collections, CollectionDetail, InvoiceAbstract
Where dbo.stripdatefromtime(Collections.DocumentDate) > dbo.stripdatefromtime(@Date)
and Collections.DocumentID = CollectionDetail.CollectionID
and CollectionDetail.DocumentID = InvoiceAbstract.InvoiceID 
and DocumentType = 1
and dbo.stripdatefromtime(InvoiceDate) <= dbo.stripdatefromtime(@Date)
And (IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0  
Group by InvoiceAbstract.BeatID 

-- Advance Collections Deducted.
Insert #temp(BeatID, Value) 
Select IsNull(BeatID,0), 0 - IsNull(Sum(Balance),0) From    
Collections Where IsNull(Balance,0)  > 0 and (IsNull(Status,0) & 192) = 0 
and dbo.stripdatefromtime(DocumentDate) <= dbo.stripdatefromtime(@Date) 
Group By BeatID    

Select NULL, IsNull([Description],'Others') "Beat Name", IsNull(Sum(Value),0) "Total Outstanding (%c)" From       
Beat bt Right Join #temp te on bt.BeatID = te.BeatID       
Group By te.BeatID, bt.[Description]      
      
Drop Table #temp 



