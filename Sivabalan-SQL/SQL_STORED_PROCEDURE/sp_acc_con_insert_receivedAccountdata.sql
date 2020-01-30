CREATE Procedure sp_acc_con_insert_receivedAccountdata(
				@CompanyID nVarchar(15),
				@Date DateTime,
				@AccountID Int,
				@AccountName nVarchar (120),
				@AccountGroupID Int,
				@OpeningBalance Decimal(18,2),
				@ClosingBalance Decimal(18,2),
				@Depreciation Decimal(18,2),
				@Fixed Int)
As
Set @Date=dbo.StripDateFromTime(@Date)
If Not Exists(Select Top 1 AccountID from ReceiveAccount Where CompanyID=@CompanyID and Date=@Date and AccountID=@AccountID)
Begin
	Insert Into ReceiveAccount Values(@CompanyID,
						@Date,
						@AccountID,
						@AccountName,
						@AccountGroupID,
						@OpeningBalance,
						@ClosingBalance,
						@Depreciation,
						@Fixed)
End
Else
Begin
	Update ReceiveAccount Set AccountGroupID=@AccountGroupID,
					OpeningBalance=@OpeningBalance,
					ClosingBalance=@ClosingBalance,
					Depreciation=@Depreciation,
					Fixed=@Fixed
	Where CompanyID=@CompanyID and Date=@Date and AccountID=@AccountID 
End


