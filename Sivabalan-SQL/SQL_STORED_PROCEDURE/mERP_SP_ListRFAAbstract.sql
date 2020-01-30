Create Procedure mERP_SP_ListRFAAbstract(@RFAID as int)
As
Begin
Declare @WDCode NVarchar(255)  
Declare @WDDest NVarchar(255)  
Declare @CompaniesToUploadCode NVarchar(255)  
	
    Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
	Select Top 1 @WDCode = RegisteredOwner From Setup  
	
	If @CompaniesToUploadCode = N'ITC001'
		Set @WDDest= @WDCode  
	Else  
	  Begin  
		Set @WDDest= @WDCode  
		Set @WDCode= @CompaniesToUploadCode  
	  End
    Select @WDCode,@WDDest,'RFA'+ Cast(RFADocID as nvarchar),
    SchemeType,ActivityCode,Description,ActiveFrom,ActiveTo,PayoutFrom,
    PayoutTo,Division,SubCategory,MarketSKU,SystemSKU,UOM,SaleQty,SaleValue,PromotedQty,
    PromotedValue,FreeBaseUOM,RebateQty,RebateValue,BudgetedQty,BudgetedValue,SubmissionDate, AppOn ,
	'RFA'+ Cast(RFAID as nvarchar)
	From tbl_mERP_RFAAbstract 
	Where RFAID=@RFAID
	Order By RFAID
End
