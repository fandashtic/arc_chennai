Create Procedure sp_List_BeatWiseNotBilledCustomer_ITC(
     @Month Int,  
	 @Year Int,   
	 @BeatList nVarchar(2550), 
	 @SubCategoryList nVarchar(2550))  
As  
Declare @FromDate Datetime 
Declare @ToDate Datetime
Declare @FirstMonthST Datetime 
Declare @FifthMonthEOM Datetime 
Declare @BeatIDs TABLE (ItemValue Int )
Declare @SubCatIDs Table (ItemValue Int)
Declare @CustBeat Table (CustID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatID Int, 
BeatName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS) 

create table #tItems (Items nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, SubCatID Int)
Declare @colSubCatName nVarchar(256) 
Declare @colSubCatID Int 
Declare @SqlStr nVarChar(4000)
--Beat wise customer sales removed.
Create Table #tempCustSales(CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS
	, BeatID Int, BeatName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #CustWiseBeatWiseSales(CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	BeatName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CategoryName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	LMSalSts int,CMSalSts int,CustCatSts int)

/*To get Last 6month from date and last month Todate Currentmonth fromDate and Todate */
Set DateFormat DMY
Set @FromDate = N'01/' + Cast(@Month As nVarchar) + N'/' + Cast(@Year As nVarchar)
Set @ToDate = DateAdd(ss, -1, DateAdd(mm, 1, @FromDate))
Set @FifthMonthEOM = DateAdd(ss, -1, @FromDate) 
Set @FirstMonthST = DateAdd(mm, -5, @FromDate) 

Insert InTo @BeatIDS
Select ItemValue From fn_SplitIn2Rows_Int(@BeatList, ',')

Insert InTo @SubCatIDs 
Select ItemValue From fn_SplitIn2Rows_Int(@SubCategoryList, ',')

Insert InTo @CustBeat 
Select Distinct cs.CustomerID, cs.Company_Name, bt.BeatID, bt.Description 
From Beat_Salesman bs, Customer cs, Beat bt, @BeatIDs bid 
Where bs.CustomerID = cs.CustomerID 
and bs.BeatID = bt.BeatID 
And bt.BeatID = bid.ItemValue 
and Cs.Active = 1 

Declare @GPID nvarchar(200)
select @GPID = dbo.mERP_fn_Get_CGMappedForSalesMan_Beat(@BeatList)

Declare @GId Table   
(  
 CatGroupID Int   
)  
  
Insert Into @GId  
Select Cast(ItemValue As Int) From dbo.sp_SplitIn2Rows(@GPID,',') 

Declare @allItems Table (Items nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
insert into @allItems(Items)
Select Distinct Product_Code from dbo.Fn_Get_Items_ITC_FromItems(@GPID)

/* If OCG is enabled then select the items which belongs to selected category alone*/
If(Select max(isnull(OCGType,0)) from ProductCategoryGroupAbstract where groupid in (Select CatGroupID from @GId ))=1
BEGIN
	Delete from @allItems where Items not in (
	Select its.Product_Code
	From Items its, ItemCategories itsc, @SubCatIDs sc 
	Where Its.CategoryID = itsc.CategoryID 
	And itsc.ParentID = sc.ItemValue 
	And itsc.Level = 4 )

END

/* If OCG is enabled then consider only the OCG enabled Items */
If(Select max(isnull(OCGType,0)) from ProductCategoryGroupAbstract where groupid in (Select CatGroupID from @GId ))=1
BEGIN
	Insert InTo #tItems
	Select its.Product_Code, itsc.ParentID 
	From Items its, ItemCategories itsc, @SubCatIDs sc,@allItems A 
	Where Its.CategoryID = itsc.CategoryID 
	And itsc.ParentID = sc.ItemValue 
	And itsc.Level = 4 
	And A.Items=its.Product_code
END
ELSE
BEGIN
	Insert InTo #tItems
	Select its.Product_Code, itsc.ParentID 
	From Items its, ItemCategories itsc, @SubCatIDs sc 
	Where Its.CategoryID = itsc.CategoryID 
	And itsc.ParentID = sc.ItemValue 
	And itsc.Level = 4 
END

Insert #CustWiseBeatWiseSales 
Select "CustomerID" = cb.CustID, "CustomerName" = cb.CustName, 
"BeatName" = cb.BeatName, 
"CategoryName" = (Select Category_Name From ItemCategories icg Where icg.CategoryID = sci.Itemvalue) , 
"LMSalsts" = 
Case When IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia, InvoiceDetail idtl , #tItems its
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb.CustID And
		  --ia.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Items And 
		  its.SubCatID = sci.Itemvalue And 
		  ia.InvoiceDate Between @FirstMonthST And @FifthMonthEOM  
	) Als ), 0) = 0  Then 0 Else 1 End,
"CMSalsts" = 
Case When IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia, InvoiceDetail idtl , #tItems its
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb.CustID And
		  --ia.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Items And 
		  its.SubCatID = sci.Itemvalue And 
		  ia.InvoiceDate Between @fromDate And @ToDate  
	) Als ), 0) = 0  Then 0 Else 1 End,0
From @CustBeat cb , @SubCatIDs sci 


/*To update Customer Category Handler Status*/
update #CustWiseBeatWiseSales set CustCatSts = 1 
from #CustWiseBeatWiseSales CBS,CustomerProductCategory CPC,ItemCategories IC
where CBS.Customerid = CPC.Customerid 
and CBS.Categoryname = IC.Category_name 
and IC.Categoryid = CPC.Categoryid
and CPC.Active = 1


--Beat wise customer sales removed.
Insert Into #tempCustSales (CustomerID , CustomerName , BeatID, BeatName) 
Select CustID, CustName , isnull(BeatID,''), isnull(BeatName ,'')
From @CustBeat 
Order By CustName 
Set @SqlStr = ''
Declare curSubCatList Cursor For 
	Select icg.Category_Name, icg.CategoryID From ItemCategories icg, @SubCatIDs sci
	Where icg.CategoryID = sci.ItemValue 
	Order By icg.Category_Name 
Open curSubCatList 
	Fetch Next From curSubCatList Into @colSubCatName, @colSubCatID  
	While @@Fetch_Status = 0
	Begin
		Set @SqlStr = 'Alter Table #tempCustSales Add [' + @colSubCatName + '] 
		nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS '  
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = 'Update tCS Set tCS.[' + @colSubCatName + '] =  
		Case When CMsalsts > 0  then ''''
		when CMsalsts = 0 and LMsalsts = 1 then ''X''
		when CMSalsts = 0 and LMSalsts = 0 and CustCatSts = 1 then ''XX''
		else ''''
		end
		From #tempCustSales tCS,#CustWiseBeatWiseSales tCBS 
		Where tCS.CustomerName = tCBS.CustomerName 		
		And tCBS.CategoryName Like ''' + @colSubCatName + ''''
		--And tCS.BeatName = tCBS.BeatName 
		exec (@SqlStr) 
		Set @SqlStr = ''
	Fetch Next From curSubCatList Into @colSubCatName, @colSubCatID 
	End
Close curSubCatList 
Deallocate curSubCatList 

Select "RecordCount" = Count(*) from #tempCustSales 

select * from #tempCustSales 
Order BY CustomerName 
