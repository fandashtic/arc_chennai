Create Function FN_V_Category_Group()
Returns @Data Table (Group_ID int,Group_Name nvarchar(50),SalesmanID int,Category_ID int,Category_Name nvarchar(255),Creation_Date datetime,Active int)
AS
BEGIN
	If(Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
	BEGIN
	insert into @Data (Group_ID,Group_Name,SalesmanID,Category_ID,Category_Name,Creation_Date,Active)
	SELECT     
		ProductCategoryGroupAbstract.Groupid, ProductCategoryGroupAbstract.GroupName, DsHandle.SalesmanID, 
		ItemCategories.CategoryID
	, ItemCategories.Category_name, ProductCategoryGroupAbstract.CreationDate, 
		(Case ItemCategories.Active When 0 then 0 else ProductCategoryGroupAbstract.Active end)
	FROM ProductCategoryGroupAbstract, tblCGDivMapping, ItemCategories, DsHandle,
	(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
	  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
	where 
	ProductCategoryGroupAbstract.GroupName = tblCGDivMapping.CategoryGroup and
	tblCGDivMapping.Division = ItemCategories.Category_name and
	ProductCategoryGroupAbstract.Groupid = DsHandle.GroupID and 
	HHS.Salesmanid=DsHandle.Salesmanid  and 
	ISnULL(DsHandle.SalesmanID,0) <> 0 and
	isnull(OCGType,0)=0
	END
	ELSE
	BEGIN
	insert into @Data (Group_ID,Group_Name,SalesmanID,Category_ID,Category_Name,Creation_Date,Active)	
	SELECT distinct    
		ProductCategoryGroupAbstract.Groupid, ProductCategoryGroupAbstract.GroupName, DsHandle.SalesmanID, 
		IC2.CategoryID
	, IC2.Category_name, ProductCategoryGroupAbstract.CreationDate, 
		(Case IC2.Active When 0 then 0 else ProductCategoryGroupAbstract.Active end)
	FROM ProductCategoryGroupAbstract, dbo.Fn_GetOCGSKU('%') Temp, DsHandle,
	(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
	  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS,
	ItemCategories IC4,ItemCategories IC3,ItemCategories IC2
	where 
	ProductCategoryGroupAbstract.GroupID = Temp.GroupID and
	Temp.CategoryID = IC4.CategoryID and
	ProductCategoryGroupAbstract.Groupid = DsHandle.GroupID and 
	HHS.Salesmanid=DsHandle.Salesmanid  and 
	ISnULL(DsHandle.SalesmanID,0) <> 0 And
	isnull(OCGType,0)=1 and
	Temp.CategoryID=IC4.CategoryID
	And IC4.Parentid=IC3.CategoryID
	And IC3.ParentID=IC2.CategoryID
	END
	Return
END
