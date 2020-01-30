Create Procedure Spr_CategoryHandler_ITC (
 @Level NVarChar(25),
 @Categories NVarChar(4000),   
 @AllCustomer NVarchar(30),  
 @ActiveCust NVarchar(30)
 )
As
Begin
Declare @Delimeter Char(1)  
Set @Delimeter=Char(15)
----------
Declare @BCount Int, @i Int, @SQLStr nVarchar(4000)
Declare @CBeat nVarchar(256), @CSalesman nVarchar(256)
----------
If @Categories = 'All Categories'
set @Categories = '%'
if @Level = 'Sub_Cat' or @Level = 'Sub Category' or @Level = 'Sub-Category' or @Level = 'Subcategory'
set @Level = 'Sub_Category'
Set @AllCustomer = dbo.LookupDictionaryItem2(@AllCustomer, Default)  
Set @ActiveCust = dbo.LookupDictionaryItem2(@ActiveCust, Default)  

If @Level = '%'
Set @Level = N'Division' 
-----------
Set @CBeat = dbo.LookupDictionaryItem(N'Beat', Default)  
Set @CSalesman = dbo.LookupDictionaryItem(N'Salesman', Default)  
-----------
Create Table #TmpCategoryHandler(CustID nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Customer ID] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Customer Name] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
         [Categories Being Handled] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
         [Sub Categories Being Handled] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS --,
--         Salesmans nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
--	     Beats nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS
		)

Create Table #TmpCategories(CategoryID Int)

Create Table #tmpCustomer(CustomerID nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
        Company_Name nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
If @Categories <> N'%'  and @Level = N'Division'
 Insert InTo #TmpCategories Select Distinct CategoryID From ItemCategories Where Level in(3) 
	                    and ParentID in(Select CategoryID from ItemCategories Where Category_Name In 
                                        (Select ItemValue From Dbo.sp_SplitIn2Rows(@Categories,@Delimeter)))
Else If @Categories <> N'%'  and @Level = N'Sub_Category'
 Insert InTo #TmpCategories Select Distinct CategoryID From ItemCategories Where Level in(3) 
	                    and Category_Name In (Select ItemValue From Dbo.sp_SplitIn2Rows(@Categories,@Delimeter))
Else
 Insert InTo #TmpCategories Select Distinct CategoryID From ItemCategories Where Level=3

If @ActiveCust =N'Active Customer' 
 Insert Into #tmpCustomer Select CustomerID,Company_Name From Customer Where Active = 1 and CustomerID <> '0'  Order by CustomerID
Else  
 Insert Into #tmpCustomer Select CustomerID,Company_Name From Customer Where CustomerID <> '0' Order by CustomerID

If @AllCustomer = N'All Customer' or @AllCustomer = N'%' and @Categories = N'%'
Begin
	Insert into #TmpCategoryHandler
		Select CustomerID,CustomerID,Company_Name,'' [Categories Being Handled],'' [Sub Categories being Handled] --, 
--		[Salesmans]=dbo.fn_getsalesmancustomer (CustomerID),
--		[Beats]=dbo.fn_getbeatcustomer (CustomerID)
		From #tmpCustomer 
        Where CustomerID not in(Select Distinct CustomerID from CustomerProductCategory Where CustomerID<>'0' And Active=1) 
        and   CustomerID <>'0'
		Order By 1
End
Insert into #TmpCategoryHandler 
Select CPC.CustomerID,CPC.CustomerID,CustomerName =(Select Company_Name from #tmpCustomer Where CustomerID=CPC.CustomerID),
[Categories Being Handled]=(Select Category_Name from ItemCategories 
Where CategoryID=(Select ParentID From ItemCategories Where CategoryID=CPC.CategoryID)),
[Sub Categories being Handled]=(Select Category_Name from ItemCategories Where CategoryID=CPC.CategoryID) --,
--[Salesmans]=dbo.fn_getsalesmancustomer (CPC.CustomerID),
--[Beats]=dbo.fn_getbeatcustomer (CPC.CustomerID)
from CustomerProductCategory CPC Where 
	CPC.CustomerID in(Select CustomerID from #tmpCustomer)
and CPC.CategoryID in(Select CategoryID from #TmpCategories)
Order By 4,5,3

Set @BCount = 0
Set @i = 0

Select @BCount = Max([BeatCount]) From (
Select Distinct "CustomerID" = bsm.CustomerID, "BeatCount" = Count(Distinct bt.Description)
from Beat bt, Beat_Salesman bsm
Where bt.BeatID = bsm.BeatID 
	And bsm.CustomerID In (Select Distinct [Customer ID] From #TmpCategoryHandler)
Group By bsm.CustomerID
--Order By Count(Distinct bt.Description)
) al
--Group By [CustomerID]
--Having [BeatCount] = Max([BeatCount])
--Order By CustomerID

While @i < @BCount 
Begin
--	Set  @CBeat = '[' + @CBeat + ' ' + Cast(@i + 1 As nVarchar) + ']'
--	select @CBeat
	Set @SQLStr = 'Alter Table #TmpCategoryHandler Add [' + @CBeat + ' ' + Cast(@i + 1 As nVarchar) + '] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS'
	Exec (@SQLStr)
	Set @SQLStr = 'Alter Table #TmpCategoryHandler Add [' + @CSalesman + ' ' + Cast(@i + 1 As nVarchar) + '] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS'
	Exec (@SQLStr)

	Set @SQLStr = 'Update tmp Set [' + @CBeat + ' ' + Cast(@i + 1 As nVarchar) + '] = 
	dbo.mERP_fn_GetBeatSalesman_ITC(tmp.[Customer ID], 1, ' + Cast(@i + 1 As nVarchar) + ' ),
	[' + @CSalesman + ' ' + Cast(@i + 1 As nVarchar) + '] = 
	dbo.mERP_fn_GetBeatSalesman_ITC(tmp.[Customer ID], 2, ' + Cast(@i + 1 As nVarchar) + ' )
	From #TmpCategoryHandler tmp'

--	Update tmp Set [Beat 2] = 
--	(Select Beat From dbo.mERP_fn_GetBeatSalesman_ITC(tmp.CustomerID) Where IDs = 1) 
--	From #TmpCategoryHandler tmp

--	 Update tmp Set select "Beat 2" = dbo.mERP_fn_GetBeatSalesman_ITC (tmp.CustomerID, 1, 1) From #TmpCategoryHandler tmp

	Exec (@SQLStr)

	Set @i = @i + 1
End

Select * from #TmpCategoryHandler
Drop Table #TmpCategoryHandler
Drop Table #TmpCategories
Drop Table #tmpCustomer
End
