Create Procedure MERP_SPR_TMDCategoryHandler_XML(@FromDate datetime, @ToDate datetime)  
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

Create Table #TmpCatHandler (
	WDCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	WDDest NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	FromDate DateTime,
	ToDate Datetime,	
	CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CategoriesBeingHandled nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	SubCategoriesbeingHandled nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo #TmpCatHandler(WDCode, WDDest, FromDate, ToDate, 
	CustomerID, CustomerName, CategoriesBeingHandled, SubCategoriesbeingHandled)

Select "WD Code" = @WDCode , "WD Dest Code" = @WDDestCode , 
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
	Where CPC.CustomerID = cs.CustomerID 
	And CPC.CreationDate Between @FromDate And @ToDate) als
	Where  [Categories Being Handled] Is Not Null
Order By 3,4,2

Select "_1" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(WDCode, '')),
	"_2" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(WDDest, '')),
	"_3" = Convert(nVarchar(10),FromDate,103),
	"_4" = Convert(nVarchar(10),ToDate,103),
	"_5" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CustomerID, '')),
	"_6" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CustomerName, '')),
	"_7" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CategoriesBeingHandled, '')),
	"_8" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(SubCategoriesbeingHandled, ''))
From  #TmpCatHandler As Abstract For XML Auto, ROOT ('Root')  



