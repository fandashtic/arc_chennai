Create Procedure mERP_spr_ListMarketAccompaniment_Supervisor(@Group nVarchar(100),@DS nVarchar(500),
@Beat nVarchar(500),
@FromDate datetime,
@ToDate datetime,@CurDate datetime,
@Supervisor int,@OCG nvarchar(3000) = NULL)
As
Begin
	Declare @DivName as nvarchar(100)
	set dateformat dmy

    Create table #TmpMarketAccompaniment(CustomerID nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
    CustomerName nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,PrevLinesCut decimal(18,6),PrevBillValue decimal(18,6),
    LinesCut decimal(18,6),BillValue decimal(18,6),PrevBillCount int,BillCount int,
	PBillValue decimal(18,6),PLinesCut int)
    
    Create table #TmpLast3week(CustomerID nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,LinesCut int,Billcount decimal(18,6),BillValue decimal(18,6))

    Create table #TmpCurDate(CustomerID nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,LinesCut int,BillCount decimal(18,6),BillValue decimal(18,6))     
	
	Create table #TmpItems(Product_Code nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create table #tempCategory(CategoryID int,Status int)
	Create table #TmpCatGroup(GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
	/* For NON OCG*/
	If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
	Begin
		If @Group='Common DS'
		   insert into #TmpCatGroup  select distinct Top 3 CategoryGroup from tblCGDivMapping order by CategoryGroup
		Else
		   insert into #TmpCatGroup  select @Group

		Declare Cur_Div Cursor for
		Select Division from tblCGDivMapping where CategoryGroup in (select GroupName from #TmpCatGroup)
		Open Cur_Div
		Fetch From Cur_Div Into @DivName
		While @@Fetch_Status = 0
		Begin
		   Exec dbo.GetLeafCategories '%',@DivName
		   Insert into #TmpItems
		   select Product_Code from Items where 
		   CategoryID in (select CategoryID from #tempCategory) 
		   Truncate table #tempCategory
		   Fetch From Cur_Div Into @DivName
		End
		Close Cur_Div
		Deallocate Cur_Div
	End
	Else
	Begin
		Create Table #TmpGroup (GroupId int)
		Declare @GroupID nvarchar(50)
		Insert into #TmpGroup (GroupId)
		Select GroupID from ProductCategoryGroupAbstract where GroupName in(
		Select * from dbo.sp_SplitIn2Rows(@OCG, ','))
		Declare AllGroup Cursor For select Distinct cast(GroupId as nvarchar(50)) from #TmpGroup
		Open AllGroup
		Fetch from AllGroup into @GroupID
		While @@fetch_status=0
		Begin
			insert into #TmpItems (Product_Code)	
			Select Product_code from Fn_GetOCGSKU(@GroupID)
			Fetch next from AllGroup into @GroupID	
		End
		Close AllGroup
		Deallocate AllGroup
	End
	/*Insert into #TmpMarketAccompaniment(CustomerID,CustomerName)
    Select distinct IA.CustomerID,	
    CS.Company_Name
	From InvoiceAbstract IA,  Customer CS
	Where dbo.striptimefromdate(IA.InvoiceDate) 
    Between dbo.striptimefromdate(@FromDate) and dbo.striptimefromdate(@CurDate)
    And (isNull(IA.Status,0) & 128 = 0 )	
	And CS.CustomerID = IA.CustomerID
	And IA.SalesmanID=@DS
	And IA.BeatID=@Beat
    And isnull(IA.Salesman2,0)=@Supervisor
    And (select count(*) from #TmpItems,InvoiceDetail ID where ID.InvoiceID=IA.InvoiceID 
    And #TmpItems.Product_Code=ID.Product_Code) > 0 */

    Insert into #TmpMarketAccompaniment(CustomerID,CustomerName)
    select Distinct C.CustomerID,C.Company_Name
    from Beat_Salesman B,Customer C
    where B.BeatID=@Beat and B.SalesmanID=@DS
    and C.CustomerID=B.CustomerID
    and C.Active=1
  
    Insert into #TmpLast3week(CustomerID,Billcount,LinesCut,BillValue)
    Select IA.CustomerID,case when IA.InvoiceID > 0 then 1 else 1 end,Count(Distinct ID.Product_Code),	
    Sum(Case IA.InvoiceType
	When 4 Then	0 - (ID.Amount)
	Else ID.Amount
	End)
	From InvoiceAbstract IA, InvoiceDetail ID, Customer CS,#TmpMarketAccompaniment Tmp
	Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@FromDate) 
    And dbo.striptimefromdate(@ToDate)  
	And (isNull(IA.Status,0) & 128 = 0 )
	And IA.InvoiceType In(1,3)
	And IA.InvoiceID = ID.InvoiceID
	And CS.CustomerID = IA.CustomerID
    And IA.CustomerID=Tmp.CustomerID
	/*And IA.SalesmanID=@DS
	And IA.BeatID=@Beat*/
    /*And isnull(IA.Salesman2,0)=@Supervisor*/
	And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems 
    where #TmpItems.Product_Code=ID.Product_Code)
    Group by IA.CustomerID,IA.InvoiceID

	Insert into #TmpLast3week(CustomerID,Billcount,LinesCut,BillValue)
    Select IA.CustomerID,case when IA.InvoiceID > 0 then 0 else 0 end,0,0-Sum(ID.Amount)
	From InvoiceAbstract IA, InvoiceDetail ID, Customer CS,#TmpMarketAccompaniment Tmp
	Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@FromDate) 
    And dbo.striptimefromdate(@ToDate)  
	And (isNull(IA.Status,0) & 128 = 0 )
	And IA.InvoiceType In(4)
	And IA.InvoiceID = ID.InvoiceID
	And CS.CustomerID = IA.CustomerID
	And IA.CustomerID=Tmp.CustomerID
	/*And IA.SalesmanID=@DS
	And IA.BeatID=@Beat*/
    /*And isnull(IA.Salesman2,0)=@Supervisor*/
	And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems 
    where #TmpItems.Product_Code=ID.Product_Code)
    Group by IA.CustomerID,IA.InvoiceID
	
	
	select CustomerID,cast(sum(Billcount) as decimal(18,6)) as BillCount,
    sum(LinesCut) as LinesCut,sum(BillValue) as BillValue 
    into  #TmpLast3week1
    from #TmpLast3week  group by #TmpLast3week.CustomerID    
    
    	
    Insert into #TmpCurDate(CustomerID,Billcount,LinesCut,BillValue)
    Select IA.CustomerID,case when IA.InvoiceID > 0 then 1 else 1 end,
    Count(Distinct ID.Product_Code),	
    Sum(Case IA.InvoiceType
	When 4 Then	0 - (ID.Amount)
	Else ID.Amount
	End)
	From InvoiceAbstract IA, InvoiceDetail ID, Customer CS
	Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@CurDate)
    And dbo.striptimefromdate(@CurDate)  
	And (isNull(IA.Status,0) & 128 = 0)
	And IA.InvoiceType In(1,3)
	And IA.InvoiceID = ID.InvoiceID
	And CS.CustomerID = IA.CustomerID
	And IA.SalesmanID=@DS
	And IA.BeatID=@Beat
    And isnull(IA.Salesman2,0)=@Supervisor
    And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems where #TmpItems.Product_Code=ID.Product_Code)
    Group by IA.CustomerID,IA.InvoiceID


	Insert into #TmpCurDate(CustomerID,Billcount,LinesCut,BillValue)
    Select IA.CustomerID,case when IA.InvoiceID > 0 then 0 else 0 end,0,0-Sum(ID.Amount)
	From InvoiceAbstract IA, InvoiceDetail ID, Customer CS
	Where dbo.striptimefromdate(IA.InvoiceDate) Between dbo.striptimefromdate(@CurDate)
    And dbo.striptimefromdate(@CurDate)  
	And (isNull(IA.Status,0) & 128 = 0)
	And IA.InvoiceType In(4)
	And IA.InvoiceID = ID.InvoiceID
	And CS.CustomerID = IA.CustomerID
	--And IA.SalesmanID=@DS
	And IA.BeatID=@Beat
    And isnull(IA.Salesman2,0)=@Supervisor
    And ID.Product_Code in (select #TmpItems.Product_Code from #TmpItems 
    where #TmpItems.Product_Code=ID.Product_Code)
    Group by IA.CustomerID,IA.InvoiceID	
 
	
	select #TmpCurDate.CustomerID,cast(sum(Billcount) as decimal(18,6)) as BillCount,
    sum(LinesCut) as LinesCut,sum(BillValue) as BillValue 
    into  #TmpCurDate1
    from #TmpCurDate  group by #TmpCurDate.CustomerID

	
    Update  #TmpMarketAccompaniment set PrevLinesCut=(select LinesCut/(case when isnull(BillCount,0)=0 then 1 else BillCount end) from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID), 
	PrevBillValue=(select BillValue/(case when isnull(BillCount,0)=0 then 1 else BillCount end) from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
    LinesCut=(select LinesCut from #TmpCurDate1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
    BillValue=(select BillValue from #TmpCurDate1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
    PrevBillCount=(select BillCount from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID), 
    BillCount=(select BillCount from #TmpCurDate1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
	PBillValue=(select BillValue from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID),
	PLinesCut=(select LinesCut from #TmpLast3week1 where CustomerID=#TmpMarketAccompaniment.CustomerID)


    
	--Dynamic Updation of Merchandising column  
	Declare @MerchandiseID As Int  
	Declare @Merchandise as nVarchar(500)  
	Declare @MerchandiseCol as nVarchar(2000)  
	Declare @YES as Nvarchar(10)  
	Declare @NO as Nvarchar(10) 
	Declare @SQL as nvarchar(500)	 
	Set  @YES = 'Yes'  
	Set @NO ='No'  
	Set @MerchandiseCol = ''  
	Declare CurMerChandise Cursor For  
	Select MerchandiseID,Merchandise From Merchandise order by MerchandiseID  
	
	Open CurMerChandise  
	Fetch From CurMerChandise Into @MerchandiseID,@Merchandise  
	While @@Fetch_Status = 0  
	Begin  
	  
	Set @SQL = 'Alter Table #TmpMarketAccompaniment Add[' + @Merchandise + ' ' + '] nVarchar(10)'  
	Exec sp_ExecuteSql @SQL  
	  
	Set @SQL = 'Update #TmpMarketAccompaniment Set[' + @Merchandise +  
	'] = isNull((Select Case MerchandiseID When ' + Cast(@MerchandiseID as nVarchar) + ' Then ' + '''' + @YES + '''' + '  
	Else' + '''' + @NO + '''' + ' End From CustMerchandise  
	Where CustomerID = #TmpMarketAccompaniment.CustomerID And MerchandiseID = ' + Cast(@MerchandiseID as nVarchar)  
	+' ),' + '''' + @No+ ''''  + ')'  
	Exec sp_ExecuteSql @SQL  
	  
	Set @MerchandiseCol  = @MerchandiseCol + ',[' + @Merchandise + ']'  
	  
	Fetch Next From CurMerChandise Into @MerchandiseID,@Merchandise  
	End  
	Close CurMerChandise  
	Deallocate CurMerChandise 

    select * from #TmpMarketAccompaniment order by CustomerName

    Truncate table #TmpMarketAccompaniment
    Truncate table #TmpCurDate
	Truncate table #TmpLast3week
	Truncate table #TmpCatGroup

    Drop Table #TmpMarketAccompaniment
    Drop Table #TmpCurDate
    Drop Table #TmpLast3week  
	Drop Table #TmpCurDate1 
    Drop table #TmpLast3week1
    Drop table #TmpItems
    Drop table #tempCategory 
    Drop table #TmpCatGroup

End
