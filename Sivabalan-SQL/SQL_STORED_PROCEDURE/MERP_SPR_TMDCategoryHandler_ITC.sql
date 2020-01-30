Create Procedure MERP_SPR_TMDCategoryHandler_ITC(@FromDate datetime, @ToDate datetime)  
As  
Declare @WDCode as nVarchar(100)  
Declare @WDDestCode as nVarchar(100)
Declare @CompaniesToUploadCode as nVarchar(255)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload      
Select Top 1 @WDCode = RegisteredOwner From Setup        

If @CompaniesToUploadCode='ITC001'      
	Set @WDDestCode= @WDCode      
Else      
Begin      
	Set @WDDestCode= @WDCode      
	Set @WDCode= @CompaniesToUploadCode      
End      


Select "WD Code" = @WDCode, "WD Code" = @WDCode , "WD Dest Code" = @WDDestCode , 
	"From Date" = @FromDate, "To Date" = @ToDate, [Customer ID], [Customer Name], [Categories Being Handled], 
	[Sub Categories being Handled] From 
	(Select "Customer ID" = CPC.CustomerID, 
		"Customer Name" = cs.Company_Name,
		"Categories Being Handled" = Case CPC.CategoryID When 0 Then '' Else (Select Category_Name from ItemCategories 
			Where CategoryID=(Select ParentID From ItemCategories Where CategoryID=CPC.CategoryID
				And [Level] = 3)) End,
		"Sub Categories being Handled" = Case CPC.CategoryID When 0 Then '' Else (Select Category_Name From ItemCategories 
		Where CategoryID=CPC.CategoryID And [Level] = 3) End
	From CustomerProductCategory CPC, Customer cs 
	Where CPC.CustomerID = cs.CustomerID and isnull(CPC.Active,0) =1
	And CPC.CreationDate Between @FromDate And @ToDate) als
	Where  [Categories Being Handled] Is Not Null
Order By 4,5,3

