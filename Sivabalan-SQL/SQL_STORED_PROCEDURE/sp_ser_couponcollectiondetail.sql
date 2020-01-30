CREATE procedure sp_ser_couponcollectiondetail(@PaymentType as int,@PartyAccountID as int)
as
If @PaymentType = 4 /* Coupon */ 
begin 
	Select 0 'Checked', SerialNo 'DOCID', FullDocID, Company_Name 'Name',
	PaymentMode.Value 'CouponName', Coupon.qty 'Qty', Coupon.Denomination 'Rate', Coupon.Value 'Amount', 
	ProviderServiceCharge 'ServiceCharge', 1 'DocType' 
	from Collections 
	Inner Join Coupon On Coupon.CollectionID =  Collections.DocumentID 
	Inner Join PaymentMode On PaymentMode.Mode = Collections.PaymentModeID
	Inner Join Customer On Customer.CustomerID = Collections.CustomerID 
	Where 
	IsNull(CouponDepositID, 0) = 0 and IsNull(Status, 0) & 192 = 0 and IsNull(BankID,0) =  @PartyAccountID and
	IsNull(Collections.PaymentMode,0) = 5
	Union
	Select 0 'Checked', ContraSerialCode 'DOCID',dbo.getoriginalid(ContraDetail.ContraID,74) 'FullDocID', AdditionalInfo_Customer 'Name',
	AdditionalInfo_Number 'CouponName', AdditionalInfo_Qty 'Qty',AdditionalInfo_Value 'Rate',AdditionalInfo_Amount 'Amount',
	AdditionalInfo_ServiceCharge 'ServiceCharge', 0 'DocType' from 
	ContraDetail,ContraAbstract where ContraAbstract.ContraID=ContraDetail.ContraID and 
	ContraAbstract.ToUser='Main' and  IsNull(ContraAbstract.Status,0)=0 and
	AdditionalInfo_Party=@PartyAccountID and IsNull(AdjustedFlag,0)=0 and
	PaymentType=@PaymentType and ToAccountID=95 -- Coupon Account (Main)
end 



