CREATE PROCEDURE [dbo].[Spr_AgeOfOutstanding] (@ReportType Nvarchar(255),@SalesMan Nvarchar(255),@Beat Nvarchar(255),@Customerid Nvarchar(255),@Fromdate dateTime,@Todate dateTime)
As   
Begin
	Set DateFormat DMY
	Declare @Date as Nvarchar(255)
	Declare @Id as Int
	Declare @DateCount as Int
	Declare @Sql as Nvarchar(4000)
	Declare @Delimeter as Char(1)
	Set @Delimeter=Char(15)

	CREATE TABLE #TempCust(
		[salesmanid] Int,
		[Salesman] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Beatid] Int,
		[Beat] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Customerid] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CustomerName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	) 

	CREATE TABLE #Tempsalesman(	[Salesmanid] Int)
	CREATE TABLE #TempBeat(	[Beatid] Int)
	CREATE TABLE #TempDate(	[DateCol] DateTime)

	CREATE TABLE [dbo].[TempOutstanding](
		[From Date] [datetime] NULL,
		[To Date] [datetime] NULL,
		[Salesman] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Beat] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Customerid] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Customer Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[InvoiceID] [int] NOT NULL,
		[Documentid] [int] NULL,
		[Invoice Date] [datetime] NULL,
		[NetValue] [decimal](18, 6) NULL,
		[Balance] [decimal](18, 6) NULL,
		[Pending Days] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL )


	If @SalesMan <> '%'
		Begin
			Insert into #Tempsalesman Select Distinct salesmanid From Salesman Where Salesman_Name Like @SalesMan
		End
	Else
		Begin
			Insert into #Tempsalesman Select Distinct salesmanid From Salesman
		End

	If @Beat <> '%'
		Begin
			Insert into #TempBeat Select Distinct Beatid From Beat Where Description Like @Beat
		End
	Else
		Begin
			Insert into #TempBeat 
			Select Distinct Beatid From Beat 
			Where Beatid in (select Distinct Beatid From beat_salesman Where salesmanid in(select Distinct Salesmanid From #Tempsalesman))
		End

	If @Customerid <> '%'
		Begin
			Insert into #TempCust
			Select Distinct S.salesmanid,S.Salesman_Name,B.Beatid,B.Description,BS.Customerid,C.Company_Name 
			from Salesman S, Beat B, beat_salesman BS, Customer C
			Where S.salesmanid = BS.salesmanid
			And B.Beatid = BS.Beatid
			And C.Customerid = BS.Customerid
			And BS.SalesmanId in (Select Distinct Salesmanid From #Tempsalesman)
			And BS.BeatID in (Select Distinct Beatid From #TempBeat)
			And C.Customerid in (Select * from dbo.sp_SplitIn2Rows(@Customerid,@Delimeter)) 
		End
	Else
		Begin
			Insert into #TempCust
			Select Distinct S.salesmanid,S.Salesman_Name,B.Beatid,B.Description,BS.Customerid,C.Company_Name 
			from Salesman S, Beat B, beat_salesman BS, Customer C
			Where S.salesmanid = BS.salesmanid
			And B.Beatid = BS.Beatid
			And C.Customerid = BS.Customerid
			And BS.SalesmanId in (Select Distinct Salesmanid From #Tempsalesman)
			And BS.BeatID in (Select Distinct Beatid From #TempBeat)
		End

	If @ReportType = 'Summary'
		Begin
			select Distinct 1 Id,@Fromdate [From Date],@Todate [To Date],T.Salesman,T.Beat,IA.Customerid,C.Company_Name [Customer Name] ,IA.InvoiceID,IA.Documentid,dbo.stripdatefromtime(IA.Invoicedate) [Invoice Date],IA.NetValue,IA.Balance,
			Cast((Cast((DateDiff(Day,dbo.stripdatefromtime(IA.Invoicedate),@Todate)) as Nvarchar) + ' - Days Pending') as Nvarchar(255)) [Pending Days]
			from invoiceabstract IA, Customer C, #TempCust T
			Where IA.Customerid in (select Distinct Customerid From #TempCust)
			And dbo.stripdatefromtime(IA.Invoicedate) Between @Fromdate and @Todate 
			And IA.SalesmanId in (Select Distinct Salesmanid From #Tempsalesman)
			And IA.BeatID in (Select Distinct Beatid From #TempBeat)
			And IA.InvoiceType in (1,3)
			And (IA.Status & 128) = 0
			And IA.PaymentMode = 0
			And C.Customerid = IA.Customerid
			And T.SalesmanId = IA.SalesmanId
			And T.BeatID = IA.BeatID
		End
	Else If @ReportType = 'Detail'
		Begin
		-- Dynamic Column Updated Start.....
			Truncate Table #TempDate
			Insert into #TempDate Select Distinct dbo.stripdatefromtime(CA.DocumentDate) From Collections CA Where dbo.stripdatefromtime(CA.DocumentDate) Between @Fromdate and @Todate and CustomerID in (select Distinct Customerid From #TempCust)

			Set @Sql = ''

			Declare @DateCol as Nvarchar(255)
			Declare @clu Cursor 
			Set @clu = Cursor for
			select Distinct cast(Convert(Nvarchar(10),DateCol,103) as Nvarchar(10)) from #TempDate
			Open @clu
			Fetch Next from @clu into @DateCol
			While @@fetch_status =0
				Begin
					Set @Sql = ('Alter Table TempOutstanding  Add [' + Cast(@DateCol as Nvarchar(255))+'] Decimal(18,6)')
					Exec (@Sql)
					Fetch Next from @clu into @DateCol
				End
			Close @clu
			Deallocate @clu

		-- Dynamic Column Updated End.....

			INSERT INTO TempOutstanding([From Date],[To Date],[Salesman],[Beat],[Customerid],[Customer Name],[InvoiceID],[Documentid],[Invoice Date],[NetValue],[Balance],[Pending Days])
			select Distinct @Fromdate [From Date],@Todate [To Date],T.Salesman,T.Beat,IA.Customerid,C.Company_Name [Customer Name] ,IA.InvoiceID,IA.Documentid,dbo.stripdatefromtime(IA.Invoicedate) [Invoice Date],IA.NetValue,IA.Balance,
			Cast((Cast((DateDiff(Day,dbo.stripdatefromtime(IA.Invoicedate),@Todate)) as Nvarchar) + ' - Days Pending') as Nvarchar(255)) [Pending Days]
			from invoiceabstract IA, Customer C, #TempCust T
			Where IA.Customerid in (select Distinct Customerid From #TempCust)
			And dbo.stripdatefromtime(IA.Invoicedate) Between @Fromdate and @Todate 
			And IA.SalesmanId in (Select Distinct Salesmanid From #Tempsalesman)
			And IA.BeatID in (Select Distinct Beatid From #TempBeat)
			And IA.InvoiceType in (1,3)
			And (IA.Status & 128) = 0
			And IA.PaymentMode = 0
			And C.Customerid = IA.Customerid
			And T.SalesmanId = IA.SalesmanId
			And T.BeatID = IA.BeatID

-- Dynamic data Update Start...

			Declare @cur Cursor 
			Set @cur = Cursor for
			select Distinct cast(Convert(Nvarchar(10),DateCol,103) as Nvarchar(10)) from #TempDate
			Open @cur
			Fetch Next from @cur into @DateCol
			While @@fetch_status =0
				Begin
					Set @Sql = 'Set dateFormat DMY '
					Set @Sql = @Sql +'Update T set T.[' + @DateCol + '] = T1.Amount From TempOutstanding T,'
					Set @Sql = @Sql + '(select CD.OriginalId,Sum(CD.AdjustedAmount) Amount from Collections CA, CollectionDetail CD ' 
					Set @Sql = @Sql + 'Where dbo.stripdatefromtime(CA.DocumentDate) = ''' + @DateCol + ''' '
					Set @Sql = @Sql + 'And CD.DocumentType IN (4,5,6) '
					Set @Sql = @Sql + 'And CA.DocumentID = CD.CollectionID And Isnull(Status,0) <> 192 '
					Set @Sql = @Sql + 'Group By CD.OriginalId) T1 Where Cast((''I'' + cast(T.DocumentID as Nvarchar(255))) as Nvarchar(255)) = Cast(T1.OriginalId as Nvarchar(255)) '
					Print @Sql
					Exec (@Sql)
					Set @Sql = ''
					Fetch Next from @cur into @DateCol
				End
			Close @cur
			Deallocate @cur

-- Dynamic data Update End...

			Update TempOutstanding Set [Pending Days] = '' Where Isnull(Balance,0) = 0

			select 1,* from TempOutstanding Order By 4,5,6,7,9

		End
	Drop table #TempCust
	Drop table #Tempsalesman
	Drop table #TempBeat
	Drop table #TempDate
	Drop table TempOutstanding

End
