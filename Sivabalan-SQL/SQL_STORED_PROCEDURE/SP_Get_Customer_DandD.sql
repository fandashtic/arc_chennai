Create Procedure SP_Get_Customer_DandD
AS
BEGIN

	--Select Company_Name, isnull(BillingAddress,'') From Customer Where isnull(DnDFlag,0) = 1
	Select Company_Name, '' From Customer Where isnull(DnDFlag,0) = 1
	
END
