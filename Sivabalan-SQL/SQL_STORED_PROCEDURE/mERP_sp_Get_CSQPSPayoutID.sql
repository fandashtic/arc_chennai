Create Procedure mERP_sp_Get_CSQPSPayoutID(@SchemeID Int, @CustomerID nVarchar(50), @InvoiceID Int, @SerialNo Int)
As
Begin
  Declare @tmpInvoiceRef Table(ID Int Identity, PayoutID INT)
  Declare @SchPayoutID INT
    
  /*When More than 1 Payout Adjusted in a single invoice*/
  If (Select Count(*) From SchemeCustomerItems where IsNull(InvoiceRef,0) = @InvoiceID and CustomerID = @CustomerID and SchemeID = @SchemeID and Claimed = 1 ) > 1
  Begin
    Declare curInvRef  Cursor For
    Select Distinct PayoutID from SchemeCustomerItems where IsNull(InvoiceRef,0) = @InvoiceID and CustomerID = @CustomerID and SchemeID = @SchemeID and Claimed = 1
    Open curInvRef
    Fetch Next From curInvRef Into @SchPayoutID
    While @@Fetch_Status = 0
    Begin
      Insert into @tmpInvoiceRef Select @SchPayoutID
      Fetch Next From curInvRef Into @SchPayoutID
    End
    Close curInvRef
    Deallocate curInvRef
    Select PayoutID From @tmpInvoiceRef Where ID = @SerialNo
  End 
Else 
  Begin
    Select Top 1 Isnull(PayoutID,0) from SchemeCustomerItems where SchemeID = @SchemeID and CustomerID = @CustomerID and  IsNull(InvoiceRef,0) = @InvoiceID and Claimed = 1
  End 
End
