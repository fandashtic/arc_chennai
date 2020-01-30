--select * from ReportData Where Node in('Outstanding - Customer wise', 'Outstanding Ledger By Customer wise')
Update ReportData Set Parent = 151, Node = 'Outstanding Ledger By Customer wise' Where (Id = 141 OR Node = 'Outstanding - Customer wise')
GO
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'spr_list_Customer_OutStanding')
BEGIN
	DROP PROC spr_list_Customer_OutStanding
END
GO
Create procedure spr_list_Customer_OutStanding( @Customer nvarchar(2550),  @FromDate datetime, @ToDate datetime)                    
As     
BEGIN
	Declare @Delimeter as Char(1)                      
	Set @Delimeter=Char(15)                      
  
	Declare @One As Datetime                    
	Declare @Seven As Datetime                    
	Declare @Eight As Datetime                    
	Declare @Ten As Datetime                    
	Declare @Eleven As Datetime                    
	Declare @Fourteen As Datetime                    
	Declare @Fifteen As Datetime                    
	Declare @TwentyOne As Datetime                    
	Declare @TwentyTwo As Datetime                    
	Declare @Thirty As Datetime                    
	Declare @ThirtyOne As Datetime                    
	Declare @Sixty As Datetime                    
	Declare @SixtyOne As Datetime                    
	Declare @Ninety As Datetime                    
	Declare @NinetyOne as Datetime                    
	Declare @OneTwenty as datetime                    
	Declare @TOBEDEFINED nVarchar(50)  
  
	Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)  
                  
  
	Declare @DocID int                  
	Declare @DocType int                     
	Declare @CustID varchar(255), @ChqStatus Int  
                  
	Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + '/' +                    
	Cast(Datepart(mm, GetDate()) As nvarchar) + '/' +                    
	Cast(Datepart(yyyy, GetDate()) As nvarchar)                    
	Set @Seven = DateAdd(d, -7, @One)                    
	Set @Eight = DateAdd(d, -1, @Seven)                    
	Set @Ten = DateAdd(d, -2, @Eight)                    
	Set @Eleven = DateAdd(d, -1, @Ten)                    
	Set @Fourteen = DateAdd(d, -3, @Eleven)                    
	Set @Fifteen = DateAdd(d, -1, @Fourteen)                    
	Set @TwentyOne = DateAdd(d, -6, @Fifteen)                    
	Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)                    
	Set @Thirty = DateAdd(d, -8, @TwentyTwo)                    
	Set @ThirtyOne = DateAdd(d, -1, @Thirty)                    
	Set @Sixty = DateAdd(d, -29, @ThirtyOne)                    
	Set @SixtyOne = DateAdd(d, -1, @Sixty)                    
	Set @Ninety = DateAdd(d, -29, @SixtyOne)                    
	Set @NinetyOne = DateAdd(d, -1, @Ninety)                    
	Set @OneTwenty = DateAdd(d, -29, @NinetyOne)                    
                    
	Set @One = dbo.MakeDayEnd(@One)                    
	Set @Eight = dbo.MakeDayEnd(@Eight)                    
	Set @Eleven = dbo.MakeDayEnd(@Eleven)                    
	Set @Fifteen = dbo.MakeDayEnd(@Fifteen)                    
	Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)                    
	Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)                    
	Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)                    
	Set @NinetyOne= dbo.MakeDayEnd(@NinetyOne)                    
                    
	create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                    
	if @Customer='%'                    
	   insert into #tmpCust select customerid from customer                    
	else                    
	   insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)                    
                    
	create table #temp                    
	(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,                  
	DocumentID int null,                  
	Documenttype int null,                      
	NoteCount int null,                      
	Value Decimal(18,6) null,                    
	OnetoSeven Decimal(18,6) null,                    
	EighttoTen Decimal(18,6) null,                    
	EleventoFourteen Decimal(18,6) null,                    
	FifteentoTwentyOne Decimal(18,6) null,                    
	TwentyTwotoThirty Decimal(18,6) null,                    
	LessthanThirty Decimal(18,6) null,                    
	ThirtyOnetoSixty Decimal(18,6) null,                    
	SixtyOnetoNinety Decimal(18,6) null,                    
	NinetyonetoOneTwenty Decimal(18,6) null,                    
	MorethanOneTwenty Decimal(18,6) null,                    
	NotOverDue Decimal(18,6)                    
	)                    
                    
	insert #temp(CustomerID, DocumentID,Documenttype,NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,                    
	FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,                     
	SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)                    
	select InvoiceAbstract.CustomerID,InvoiceID,              
	(Case InvoiceAbstract.InvoiceType When 4 then              
	1 When 5 then 1 When 2 then 6 Else 4 End), count(InvoiceID),              
	Sum(Case InvoiceAbstract.InvoiceType When 4 then 0-Isnull(InvoiceAbstract.Balance,0)                   
	When 5 then 0-Isnull(InvoiceAbstract.Balance,0) When 6 then 0-Isnull(InvoiceAbstract.Balance,0)                  
	Else IsNull(InvoiceAbstract.Balance,0) End),              
  
	Sum(IsNull(Case When InvoiceDate Between @Seven And @One Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate Between @Ten And @Eight  Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate Between @Fourteen And @Eleven Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate Between @TwentyOne And @Fifteen Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate Between @Thirty And @TwentyTwo Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate > @Thirty Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate Between @Sixty And @ThirtyOne Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate Between @Ninety And @SixtyOne Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate Between @OneTwenty And @NinetyOne Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When InvoiceDate < @OneTwenty Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0)),  
  
	Sum(IsNull(Case When PaymentDate  >=@ToDate Then   
	(Case InvoiceType When 4 then 0-Isnull(Balance,0)                   
	When 5 then 0-Isnull(Balance,0) When 6 then 0-Isnull(Balance,0)                  
	Else IsNull(Balance,0) End) End, 0))  
  
	from InvoiceAbstract                    
	where Invoiceabstract.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and                    
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and                      
	InvoiceAbstract.Balance >= 0 and                       
	InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5,  6) and                      
	InvoiceAbstract.Status & 128 = 0                      
	group by InvoiceAbstract.CustomerID,InvoiceID,InvoiceType                      
                    
	insert #temp(CustomerID,DocumentID,Documenttype, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,                    
	FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,                     
	SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)                    
	select Creditnote.CustomerID, CreditID,2,count(CreditID), 0 - sum(Creditnote.Balance),   
  
	Sum(IsNull(Case When DocumentDate Between @Seven And @One Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Ten And @Eight Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Fourteen And @Eleven Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @TwentyOne And @Fifteen Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Thirty And @TwentyTwo Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate  > @Thirty Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Sixty And @ThirtyOne Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Ninety And @SixtyOne Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @OneTwenty And @NinetyOne Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate < @OneTwenty Then 0 - IsNull(Balance, 0) End, 0)),  
  
	0 - sum(IsNull(Balance, 0))  
                   
	from Creditnote                    
	where Creditnote.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and                    
	Creditnote.DocumentDate between @FromDate and @ToDate and                      
	Creditnote.Balance > 0                     
	group by Creditnote.CustomerID,CreditID                      
                    
  
	insert #temp(CustomerID,DocumentID,DocumentType,NoteCount,Value, OnetoSeven, EighttoTen, EleventoFourteen,                    
	FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,                     
	SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)                    
	select Debitnote.CustomerID,DebitID,5, count(DebitId), sum(Debitnote.Balance),                    
  
	Sum(IsNull(Case When DocumentDate Between @Seven And @One Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Ten And @Eight Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Fourteen And @Eleven Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @TwentyOne And @Fifteen Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Thirty And @TwentyTwo Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate  > @Thirty Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Sixty And @ThirtyOne Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Ninety And @SixtyOne Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @OneTwenty And @NinetyOne Then IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate < @OneTwenty Then IsNull(Balance, 0) End, 0)),  
  
	sum(IsNull(Balance, 0))     
  
  
	from debitnote                    
	where Debitnote.Customerid in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) and                    
	Debitnote.DocumentDate between @FromDate and @ToDate and                      
	Debitnote.Balance >= 0   And                  
	isnull(DebitNote.Flag,0) <> 2              
	group by Debitnote.CustomerID,DebitID,isnull(Flag,0)              
      
  
	insert #temp(CustomerID,DocumentID,DocumentType, NoteCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,                    
	FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,                     
	SixtyOnetoNinety,NinetyonetoOneTwenty,MorethanOneTwenty,NotOverDue)                    
	Select Collections.CustomerID,DocumentID,3, Count(DocumentID), 0 - Sum(Collections.Balance),    
  
	Sum(IsNull(Case When DocumentDate Between @Seven And @One Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Ten And @Eight Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Fourteen And @Eleven Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @TwentyOne And @Fifteen Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Thirty And @TwentyTwo Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate > @Thirty Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Sixty And @ThirtyOne Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @Ninety And @SixtyOne Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate Between @OneTwenty And @NinetyOne Then 0 - IsNull(Balance, 0) End, 0)),  
  
	Sum(IsNull(Case When DocumentDate < @OneTwenty Then 0 - IsNull(Balance, 0) End, 0)),  
  
	0 - Sum(IsNull(Collections.Balance, 0))    
                  
	From Collections                    
	Where Collections.CustomerID in(select customerid COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust) And                    
	Collections.DocumentDate Between @FromDate And @ToDate And                    
	Collections.Balance > 0 And                    
	IsNull(Collections.Status, 0) & 128 = 0                    
	Group By Collections.CustomerID,Collections.DocumentID                    
  
	-- For Updating Outstanding Balance                  
	Declare GetDocs Cursor For               
	Select DocumentID,DocumentType,CustomerID   
	from #temp Where   
	 DocumentID In (Select T.DocumentID From   
	CollectionDetail CD, Collections C,#temp T                   
	   Where T.DocumentID = CD.DocumentID And      
	   Isnull(C.paymentmode,0)=1 And              
	   C.DocumentID = CD.CollectionID And                  
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) NOT in (1)                 
	And  (T.DocumentType = 4 Or  T.DocumentType = 5))  
                
	Open GetDocs                  
	Fetch From GetDocs into @DocID,@DocType,@custID                  
	While @@fetch_status = 0                  
	BEGIN                  
  
	 Select @ChqStatus = Max(IsNull(CCD.ChqStatus, 0)) From Collections C, ChequeCollDetails CCD  
	 Where C.CustomerID=@CustID and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and         
	 C.DocumentDate between @fromdate and @todate And        
	 isnull(realised,0) not in(1)  And C.DocumentID not in(Select isnull(Representid,0) from ChequeCollDetails) and  
	 C.DocumentID = CCD.CollectionID and CCD.DocumentType In (4,5)  
  
	   Update #temp Set OnetoSeven = Isnull(OneToSeven, 0) +               
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate Between @Seven And @One And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And         
	   T.DocumentID = CD.DocumentID And      
	   CD.Documenttype = @Doctype AND                            
	   Isnull(C.paymentmode,0)=1 And              
	   C.DocumentID = CD.CollectionID And                  
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) NOT in (1))       
	   where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID             
                   
	   Update #temp Set EighttoTen = EighttoTen +      
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate between @eight and @ten And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   T.DocumentID = CD.DocumentID And         
	 CD.Documenttype = @Doctype AND                                      
	   Isnull(C.paymentmode,0)=1 And              
	   C.DocumentID = CD.CollectionID And                  
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )              
		  where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
                   
	   Update #temp Set EleventoFourteen = EighttoTen + --(Select isnull(Sum(EleventoFourteen),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate between @eleven and @fourteen And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   T.DocumentID = CD.DocumentID And               
	   CD.Documenttype = @Doctype AND                                
	   Isnull(C.paymentmode,0)=1 And              
	   C.DocumentID = CD.CollectionID And                  
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )              
		  where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
	   Update #temp Set FifteentoTwentyOne = FifteentoTwentyOne + --(Select isnull(Sum(FifteentoTwentyOne),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))  
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate between @fifteen and @twentyone And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   Isnull(C.paymentmode,0)=1 And              
	 CD.Documenttype = @Doctype AND                                
	   T.DocumentID = CD.DocumentID And                  
	   C.DocumentID = CD.CollectionID And                  
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )              
		  where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
	   Update #temp Set TwentyTwotoThirty = TwentyTwotoThirty + -- (Select isnull(Sum(TwentyTwotoThirty),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where  C.DocumentDate between @TwentyTwo and @Thirty And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   Isnull(C.paymentmode,0)=1 And              
	   T.DocumentID = CD.DocumentID And                  
	   CD.Documenttype = @Doctype AND                             
	   C.DocumentID = CD.CollectionID And                  
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )              
	   where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
	   Update #temp Set LessthanThirty = LessthanThirty +--(Select isnull(Sum(LessthanThirty),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate > @Thirty And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                
	   T.DocumentID = CD.DocumentID And                  
	   Isnull(C.paymentmode,0)=1 And              
	   C.DocumentID = CD.CollectionID And       
	   CD.Documenttype = @Doctype AND                                        
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )              
	   where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
	   Update #temp Set ThirtyOnetoSixty = ThirtyOnetoSixty + --(Select isnull(Sum(ThirtyOnetoSixty),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate Between @ThirtyOne and @Sixty And                   
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   T.DocumentID = CD.DocumentID And                  
	   Isnull(C.paymentmode,0)=1 And              
	   C.DocumentID = CD.CollectionID And         
	   CD.Documenttype = @Doctype AND                                      
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )              
	   where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
	   Update #temp Set SixtyOnetoNinety = SixtyOnetoNinety + --(Select isnull(Sum(SixtyOnetoNinety),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate Between @SixtyOne and @Ninety And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   Isnull(C.paymentmode,0)=1 And              
	   T.DocumentID = CD.DocumentID And                  
	   C.DocumentID = CD.CollectionID And           
	   CD.Documenttype = @Doctype AND                                    
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )      
	   where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
	   Update #temp Set NinetyonetoOneTwenty =  NinetyonetoOneTwenty + --(Select isnull(Sum(NinetyonetoOneTwenty),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate Between @NinetyOne and @OneTwenty And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   T.DocumentID = CD.DocumentID And                  
	   Isnull(C.paymentmode,0)=1 And              
	   C.DocumentID = CD.CollectionID And        
	   CD.Documenttype = @Doctype AND                                       
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1)) --+ (Select sum(Balance) from debitnote where isnull(status,0) & 192 = 0 and debitid in (Select debitID from ChequeCollDetails)  and isnull(balance,0) > 0 and CustomerID = @CustID )              
	   where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
                   
	   Update #temp Set MorethanOneTwenty = MorethanOneTwenty + --(Select isnull(Sum(MorethanOneTwenty),0) from #temp where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID) +                   
	   (Select IsNull((Case When @ChqStatus = 1 Then 0 When @ChqStatus = 0 or @ChqStatus = 3 or @ChqStatus = 4 or @ChqStatus = 5 Then Sum(isnull(CD.AdjustedAmount,0))-Sum(isnull(CD.DocAdjustAmount,0)) Else Sum(isnull(CD.AdjustedAmount,0)) End), 0)   
	--- (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID)))   
	 from CollectionDetail CD, Collections C,#temp T                   
	   Where C.DocumentDate < @OneTwenty And                  
	   T.DocumentID=@DocID And                  
	   T.CustomerID = @CustID And                  
	   T.DocumentType = @DocType And                  
	   Isnull(C.paymentmode,0)=1 And              
	   T.DocumentID = CD.DocumentID And            
	   CD.Documenttype = @Doctype AND                                   
	   C.DocumentID = CD.CollectionID And                  
	   isnull(C.Status,0) & 192 = 0 And                  
	   isnull(C.Realised,0) not in (1))where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID                  
  
	 Fetch Next From GetDocs into @DocID,@DocType,@CustID                  
	END                  
	Close GetDocs                  
	Deallocate GetDocs       
                 
	-- Channel type name changed, and new channel classifications added  
  
	CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,   
	[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,   
	[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)    
  
	Insert Into #OLClassMapping   
	Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc,   
	olc.SubOutlet_Type_Desc   
	From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm  
	Where olc.ID = olcm.OLClassID And  
	olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And   
	olcm.Active = 1   
    
      
	select  #temp.CustomerID, "CustomerID" = #temp.CustomerID,                     
	"Forum Code"=(Select AlternateCode from Customer where CustomerId=#temp.CustomerID),                    
	"Beat Name"=dbo.fn_GetBeatDescForCus(#temp.CustomerID),                    
	"Customer Type"=(Select Customer_Channel.ChannelDesc                    
	   From Customer,Customer_Channel                    
	   Where Customer.ChannelType=Customer_Channel.ChannelType                    
	   and Customer.Customerid=#temp.CustomerID),                    
  
	"Channel Type" = Case IsNull(olcm.[Channel Type], '')   
		 When '' Then   
		 @TOBEDEFINED  
		 Else   
		  olcm.[Channel Type]  
		 End,  
  
	"Outlet Type" = Case IsNull(olcm.[Outlet Type], '')   
		When '' Then   
		 @TOBEDEFINED  
		Else   
		 olcm.[Outlet Type]  
		End,  
  
	--"Loyalty Program" = Case IsNull(olcm.[Loyalty Program], '')   
	--        When '' Then   
	--      @TOBEDEFINED  
	--        Else   
	--      olcm.[Loyalty Program]   
	--        End,  
  
  
	--"Credit Term"=dbo.fn_GetCreditTermForCus(#temp.CustomerID),                    
	"Customer" = Customer.Company_Name, "No of Docs" = isnull(sum(Notecount),0),  
	"Not Over Due"=isnull(Sum(NotOverDue),0)+isnull(dbo.mERP_FN_get_CustomerBalance_NotOverdue_Rpt(#temp.CustomerID,@fromdate,@Todate,getdate()),0) ,                    
	"Over Due"= isnull((Select Sum(Case InvoiceType When 4 then 0-IsNull(Balance,0)                  
	When 5 then 0-IsNull(Balance,0) When 6 then 0-IsNull(Balance,0)                    
	Else IsNull(Balance,0) End) from InvoiceAbstract Where Invoicetype In (1, 2, 3, 4, 5, 6)                   
	And (Status & 128) =0 And CustomerId=#temp.CustomerId And PaymentDate < @ToDate                   
	And Invoicedate between @fromdate and @todate And Balance <> 0 ),0)+isnull(dbo.mERP_FN_get_CustomerBalance_Overdue_Rpt(#temp.CustomerID,@fromdate,@Todate,getdate()),0) ,                    
	"Outstanding Value (%c)" = Sum(Value) + isnull(dbo.mERP_FN_get_CustomerBalance_Rpt(#temp.CustomerID,@fromdate,@Todate),0),                   
	"Cheque on Hand (%c)" =  dbo.mERP_FN_get_ChequeDetails_Rpt(#temp.CustomerID,@fromdate,@Todate),      
	"1-7 Days" = Sum(OnetoSeven),                    
	"8-10 Days" = Sum(EighttoTen),                    
	"11-14 Days" = Sum(EleventoFourteen),                    
	"15-21 Days" = Sum(FifteentoTwentyOne),                    
	"22-30 Days" = Sum(TwentyTwotoThirty),                    
	"<30 Days" = Sum(LessthanThirty),                    
	"31-60 Days" = Sum(ThirtyOnetoSixty),                    
	"61-90 Days" = Sum(SixtyOnetoNinety),                    
	"91-120 Days" = Sum(NinetyonetoOneTwenty),                    
	">120 Days" = Sum(MorethanOneTwenty)                 
	From #temp  
	Inner Join Customer On #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID  
	Left Outer Join #OLClassMapping olcm On Customer.CustomerID= olcm.CustomerID  
	where #temp.DocumentType Not In (3)  
	group by #temp.CustomerID, Customer.Company_Name, olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program]  
  
	Having Sum(value) > 0                      
                    
	drop table #temp                    
	drop table #tmpCust       
	drop table #OLClassMapping
END
GO
  