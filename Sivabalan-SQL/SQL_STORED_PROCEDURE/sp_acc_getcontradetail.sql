CREATE Procedure sp_acc_getcontradetail(@PaymentType as int,@PartyAccountID as int)
As
--Contra Document Type=74
If @PaymentType=3 -- CreditCard
Begin
	Select 'No',ContraSerialCode,dbo.getoriginalid(ContraDetail.ContraID,74),AdditionalInfo_Customer,
	AdditionalInfo_Number,AdditionalInfo_Type,OriginalID,AdditionalInfo_Amount,AdditionalInfo_ServiceCharge from 
	ContraDetail,ContraAbstract where ContraAbstract.ContraID=ContraDetail.ContraID and 
	ContraAbstract.ToUser=N'Main' and  IsNull(ContraAbstract.Status,0)=0 and
	AdditionalInfo_Party=@PartyAccountID and IsNull(AdjustedFlag,0)=0 and
	PaymentType=@PaymentType and ToAccountID=94 -- Credit Card Account (Main)
End
Else If @PaymentType=4 -- Coupon
Begin
	Select 'No',ContraSerialCode,dbo.getoriginalid(ContraDetail.ContraID,74),AdditionalInfo_Customer,
	AdditionalInfo_Number,AdditionalInfo_Qty,AdditionalInfo_Value,AdditionalInfo_Amount,AdditionalInfo_ServiceCharge from 
	ContraDetail,ContraAbstract where ContraAbstract.ContraID=ContraDetail.ContraID and 
	ContraAbstract.ToUser=N'Main' and  IsNull(ContraAbstract.Status,0)=0 and
	AdditionalInfo_Party=@PartyAccountID and IsNull(AdjustedFlag,0)=0 and
	PaymentType=@PaymentType and ToAccountID=95 -- Coupon Account (Main)

End

