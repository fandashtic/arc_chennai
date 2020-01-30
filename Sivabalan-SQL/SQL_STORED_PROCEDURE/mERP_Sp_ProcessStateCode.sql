Create Procedure mERP_Sp_ProcessStateCode
AS
Begin

Declare @GSTIN nVarchar(15)
Declare @CS_StateID int
Declare @Doc_TrackID int

Declare @Errmessage nVarchar(4000)
Declare @ErrStatus int

Set @ErrStatus = 0

Select  @GSTIN = GSTIN,@CS_StateID = CS_StateID,@Doc_TrackID = Doc_TrackID 
from Recd_WDStateCode where  IsNull(Status,0) = 0

Set @ErrStatus = 0

--If ((Isnull(@GSTIN,'') = '') )
--Begin
--	Set @Errmessage = 'GSTIN should not be Null'
--	Set @ErrStatus = 1
--	Goto last
--End

If (@GSTIN Like '%[^a-zA-Z0-9]%' )
Begin
	Set @Errmessage = 'GSTIN should be Alpha Numeric'
	Set @ErrStatus = 1
	Goto last
End
--If ((Len(@GSTIN) > 15) )
--Begin
--	Set @Errmessage = 'GSTIN should be lesser than or Equal to  15  chanracters'
--	Set @ErrStatus = 1
--	Goto last
--End 
If (@CS_StateID  Not in (Select Distinct StateID from StateCode ) )
Begin
	Set @Errmessage = 'Invalid StateID'
	Set @ErrStatus = 1
	Goto last
End

	Update Setup Set BillingStateID  = @CS_StateID, ShippingStateID  = @CS_StateID ,GSTIN = @GSTIN  
		
	Update Vendors Set BillingStateID  = @CS_StateID
	Where isnull(BillingStateID,0) = 0  and isnull(Locality,0) = 1
	
	Update Customer Set BillingStateID  = @CS_StateID
	Where isnull(BillingStateID,0) = 0 and isnull(Locality,0) = 1
	
	Update Customer Set  ShippingStateID  = @CS_StateID 
	Where isnull(ShippingStateID,0) = 0 and isnull(Locality,0) = 1
		
	Update WareHouse Set BillingStateID  = @CS_StateID, GSTIN = @GSTIN  
		
	Update Recd_WDStateCode Set Status = 1 where Doc_TrackID = @Doc_TrackID
	


Declare @KeyValue nVarchar(255)

Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = ''
		Set @Errmessage = 'Company Setup:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage)
		Set @KeyValue = Convert(nVarchar, @Doc_TrackID)
		Update Recd_WDStateCode Set Status = 64 where Doc_TrackID = @Doc_TrackID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('TransferStateCode', @Errmessage,  @KeyValue, getdate())  
	End

End
