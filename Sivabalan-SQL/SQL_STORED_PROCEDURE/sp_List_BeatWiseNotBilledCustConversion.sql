Create Procedure sp_List_BeatWiseNotBilledCustConversion(
     @Month Int,  
	 @Year Int,   
	 @BeatList nVarchar(2550), 
	 @SubCategoryList nVarchar(2550))  
As
Declare @FromDate Datetime 
Declare @ToDate Datetime
Declare @FirstMonthST Datetime 
Declare @FifthMonthEOM Datetime 
Declare @FifthMonthBOM Datetime 
Declare @MTDStartDt dateTime 
Declare @MTDEndDt Datetime
Declare @MTDStartMth Datetime
Declare @MTDEndMth Datetime 
Declare @TranDate Datetime 
Declare @colSubCatName nVarchar(256) 
Declare @colSubCatID Int 
Declare @SqlStr nVarChar(4000)
Declare @tblSQL nVarChar(4000)
Declare @CatName nVarchar(255)
Declare @CatListforSQL nvarchar(4000)

Declare @BeatIDs TABLE (ItemValue Int )
Declare @SubCatIDs Table (ItemValue Int)
Declare @CustBeat Table (CustID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
         CustName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatID Int, 
         BeatName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS) 

Create table #tItems (Items nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, SubCatID Int)

--GR4 Items table to Filter SalesValue 
Create table #tGR4Items (Items nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, SubCatID Int)

--result table 
Create Table #tempCustSales(CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    BeatID Int, BeatName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Period nVarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS)

--table to get the conversion for given categories 
Create Table #CustBeatWiseConversion(CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	BeatName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CategoryName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Period nVarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS,
	LMSalSts int,CMSalSts int,CustCatSts int)

--table to get the Selected Month and Transaction Month Sales and Bill Value 
Create table #CustBeatWiseSalesVal(CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    BeatID Int, Period nVarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS,  
    SalesValue Decimal(18,6), NoOfBills Int)

--table to calculate the Conversion 
Create table #CatConvTotal(RowID int Identity(1,1), ConvCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

--LM and MTD Period calculations
Set DateFormat DMY
Set @FromDate = N'01/' + Cast(@Month As nVarchar) + N'/' + Cast(@Year As nVarchar)
Set @ToDate = DateAdd(ss, -1, DateAdd(mm, 1, @FromDate))
Set @FifthMonthEOM = DateAdd(ss, -1, @FromDate)
If @Month = 1 
  Set @FifthMonthBOM = N'01/12' + N'/' + Cast((@Year -1) As nVarchar)
Else 
  Set @FifthMonthBOM = N'01/' + Cast((@Month - 1) As nVarchar) + N'/' + Cast(@Year As nVarchar)
Set @FirstMonthST = DateAdd(mm, -5, @FromDate)
--Select @TranDate = dbo.StripTimeFromDate(TransactionDate) From Setup
--Set @MTDStartDt = N'01/'+ Cast(Month(@TranDate) as nVarchar(2)) + N'/'+ Cast(Year(@TranDate) as nVarchar(4)) 
--Select @MTDEndDt = dbo.MakeDayEnd(@TranDate)
--Set @MTDStartMth = DateAdd(mm, -5, @MTDStartDt) 
--Set @MTDEndMth = DateAdd(ss, -1, @MTDStartDt)

--Select @FromDate, @ToDate, @FifthMonthBOM, @FifthMonthEOM, @FirstMonthST
--Select @MTDStartDt, @MTDEndDt, @MTDStartMth, @MTDEndMth

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

Declare @allItems_OCG Table (Items nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
insert into @allItems_OCG(Items)
Select Items from @allItems


/* If OCG is enabled then select the items which belongs to selected category alone*/
If(Select max(isnull(OCGType,0)) from ProductCategoryGroupAbstract where groupid in (Select CatGroupID from @GId ))=1
BEGIN
	Delete from @allItems_OCG where Items not in (
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
	From Items its, ItemCategories itsc, @SubCatIDs sc,@allItems_OCG A 
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


Insert into #tGR4Items
Select I.Product_Code, IC1.CategoryID 
from ITemCategories IC, tblCGDivMapping CGM, ItemCategories IC1, ItemCategories IC2, Items I
Where CGM.CategoryGroup Like N'GR4'
and CGM.Division = IC.Category_Name 
and IC1.ParentID = IC.CategoryID 
and IC2.ParentID = IC1.CategoryID 
and IC2.CategoryID = I.CategoryID 
and I.Active = 1

--LM Conversion history for selected month 
Insert #CustBeatWiseConversion
Select "CustomerID" = cb.CustID, "CustomerName" = cb.CustName, 
"BeatName" = cb.BeatName, 
"CategoryName" = (Select Category_Name From ItemCategories icg Where icg.CategoryID = sci.Itemvalue), 
"Period" =N'LM',
"LMSalsts" = 
Case When IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia, InvoiceDetail idtl , #tItems its
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb.CustID And
--		  ia.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Items And 
		  its.SubCatID = sci.Itemvalue And 
		  ia.InvoiceDate Between @FirstMonthST And @FifthMonthEOM  
	) Als ), 0) = 0  Then 0 Else 1 End,
"CMSalsts" = 
Case When IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia, InvoiceDetail idtl , #tItems its
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb.CustID And
--		  ia.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Items And 
		  its.SubCatID = sci.Itemvalue And 
		  ia.InvoiceDate Between @fromDate And @ToDate  
	) Als ), 0) = 0  Then 0 Else 1 End,0 
From @CustBeat cb , @SubCatIDs sci

--MTD conversion history for selected month 
Insert #CustBeatWiseConversion
Select "CustomerID" = cb.CustID, "CustomerName" = cb.CustName, 
"BeatName" = cb.BeatName,
"CategoryName" = (Select Category_Name From ItemCategories icg Where icg.CategoryID = sci.Itemvalue), 
"Period" =N'MTD',
"LMSalsts" = 
Case When IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia, InvoiceDetail idtl , #tItems its
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb.CustID And
--		  ia.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Items And 
		  its.SubCatID = sci.Itemvalue And 
		  ia.InvoiceDate Between @FirstMonthST And @FifthMonthEOM  
	) Als ), 0) = 0  Then 0 Else 1 End,
"CMSalsts" = 
Case When IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia, InvoiceDetail idtl , #tItems its
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb.CustID And
--		  ia.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Items And 
		  its.SubCatID = sci.Itemvalue And 
		  ia.InvoiceDate Between @fromDate And @ToDate  
	) Als ), 0) = 0  Then 0 Else 1 End,0
From @CustBeat cb , @SubCatIDs sci

-- Customer Category Handler Status update
update #CustBeatWiseConversion set CustCatSts = 1 
from #CustBeatWiseConversion CBS,CustomerProductCategory CPC,ItemCategories IC
where CBS.Customerid = CPC.Customerid 
and CBS.Categoryname = IC.Category_name 
and IC.Categoryid = CPC.Categoryid
and CPC.Active = 1

--LM Customers
Insert Into #tempCustSales (CustomerID , CustomerName , BeatID, BeatName, Period) 
Select CustID, CustName , isnull(BeatID,''), isnull(BeatName ,''), N'LM'
From @CustBeat 
Order By CustName 
--MTD Customers
Insert Into #tempCustSales (CustomerID , CustomerName , BeatID, BeatName, Period) 
Select CustID, CustName , isnull(BeatID,''), isnull(BeatName ,''), N'MTD'
From @CustBeat 
Order By CustName 



--Sales Update for LM and MTD
set @tblSQL = ''
set @SqlStr = ''
set @CatListforSQL = ''
Declare curSubCatList Cursor For 
	Select icg.Category_Name, icg.CategoryID From ItemCategories icg, @SubCatIDs sci
	Where icg.CategoryID = sci.ItemValue 
	Order By icg.Category_Name 
    Open curSubCatList 
	Fetch Next From curSubCatList Into @colSubCatName, @colSubCatID  
	While @@Fetch_Status = 0
	Begin
        Set @tblSQL = 'Alter table #CatConvTotal Add  [' + @colSubCatName + '] Decimal(18,6) Default 0'  
        exec (@tblSQL)
		Set @SqlStr = 'Alter Table #tempCustSales Add [' + @colSubCatName + '] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS '  
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = 'Update tCS Set tCS.[' + @colSubCatName + '] =  
		Case when tCS.Period = ''LM'' and CMsalsts = 1 and LMsalsts = 1 then ''X''
        when tCS.Period = ''LM'' and CMsalsts = 0 and LMsalsts = 1 then ''X''
        when tCS.Period = ''LM'' and  CMSalsts = 1 and LMSalsts = 0 and CustCatSts = 1 then ''XX''
        when tCS.Period = ''LM'' and  CMSalsts = 0 and LMSalsts = 0 and CustCatSts = 1 then ''XX''
		when tCS.Period = ''MTD'' and CMsalsts > 0  then ''''
		when tCS.Period = ''MTD'' and CMsalsts = 0 and LMsalsts = 1 then ''X''
		when tCS.Period = ''MTD'' and CMSalsts = 0 and LMSalsts = 0 and CustCatSts = 1 then ''XX''   
		else ''''
		end
		From #tempCustSales tCS,#CustBeatWiseConversion tCBS 
		Where tCS.CustomerName = tCBS.CustomerName and tCS.BeatName = tCBS.BeatName
        And tCS.Period = tCBS.Period
		And tCBS.CategoryName Like ''' + @colSubCatName + ''''
		--And tCS.BeatName = tCBS.BeatName 
		exec (@SqlStr) 
		Set @SqlStr = ''
	Fetch Next From curSubCatList Into @colSubCatName, @colSubCatID 
	End
Close curSubCatList 
Deallocate curSubCatList 

-- Add on columns for Conversions and Sales
Alter Table #tempCustSales Add XXConversion int, XConversion int, SalesValue Decimal(18,6), NoOfBills Int

--Total Row Insert for value update 
Insert into #CatConvTotal(ConvCategory) Values ('Total no. of XX - LM')
Insert into #CatConvTotal(ConvCategory) Values ('Sub cat level XX Conversions')
Insert into #CatConvTotal(ConvCategory) Values ('Percentage of XX Conversion')
Insert into #CatConvTotal(ConvCategory) Values ('Total no. of X - LM')
Insert into #CatConvTotal(ConvCategory) Values ('Sub cat level X Conversions')
Insert into #CatConvTotal(ConvCategory) Values ('Percentage of X Conversion')

-- Cursor to conversion count
Declare @mySQL nVarchar(2000) 
Set @SqlStr = ''
Declare Cur_CatLst Cursor For
Select icg.Category_Name From ItemCategories icg, @SubCatIDs sci
Where icg.CategoryID = sci.ItemValue 
Order By icg.Category_Name
Open Cur_CatLst
Fetch Next From Cur_CatLst into @CatName
While @@Fetch_status =0 
Begin
-- SQL to Update Conversion Count on XXConversion and Xconversion Columns
  Set @SqlStr = 'Update MTD Set mtd.XXConversion = IsNull(mtd.XXConversion,0) + (Case When (IsNull(MTD.'+ @CatName +','''') = N'''' and IsNull(LM.'+ @CatName +','''') = ''XX'') Then 1 Else 0 End), '
              + '  mtd.XConversion = IsNull(mtd.XConversion,0) + (Case When (IsNull(MTD.'+ @CatName +','''') = N'''' and IsNull(LM.'+ @CatName +','''') = ''X'') Then 1 Else 0 End)  '
              + '  From #tempCustSales MTD , #tempCustSales LM '
              + '  Where MTD.Period = ''MTD'' and LM.Period = ''LM'''
              + '  and MTD.CustomerID = LM.CustomerID and MTD.BeatID = LM.BeatID'
  Exec sp_ExecuteSQL @SqlStr
-- SQL to update the Sum of XX Conversion 
  set @SqlStr = 'Update #CatConvTotal Set '+ @CatName +' = (Select Count(Distinct CustomerID) from #tempCustSales Where '+ @CatName +' like ''XX'' and Period=''LM'') where RowID = 1'
  Exec sp_ExecuteSQL @SqlStr
-- SQL to update sub cat level XX Conversion   
  set @SqlStr = 'Update #CatConvTotal Set '+ @CatName +' = IsNull((Select Count(*) From '
  + '(Select CustomerID, Count('+ @CatName +') as ''LM'' From #tempCustSales Where PEriod=''LM'' and IsNull('+ @CatName +','''') Like ''XX'' Group By CustomerID) LMXX,'
  + '(Select CustomerID, Count('+ @CatName +') as ''MTD'' From #tempCustSales Where PEriod=''MTD'' and IsNull('+ @CatName +','''') Like '''' Group By CustomerID) MTDXX '
  + 'Where LMXX.CustomerID = MTDXX.CustomerID),0) where RowID = 2'
  Exec sp_ExecuteSQL @SqlStr
-- SQL to update the Sum of X Conversion 
  set @SqlStr = 'Update #CatConvTotal Set '+ @CatName +' = (Select Count(Distinct CustomerID) from #tempCustSales Where '+ @CatName +' like ''X'' and Period=''LM'') where RowID = 4'
  Exec sp_ExecuteSQL @SqlStr
-- SQL to update sub cat level X Conversion   
  set @SqlStr = 'Update #CatConvTotal Set '+ @CatName +' = IsNull((Select Count(*) From '
  + '(Select CustomerID, Count('+ @CatName +') as ''LM'' From #tempCustSales Where PEriod=''LM'' and IsNull('+ @CatName +','''') Like ''X'' Group By CustomerID) LMXX,'
  + '(Select CustomerID, Count('+ @CatName +') as ''MTD'' From #tempCustSales Where PEriod=''MTD'' and IsNull('+ @CatName +','''') Like '''' Group By CustomerID) MTDXX '
  + 'Where LMXX.CustomerID = MTDXX.CustomerID),0) where RowID = 5'
  Exec sp_ExecuteSQL @SqlStr  
-- SQL to update Percentage of XX Conversion
  set @SqlStr = 'Update #CatConvTotal Set '+ @CatName +' = (((Select '+ @CatName +' from #CatConvTotal Where RowID = 2) / (Case (Select '+ @CatName +' from #CatConvTotal Where RowID = 1) When 0 Then 1 Else (Select '+ @CatName +' from #CatConvTotal Where RowID = 1) End))*100) where RowID = 3'
  Exec sp_ExecuteSQL @SqlStr
-- SQL to update Percentage of X Conversion
  set @SqlStr = 'Update #CatConvTotal Set '+ @CatName +' = (((Select '+ @CatName +' from #CatConvTotal Where RowID = 5) / (Case (Select '+ @CatName +' from #CatConvTotal Where RowID = 4) When 0 Then 1 Else (Select '+ @CatName +' from #CatConvTotal Where RowID = 4) End))*100) where RowID = 6'
  Exec sp_ExecuteSQL @SqlStr
  Fetch Next From Cur_CatLst into @CatName
End
Close Cur_CatLst
Deallocate Cur_CatLst

--LM Sales and Bill Value 
Insert into #CustBeatWiseSalesVal
Select "CustomerID" = cb1.CustID, 
"BeatID" = cb1.BeatID,
"Period"=N'LM',
"SalesValue" = IsNull((Select (Case When Sum(Amount) < 0 Then 0 Else Sum(Amount) End) From
	(Select Case ia.InvoiceType When 4 Then Sum(Amount) * -1 Else Sum(Amount) End as Amount
    From InvoiceAbstract ia, InvoiceDetail idtl , Items its, --@CustBeat cb,
	@AllItems tI
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3,4) And ia.CustomerID = cb1.CustID And
--          cb1.CustID = cb.CustID And
		  its.Product_code=tI.Items and 
--		  ia.BeatID = cb.BeatID And 
--          cb1.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Product_code And 
          its.Product_code not in (Select items From #tGR4Items) and 
		  ia.InvoiceDate Between @FifthMonthBOM And @FifthMonthEOM Group By ia.InvoiceType)A),0),
"NoOfBills" = IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia, InvoiceDetail idtl , Items its, --@CustBeat cb,
		@AllItems tI
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb1.CustID And
--          cb1.CustID = cb.CustID And 
		  its.Product_code=tI.Items and 
--		  ia.BeatID = cb.BeatID And 
--          cb1.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Product_code And 
		  its.Product_code not in (Select items From #tGR4Items) and 
		  ia.InvoiceDate Between @FifthMonthBOM And @FifthMonthEOM  
	) Als ), 0)
From @CustBeat cb1

--MTD Sales and Bill Vlaue 
Insert into #CustBeatWiseSalesVal
Select "CustomerID" = cb1.CustID, 
"BeatID" = cb1.BeatID,
"Period"=N'MTD',
"SalesValue" = IsNull((Select (Case When Sum(Amount) < 0 Then 0 Else Sum(Amount) End) From
	(Select Case ia.InvoiceType When 4 Then Sum(Amount) * -1 Else Sum(Amount) End as Amount
    From InvoiceAbstract ia(nolock), InvoiceDetail idtl(nolock) , Items its(nolock), --@CustBeat cb , 
	@AllItems tI
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3,4) And ia.CustomerID = cb1.CustID And		  
--          cb1.CustID = cb.CustID And
		  its.Product_code=tI.Items and 
--		  ia.BeatID = cb.BeatID And 
--          cb1.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Product_Code And 
          its.Product_Code not in (Select items From #tGR4Items) and 
		  ia.InvoiceDate Between @FromDate And @ToDate Group By ia.InvoiceType)A),0),
"NoOfBills" = IsNull((Select Count(*) From (
	Select Distinct ia.InvoiceID From InvoiceAbstract ia(nolock), InvoiceDetail idtl(nolock) , Items its(nolock) , --@CustBeat cb,
		@AllItems tI
	Where ia.InvoiceID = idtl.InvoiceID And isnull(ia.status,0) & 192 = 0 And
		  ia.InvoiceType in (1,3) And ia.CustomerID = cb1.CustID And
--          cb1.CustID = cb.CustID And 
		  its.Product_code=tI.Items and 
--		  ia.BeatID = cb.BeatID And 
--          cb1.BeatID = cb.BeatID And 
		  idtl.Product_Code = its.Product_Code And 
		  its.Product_Code not in (Select items From #tGR4Items) and 
		  ia.InvoiceDate Between @FromDate And @ToDate  
	) Als ), 0)
From @CustBeat cb1

-- Sales Value and No Of Bills update
Update tCS Set tCS.SalesValue=Round(tCBS.SalesValue,0), tCS.NoOfBills = Round(tCBS.NoOfBills,0)
From #tempCustSales tCS, 
(Select Period, BeatID, CustomerID, Sum(SalesValue) SalesValue, Sum(NoOfBills) NoOfBills From #CustBeatWiseSalesVal Group By Period, BeatID, CustomerID) tCBS
Where tCS.CustomerID = tCBS.CustomerID And tCS.Period = tCBS.Period And tCS.BeatID = tCBS.BeatID

select Count(*) 'RowCount' from #tempCustSales
select * from #tempCustSales Order BY CustomerName, BeatName, Period 
Select * from #CatConvTotal
EndRun:
Drop table #tItems
Drop table #CustBeatWiseConversion
Drop table #tempCustSales
Drop table #CatConvTotal
Drop table #CustBeatWiseSalesVal

