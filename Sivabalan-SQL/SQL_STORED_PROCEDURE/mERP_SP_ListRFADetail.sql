Create Procedure mERP_SP_ListRFADetail(@RFAID as int)
As
Begin
Declare @WDCode NVarchar(255)  
Declare @WDDest NVarchar(255)  
Declare @CompaniesToUploadCode NVarchar(255)  
Declare @RFADocID Int
	
    Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
	Select Top 1 @WDCode = RegisteredOwner From Setup  
	
	If @CompaniesToUploadCode = N'ITC001'
		Set @WDDest= @WDCode  
	Else  
	  Begin  
		Set @WDDest= @WDCode  
		Set @WDCode= @CompaniesToUploadCode  
	  End

	Select @RFADocID = RFADocID From tbl_mERP_RFAAbstract Where RFAID  = @RFAID



    Select @WDCode,@WDDest,'RFA'+ Cast(@RFADocID as nvarchar),
    ActivityCode,CSSchemeID,Description,ActiveFrom,ActiveTo,BillRef,RFA.CustomerID,RFA.RCSID,RFA.ActiveInRCS,LineType
    ,Division,SubCategory,MarketSKU,SystemSKU,UOM,SaleQty,SaleValue,PromotedQty,
    PromotedValue,RebateQty,RebateValue,
    Price_Excl_Tax,Tax_Percentage,Tax_Amount,Price_Incl_Tax,
    BudgetedQty,BudgetedValue,Cust.Company_Name,'RFA'+ Cast(RFAID as nvarchar)
    From tbl_mERP_RFADetail RFA,Customer Cust
	Where RFAID  = @RFAID
	And RFA.CustomerID = Cust.CustomerID
	Order By RFAID
End
