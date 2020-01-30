Create Procedure sp_update_SchemeCustomerItems(     
  @SchemeID as Int,     
  @CustomerID as nvarchar(30),    
  @Product_Code as nvarchar(30),    
  @Quantity as Decimal(18,6), @CSQPSFlag Int = 0,
  @InvoiceID Int = 0,
  @InvPayoutID Int = 0)
as
Begin
Declare @Pending as Decimal(18,6) 
Declare @PendingQty Decimal(18,6)
Declare @InvoiceRefLst nVarchar(1000) 
If @CSQPSFlag = 1
Begin
  Declare @PayoutID Int 
  Declare @UPDATECNT Int 
  Set @UPDATECNT = 0 
  SET @Pending  = 0 
  Declare CurSchPayouts Cursor For 
  Select PayoutID , Case IsNull(IsInvoiced,0) When 0 Then Pending Else Quantity End, IsNull(InvoiceRef,'')
  From SchemeCustomerItems
  Where SchemeID = @SchemeID and    
     PayoutID = @InvPayoutID and  
     CustomerID = @CustomerID and    
     Product_Code = @Product_Code and IsNull(Pending,0) > 0 
  Order by PayoutID
  Open CurSchPayouts
  Fetch Next From CurSchPayouts Into @PayoutID, @Pending, @InvoiceRefLst
  Begin
    IF @Quantity > 0 
    Begin
      Declare CurUpdtSchCustItem Cursor For
      Select Case IsNull(IsInvoiced,0) When 0 Then Pending Else Quantity End
      From SchemeCustomerItems 
      Where SchemeID = @SchemeID and    
      CustomerID = @CustomerID and    
      Product_Code = @Product_Code and 
      PayoutID = @PayoutID and Pending > 0 
      OPen CurUpdtSchCustItem
      Fetch Next From CurUpdtSchCustItem Into @PendingQty
      While @@Fetch_status = 0
        Begin
         Update SchemeCustomerItems Set Pending = (Case When @Quantity >= @PendingQty Then 0 Else @PendingQty - @Quantity End), Claimed = 1
         Where CURRENT OF CurUpdtSchCustItem
         Set @Quantity = @Quantity - @PendingQty
         Fetch Next From CurUpdtSchCustItem Into @PendingQty
        End
      Close CurUpdtSchCustItem
      Deallocate CurUpdtSchCustItem 
      If Len(@InvoiceRefLst) > 0 
      Begin
        Update SchemeCustomerItems Set IsInvoiced = 1, InvoiceRef = Cast(@InvoiceID as nVarchar(15)) Where SchemeID = @SchemeID And CustomerID = @CustomerID  and PayoutID = @PayoutID  and InvoiceRef = @InvoiceRefLst
      End  
      Else
      Begin
        Update SchemeCustomerItems Set IsInvoiced = 1, InvoiceRef = Cast(@InvoiceID as nVarchar(15)) Where SchemeID = @SchemeID And CustomerID = @CustomerID  and PayoutID = @PayoutID 	
      End
      Set @UPDATECNT = @UPDATECNT + 1 
    End 
    Fetch Next From CurSchPayouts Into @PayoutID, @Pending, @InvoiceRefLst
  End
  Close CurSchPayouts
  Deallocate CurSchPayouts
  Select Case @UPDATECNT when 0 Then 0 Else 1 End 
End
Else 
  Begin
    Select @Pending = Sum(Pending) From SchemeCustomerItems READUNCOMMITTED   
    Where SchemeID = @SchemeID and    
     CustomerID = @CustomerID and    
     Product_Code = @Product_Code   
    IF @Pending >= @Quantity  
    Begin
      Declare CurUpdtSchCustItem Cursor For
      Select Pending From SchemeCustomerItems 
      Where SchemeID = @SchemeID and    
      CustomerID = @CustomerID and    
      Product_Code = @Product_Code and Pending > 0   
      OPen CurUpdtSchCustItem
      Fetch Next From CurUpdtSchCustItem Into @PendingQty
      While @@Fetch_status = 0
      Begin
        Update SchemeCustomerItems Set Pending = (Case When @Quantity >= @PendingQty Then 0 Else @PendingQty - @Quantity End), Claimed = 1
        Where CURRENT OF CurUpdtSchCustItem
        Set @Quantity = @Quantity - @PendingQty
        Fetch Next From CurUpdtSchCustItem Into @PendingQty
      End
      Close CurUpdtSchCustItem
      Deallocate CurUpdtSchCustItem 
      Select 1 
    End
    Else 
    Begin
    Select 0 
    End
  End
End
