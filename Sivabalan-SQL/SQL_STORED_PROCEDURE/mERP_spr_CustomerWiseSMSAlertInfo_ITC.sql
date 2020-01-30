CREATE PROCEDURE mERP_spr_CustomerWiseSMSAlertInfo_ITC 
AS
	Declare @WDForumCode As nVarchar(256) 

	Select @WDForumCode = RegisteredOwner From Setup 

	Select CustomerID, [Customer ID] = @WDForumCode  +'_'+ CustomerID, [Customer Name] = Company_Name, [Mobile Number] = MobileNumber, 
		[SMS Alert] = Case When IsNull(SMSAlert, 0) = 0 Then 'No' Else 'Yes' End 
	From Customer Where CustomerCategory Not In (4,5) and isnull(active,0)=1 order by Company_Name
