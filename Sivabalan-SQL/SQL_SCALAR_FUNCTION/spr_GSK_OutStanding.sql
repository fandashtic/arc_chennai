CREATE Function spr_GSK_OutStanding(@Vendor nvarchar(255), @ToDate Datetime, @CurrentDate Datetime)      
Returns Decimal(18,6)    
As      
Begin      
Declare @F_ToDate Datetime  
Declare @PurchaseReturn Decimal(18,6)    
Declare @DebitNote Decimal(18,6)    
Declare @CreditNote Decimal(18,6)    
Declare @Advance Decimal(18,6)    
Declare @Purchase Decimal(18,6)    
  
Set @F_ToDate = Cast(Datepart(dd, @ToDate) As nvarchar) + '/'   
+ Cast(Datepart(mm, @ToDate) As nvarchar) + '/'   
+ Cast(Datepart(yyyy, @ToDate) As nvarchar)  
  
Set @PurchaseReturn = (IsNull((Select Sum(IsNull(Balance, 0))
From AdjustmentReturnAbstract Where Balance > 0 And IsNull(Status, 0) & 192 = 0), 0) -   
IsNull((Select Sum(IsNull(Total_Value, 0))
From AdjustmentReturnAbstract Where IsNull(Total_Value, 0) > 0   
And IsNull(Status, 0) & 192 = 0 And AdjustmentDate Between DateAdd(dd, 1, @F_ToDate)   
And @CurrentDate), 0))  
  
Set @DebitNote = (IsNull((Select Sum(ISNULL(Balance, 0)) from DebitNote       
Where VendorID Is Not Null And IsNull(Balance, 0) > 0), 0) -   
IsNull((Select Sum(ISNULL(NoteValue, 0)) from DebitNote       
Where VendorID Is Not Null And IsNull(NoteValue, 0) > 0 And   
DocumentDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))  
  
Set @CreditNote = (IsNull((Select Sum(ISNULL(Balance, 0)) from CreditNote       
Where VendorID Is Not Null And IsNull(Balance, 0) > 0), 0) -  
IsNull((Select Sum(ISNULL(NoteValue, 0)) from CreditNote       
Where VendorID Is Not Null And IsNull(NoteValue, 0) > 0 And  
DocumentDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))  
  
Set @Advance = (IsNull((Select Sum(IsNull(Balance, 0))
From Payments Where IsNull(Balance, 0) > 0 And IsNull(Status, 0) & 192 = 0      
And VendorID Is Not Null), 0) - IsNull((Select Sum(IsNull(Value, 0)) From Payments Where   
IsNull(Value, 0) > 0 And IsNull(Status, 0) & 192 = 0 And VendorID Is Not Null And   
DocumentDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))  
      
Set @Purchase = (IsNull((Select Sum(ISNULL(Balance, 0)) from BillAbstract       
where Status & 192 = 0 And IsNull(Balance, 0) > 0), 0) -   
IsNull((Select Sum(ISNULL(Value, 0) + IsNull(AdjustmentAmount, 0) + IsNull(TaxAmount, 0)) from BillAbstract
where Status & 192 = 0 And (IsNull(Value, 0) + IsNull(AdjustmentAmount, 0) + IsNull(TaxAmount, 0)) > 0 And  
BillDate Between DateAdd(dd, 1, @F_ToDate) And @CurrentDate), 0))  
  
Return (@Purchase + @CreditNote - @PurchaseReturn - @DebitNote - @Advance)    
End  

