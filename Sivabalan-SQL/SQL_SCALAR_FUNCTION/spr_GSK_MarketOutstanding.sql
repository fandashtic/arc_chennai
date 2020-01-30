CREATE Function spr_GSK_MarketOutstanding(@ToDate Datetime, @CurrentDate Datetime)        
Returns Decimal(18, 2)        
As        
Begin        
Declare @Sales Decimal(18, 2)        
Declare @SalesReturn Decimal(18, 2)        
Declare @CreditNote Decimal(18, 2)        
Declare @DebitNote Decimal(18, 2)        
Declare @Advance Decimal(18, 2)        
Declare @F_ToDate Datetime      
        
Set @SalesReturn = (IsNull((Select Sum(IsNull(Balance, 0))
From InvoiceAbstract        
Where IsNull(Balance, 0) > 0 And        
InvoiceType in (4) And IsNull(Status, 0) & 192 = 0), 0) -    
IsNull((Select Sum(IsNull(NetValue, 0) + IsNull(Roundoffamount, 0))
From InvoiceAbstract        
Where (IsNull(NetValue, 0) + IsNull(Roundoffamount, 0)) > 0 And        
InvoiceType in (4) And IsNull(Status, 0) & 192 = 0 And    
InvoiceDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))    
    
Set @DebitNote = (IsNull((Select Sum(ISNULL(Balance, 0)) from DebitNote         
Where CustomerID Is Not Null And IsNull(Balance, 0) > 0), 0) -     
IsNull((Select Sum(ISNULL(NoteValue, 0)) from DebitNote         
Where CustomerID Is Not Null And IsNull(NoteValue, 0) > 0 And     
DocumentDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))
    
Set @CreditNote = (IsNull((Select Sum(ISNULL(Balance, 0)) from CreditNote
Where CustomerID Is Not Null And IsNull(Balance, 0) > 0), 0) -    
IsNull((Select Sum(ISNULL(NoteValue, 0)) from CreditNote
Where CustomerID Is Not Null And IsNull(NoteValue, 0) > 0 And    
DocumentDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))    
       
Set @Advance = (IsNull((Select Sum(IsNull(Balance, 0))
From Collections        
Where IsNull(Balance, 0) > 0  And IsNull(Status, 0) & 192 = 0       
And CustomerID Is Not Null ), 0) -    
IsNull((Select Sum(IsNull(Value, 0))
From Collections        
Where IsNull(Value, 0) > 0  And IsNull(Status, 0) & 192 = 0 And CustomerID Is     
Not Null And DocumentDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))
    
Set @Sales = (IsNull((Select Sum(IsNull(Balance, 0))
From InvoiceAbstract        
Where IsNull(Balance, 0) > 0 And        
InvoiceType in (1, 3) And IsNull(Status, 0) & 192 = 0), 0) -    
IsNull((Select Sum(IsNull(NetValue, 0) + IsNull(Roundoffamount, 0))
From InvoiceAbstract        
Where (IsNull(NetValue, 0) + IsNull(Roundoffamount, 0)) > 0 And        
InvoiceType in (1, 3) And IsNull(Status, 0) & 192 = 0 And    
InvoiceDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))    
       
Return (@Sales + @DebitNote - @SalesReturn - @CreditNote - @Advance)        
End 

