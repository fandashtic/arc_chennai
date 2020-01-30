create Procedure sp_updateGVNO (@CreditID int)
AS
BEGIN
	Update CreditNote set GiftVoucherNo=DocumentReference where CreditID =@CreditID 
END
