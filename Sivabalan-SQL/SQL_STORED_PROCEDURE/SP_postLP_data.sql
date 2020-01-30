Create Procedure SP_postLP_data(@Todate datetime=NULL)  
AS
BEGIN
	/* This SP will post data in LPCustomerScore table */  
	SET Dateformat DMY  
	/* If invoked from LPDatapost.exe,we have to update the active status in LPLog table, so we are doing the below value assignment*/
	Declare @tmptodate datetime
	Declare @Productscope as nvarchar(4000)   
	Declare @ProductCode as nvarchar(4000)  
	Declare @Level int  
	Declare @FromDate datetime 
	Declare @Achievetodate datetime
	Declare @TargetToDate datetime

	Declare @CusID nvarchar(4000)
	Declare @Period nvarchar(2000)	
	Declare @Program_type nvarchar(4000)
	Declare @FromDate_DP Datetime
	Declare @ToDate_DP Datetime
	 
	set @tmptodate = @Todate
	--If invoked  from LPDatapost exe  
	if @Todate is null  
	BEGIN
		Select @FromDate= min(isnull(fromdate,getdate())) from LPLog where isnull(Active,0) = 1 
		Select @Todate = max(isnull(Todate,getdate())) from LPLog where isnull(Active,0) = 1 
	END
	--If invoked from Day end process
	ELSE	
	BEGIN
		set @FromDate= @Todate
	END 

	/* For Invoice */   
	Create Table #Invoice(InvoiceID int,InvoiceDate datetime, CustomerID nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS, Product_code nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS, NetValue decimal(18,6),ProductScope nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS) 
	/* For getting Product Scope*/  
	Create Table #LPData(Period nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductScope nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS, ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,[Level] int,Program_type nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	/* To get Leaf Level Product*/  
	Create Table #LPItemData(ProductScope nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_type nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #Item (ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS) 
	/* To get Combined LP Data*/  
	Create Table #CombinedLPData (Period nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductScope nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_type nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	/* To get Final LP Data*/   
	Create Table #FinalLPData (Period nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductScope nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductCode nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_type nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #tmpAch(Period nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,AchievedTo datetime,TargetTo datetime,Program_type nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #InvAbstract(InvoiceID int,InvoiceDate Datetime,CustomerID nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceType int)
	Create Table #InvDetail (InvoiceID int,Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Amount Decimal (18,6))

	Declare @PSWiseVal Table(Period nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductScope nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,Val decimal(18,6),CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,InvDate datetime)

	Insert into #tmpAch(Period,CustomerID,AchievedTo,TargetTo,Program_type)
	Select Distinct Period,CustomerID,AchievedTo,TargetTo,Program_type  From LP_AchievementDetail where isnull(active,0)=1 
	And @Todate between AchievedTo and TargetTo And
	AchievedTo is not null and TargetTo is not null


	Insert into #InvAbstract (InvoiceID,InvoiceDate,CustomerID,InvoiceType)
	Select InvoiceID,InvoiceDate,CustomerID,InvoiceType From InvoiceAbstract where Cast((Convert(Nvarchar(10),invoicedate,103)) as DateTime) between @FromDate and @ToDate And Isnull(status,0) & 128 = 0 
	Insert into #InvDetail (InvoiceID,Product_code,Amount)
	Select InvoiceID,Product_code,Amount From InvoiceDetail Where Invoiceid In (select InvoiceID from #InvAbstract)
	If Exists (select top 1 InvoiceID from #InvAbstract) --If sales data exist
	Begin
	Declare AllCus Cursor For Select Period,CustomerID,AchievedTo,TargetTo,Program_type  From #tmpAch
	Open AllCus 
	Fetch from AllCus into @Period,@CusID,@Achievetodate,@TargetToDate,@Program_type
	While @@Fetch_status=0
	BEGIN
		Set @FromDate_DP = @FromDate
		Set @ToDate_DP = @ToDate
		Truncate Table #LPData
		Truncate Table #LPItemData
		Truncate Table #CombinedLPData
		Truncate Table #FinalLPData
		Truncate Table #Invoice
		Delete from @PSWiseVal
		--Select top 1 @Achievetodate= AchievedTo+1 from LP_AchievementDetail where isnull(active,0)=1
		--Select top 1 @TargetToDate = TargetTo from LP_AchievementDetail where isnull(active,0)=1

		/* Grace days logic changed and implemented the new logic*/
		--				if @Achievetodate is not null and @TargetToDate is not null
		--				Begin
		--					if @Todate between @Achievetodate and @TargetToDate
		--					Begin

		insert into #LPData(Period,CustomerID,ProductScope,ProductCode,[level],Program_type)  
		Select distinct LA.Period,CustomerID,LI.ProductScope, LI.[ProductCode],LI.[ProductLevel],LA.Program_type 
		from LP_AchievementDetail LA(Nolock),LP_ItemCodeMap LI(Nolock)   
		where LA.Period=@Period And 
		LA.CustomerID=@CusID And 
		LA.Program_type=@Program_type And 
		isnull(LI.Active,0) = 1 And  
		isnull(LA.Active,0) = 1 And  
		LI.Period=LA.Period And  
		LI.ProductScope=LA.ProductScope AND
		LI.Program_type=LA.Program_type

		Declare AllProd cursor for select distinct ProductScope,ProductCode,[Level] from #LPData where [Level] <>5  
		open AllProd  
		fetch from AllProd into @ProductScope,@ProductCode,@Level  
		while @@fetch_status =0  
		BEGIN  
			insert into #LPItemData(ProductScope,ProductCode)  
			select @ProductScope,product_code from items where categoryid in (Select * From dbo.GetLeastLPCategories (@ProductCode,@Level))  
			fetch next from AllProd into @ProductScope,@ProductCode,@Level 
		END  
		close AllProd  
		Deallocate AllProd  

		insert into #CombinedLPData(ProductScope,ProductCode)   
		Select ProductScope,ProductCode from #LPData where [level]=5  
		union			     		
		Select Distinct LD.ProductScope,LD.ProductCode from #LPItemData LD 

		insert into #FinalLPData(ProductScope,ProductCode)   
		select distinct ProductScope,ProductCode from #CombinedLPData  

		/* For Invoice */   
		Insert into #Invoice (InvoiceID,InvoiceDate, CustomerID, Product_code, NetValue)   
		Select ID.InvoiceID,dbo.stripdatefromtime (invoicedate),IA.CustomerID,ID.Product_Code,Case when max(IA.InvoiceType)  in (1,3) then sum(ID.Amount) else sum(-1 * ID.Amount) end   
		from #InvAbstract IA(nolock),#InvDetail ID(nolock) Where 
		IA.InvoiceID = ID.InvoiceID
		and ID.Product_code in ( select distinct ProductCode from #FinalLPData )
		And IA.CustomerID=@CusID
		Group by dbo.stripdatefromtime (IA.invoicedate),IA.CustomerID,ID.Product_Code,ID.InvoiceID  

		update I set ProductScope = F.ProductScope from #FinalLPData F,#Invoice I
		Where F.Productcode=I.Product_Code

		insert into @PSWiseVal(ProductScope,Val,CustomerID,InvDate)
		Select I.ProductScope,sum(I.NetValue),I.CustomerID,I.InvoiceDate
		From #Invoice I 
		Group by I.ProductScope,I.CustomerID,I.InvoiceDate

		/*Data posting in LPCustomerScore */  
		While @FromDate_DP <= @ToDate_DP  
		BEGIN  
		  Delete from LPCustomerScore where Period=@Period and 
		  Dayclose=@FromDate_DP And
		  CustomerID=@CusID And
		  Program_type=@Program_type

		  insert into LPCustomerScore (Period,Dayclose,CustomerID,ProductScope,Achieved,Creationtime,Program_type)  
		  Select distinct L.Period,@FromDate_DP as DayClose,P.CustomerID,P.ProductScope,P.Val,getdate() as Creationtime,@Program_type  
		  from @PSWiseVal P,#LPData L
		  Where L.CustomerID=P.CustomerID	
		  and L.ProductScope=P.ProductScope
		  and P.InvDate=@FromDate_DP
		  And L.CustomerID=@CusID
		  And L.Program_type=@Program_Type

		  set @FromDate_DP = @FromDate_DP+1   
		END   

		/*update LPLog set ToDate=@Todate where Period in (select isnull(Period,'') from LP_AchievementDetail where isnull(Active,0) = 1)*/
		if @tmptodate is null 
			update LPLog set Active = 0 where isnull(Active,0) = 1 and Period =@Period And Program_type=@Program_type And CustomerID=@CUSID

		Fetch Next from AllCus into @Period,@CusID,@Achievetodate,@TargetToDate,@Program_type
	END
	Close AllCus
	Deallocate AllCus
	End
	Else --If no sales data while receiving LP
	Begin
		update LPLog set Active = 0 where isnull(active,0)=1 and isnull(customerid,'')<>''
	End
	Drop Table #tmpAch
	Drop Table #LPData
	Drop Table #LPItemData
	Drop Table #CombinedLPData
	Drop Table #FinalLPData
	Drop Table #Invoice
	Drop Table #InvAbstract
	Drop Table #InvDetail
END  
