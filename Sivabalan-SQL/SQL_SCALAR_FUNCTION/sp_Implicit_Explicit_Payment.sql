create Function sp_Implicit_Explicit_Payment (@BillID Integer)
Returns Int
As
begin
Declare @PaymentID Int
Declare @Bill_ID int
Declare @Final_Value int
Declare @Collect_Count int
-- retriving the Bill type
Select @PaymentID =  Isnull(PaymentID,0) 
			from BillAbstract 
			where BillID = @BillID
--  if the payment Id is not null then, implicit payment has happened once
If @PaymentID <> 0 
begin
	Set @Final_Value = 0
	Declare Explicit_Payments Cursor For   
	Select Count(*), PaymentDetail.DocumentID From PaymentDetail, Payments
	where Payments.DocumentID <> @PaymentID And 
	PaymentDetail.DocumentID = @BillID And 
	Payments.DocumentID = PaymentDetail.PaymentID And
	IsNull(Payments.Status,0) & 192 = 0 And
	PaymentDetail.DocumentType = 4 and VendorID Is Not Null
	Group By PaymentDetail.DocumentID
	Open Explicit_Payments
	Fetch From Explicit_Payments Into @Collect_Count, @Bill_ID
	If @Collect_Count > 0
	Begin
		Set @Final_Value = 1
	End
	Close Explicit_Payments
	DeAllocate Explicit_Payments
end
-- if the paymentID is null, then whether the Payment for bill is already happened
-- if made return '1' and '0' otherwise
else
begin
    Select @Bill_ID = PaymentDetail.DocumentID
	from PaymentDetail, Payments
	where PaymentDetail.DocumentID = @BillID And 
	Payments.DocumentID = PaymentDetail.PaymentID and
	IsNull(Payments.Status,0) & 192 = 0 And 
	PaymentDetail.DocumentType = 4
	and VendorID Is Not Null
    If IsNull(@Bill_ID, 0) = 0
    begin
        set @Final_Value = 0
    end
    else
    begin	    
		Set @Final_Value = 1
    end
end
return @Final_Value
end


