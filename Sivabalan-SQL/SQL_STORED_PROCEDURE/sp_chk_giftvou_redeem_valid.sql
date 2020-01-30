CREATE Procedure sp_chk_giftvou_redeem_valid (@SequenceNo nvarchar(250),@RedAmount Decimal(18,6))
As
Begin
	Declare @Result as Int
	Set @Result = -1
	If Exists(Select SequenceNumber From GiftVoucherDetail Where SequenceNumber = @SequenceNo)
	Begin
	Select @Result = Case When (IsNull(AmountReceived,0) - (IsNull(AmountRedeemed,0) + @RedAmount)) < 0 then 0 Else 1 End
	From GiftVoucherDetail
	Where SequenceNumber=@SequenceNo 
	End
	Select @Result
End


