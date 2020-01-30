Create Proc sp_TrackUser( 
@Type Nvarchar(50),
@FromDate DateTime,    
@ToDate DateTime,
@UserName NVarChar(4000)
)
AS
Begin
Declare @Delimeter as Char(1)  
DECLARE @INV AS NVARCHAR(50) 
Declare @GRNPrefix nvarchar(50)
Declare @Disp As Nvarchar(50)
Set Dateformat DMY
set @FromDate=dbo.StripDateFromTime(@FromDate)
set @ToDate=dbo.StripDateFromTime(@ToDate)
set @Delimeter =  Char(15) 
Declare @VanPrefix nvarchar(50)
Declare @QuotationPrefix nvarchar(50)
Declare @BillPrefix nvarchar(50)
Declare @PRPrefix nvarchar(50)

Select @GRNPrefix = isnull(Prefix,'') from VoucherPrefix Where TranID = 'GOODS RECEIVED NOTE'


Create Table #Users (UserName  nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE' 
SELECT @Disp = Prefix FROM VoucherPrefix WHERE TranID = N'DISPATCH' 



		create Table #tmpTransaction(ID int identity(1,1),FromDate Datetime,ToDate Datetime,UserID nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,CreationTime Datetime,
		TransactionType nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,TransactionDate Datetime,TransactionDocID nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
		TransactionID int,DocType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

if @UserName = '%'
	Insert into #Users Select UserName From [Users]
else
	Insert into #Users Select * From dbo.sp_SplitIn2Rows(@UserName, @Delimeter)  

IF @Type = '%' Or @Type = 'Creation Date'
Begin 
		Select * into #InvoiceAbstract From InvoiceAbstract   where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)

		/* For Invoice */

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		select @FromDate,@ToDate, UserName,CreationTime,TransactionType,InvoiceDate,
		--Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END     
		Cast(Documentid as Nvarchar) as Documentid,InvoiceID,DocType from (

		select UserName,CreationTime, (Case When (isnull(Status,0) & 128) <> 0 Then 'Amended Invoice' Else
		'Invoice' End) TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,
		InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract Where dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate and  InvoiceType = 1  And isnull(Status,0) & 192 <> 192 
		And (UserName in (select UserName from #Users)) --INvoice,Amended Invoice

		Union 

		select UserName,CreationTime, 'Invoice' TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract Where dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate and  InvoiceType = 1  And isnull(Status,0) & 192 = 192 And (UserName in (select UserName from #Users)) -- Invoice Before Cancel

		Union

		select UserName,CreationTime,(Case When (isnull(Status,0) & 128) <> 0 Then (Case When ((isnull(Status,0) & 192) = 192) Then 'Invoice Amendment' Else  'Amended Invoice'  end )Else
		'Invoice Amendment' End) as TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract  Where  dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate and  InvoiceType = 3 And (UserName in (select UserName from #Users)) -- Invoice Amendment

		Union

		select CancelUser as UserName,CancelDate as CreationTime, 'Cancel Invoice'  TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract Where dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate and   InvoiceType In (1,3)  And isnull(Status,0) & 192 = 192
		And (IsNull(CancelUser,'') in (select UserName from #Users)) --Cancel Invoice

		Union

		select UserName,CreationTime as CreationTime, (Case When (isnull(Status,0) & 32) <> 0 Then 'Sales Return Damages' Else
		'Sales Return Saleable' End) as TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,
		InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract Where  dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate and  InvoiceType In (4,5)  
		And (IsNull(UserName,'') in (select UserName from #Users)) --Sales Return Invoice
		) As   A  ORder by 5,6,2


		/* Temp Tables to store the data from Main Table to improve the performance */
		/* Start */
		Select * into #StockTransferInAbstract From StockTransferInAbstract where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate or dbo.StripDateFromTime(CancellationDate) between @FromDate and @ToDate)
		Select * into #StockTransferOutAbstract From StockTransferOutAbstract where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate or dbo.StripDateFromTime(CancellationDate) between @FromDate and @ToDate)
		Select * into #SOAbstract From SOAbstract  where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)
		Select * into #Collections From Collections  where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)
		Select * into #CreditNote From CreditNote  where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(Cancelled_Date) between @FromDate and @ToDate)
		Select * into #DebitNote From DebitNote  where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(Cancelled_Date) between @FromDate and @ToDate)
		Select * into #Payments From Payments  where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)
		Select * into #InvoiceWiseCollectionAbstract From InvoiceWiseCollectionAbstract  where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)
		/* End */

		--STI
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STI - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STI - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STI - Amendment' --Amendment
		else 'STI' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract SA where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) =0 
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STI - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STI - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STI - Amendment' --Amendment
		else 'STI' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract SA where  (dbo.StripDateFromTime(CancellationDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0 
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial

		Delete From #tmpTransaction Where DocType='STI' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STI - Amendment',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract SA where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate)
		And ISNULL(Reference,0)<>0 And  (isnull(Status,0) & 64) <>0 
		And (UserName in (select UserName from #Users))
		Order by DocSerial

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STI',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract SA where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate)
		And (UserName in (select UserName from #Users))
		And ISNULL(Reference,0)=0 And  (isnull(Status,0) & 64) <>0 
		And DocSerial in (Select TransactionID from #tmpTransaction where DocType='STI')
		Order by DocSerial


		--STO
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STO - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STO - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STO - Amendment' --Amendment
		else 'ST0' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract SA where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) =0
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STO - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STO - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STO - Amendment' --Amendment
		else 'ST0' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract SA where  (dbo.StripDateFromTime(CancellationDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial
		Delete From #tmpTransaction Where DocType='STO' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STO - Amendment',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract SA where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate)
		And ISNULL(Reference,'')<>'' And  (isnull(Status,0) & 64) <>0 
		And (UserName in (select UserName from #Users))
		Order by DocSerial

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STO',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract SA where  (dbo.StripDateFromTime(creationDate) between @FromDate and @ToDate)
		And (UserName in (select UserName from #Users))
		And ISNULL(Reference,'')<>'' And  (isnull(Status,0) & 64) <>0 
		And DocSerial in (Select TransactionID from #tmpTransaction where DocType='STO')
		Order by DocSerial


		--Sales Order
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then UserName --Amended
		when isnull(SORef,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then CreationTime --Amended
		when isnull(SORef,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 192) =192 Then 'SO - Cancelled' --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then 'SO - Amended' --Amended
		when isnull(SORef,0) <>0 Then 'SO - Amendment' --Amendment
		else 'SO' --Open 
		end
		,SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract  SA,VoucherPrefix where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate )
		And VoucherPrefix.TranID = 'SALE CONFIRMATION' 
		and (isnull(Status,0) & 192) <>192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by SONumber


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then UserName --Amended
		when isnull(SORef,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then CreationTime --Amended
		when isnull(SORef,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'SO - Cancelled' --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then 'SO - Amended' --Amended
		when isnull(SORef,0) <>0 Then 'SO - Amendment' --Amendment
		else 'SO' --Open 
		end
		,SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract  SA,VoucherPrefix where  (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)
		And VoucherPrefix.TranID = 'SALE CONFIRMATION' and (isnull(Status,0) & 192) =192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by SONumber

		Delete From #tmpTransaction Where DocType='SO' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'SO - Amendment',SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract SA,VoucherPrefix where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And VoucherPrefix.TranID = 'SALE CONFIRMATION'
		And ISNULL(SORef,0)<>0 And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		Order by SONumber

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'SO',SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract SA,VoucherPrefix where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And VoucherPrefix.TranID = 'SALE CONFIRMATION'
		And (UserName in (select UserName from #Users))
		And ISNULL(SORef,0)=0 And  (isnull(Status,0) & 192) =192
		Order by SONumber

		--Collections
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(OriginalRef,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(OriginalRef,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'Collection - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Collection - Amended' --Amended
		when isnull(OriginalRef,'') <>'' Then 'Collection - Amendment' --Amendment
		else 'Collection' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections  SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate) and (isnull(Status,0) & 192) <>192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by DocumentID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(OriginalRef,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(OriginalRef,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'Collection - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Collection - Amended' --Amended
		when isnull(OriginalRef,'') <>'' Then 'Collection - Amendment' --Amendment
		else 'Collection' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections  SA where  (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate) and (isnull(Status,0) & 192) =192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by DocumentID


		Delete From #tmpTransaction Where DocType='Collection' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Collection - Amendment',DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(OriginalRef,'') <>'' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		Order by DocumentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Collection',DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(OriginalRef,'') ='' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		And DocumentID in (Select TransactionID from #tmpTransaction where DocType='Collection')
		Order by DocumentID

		--CreditNote
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'Credit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Credit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Credit Note - Amendment' --Amendment
		else 'Credit Note' --Open 
		end
		,DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote  SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)  and  (isnull(Status,0) & 64) =0 
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by CreditID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'Credit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Credit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Credit Note - Amendment' --Amendment
		else 'Credit Note' --Open 
		end
		,DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote  SA where  (dbo.StripDateFromTime(Cancelled_Date) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0 
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by CreditID

		Delete From #tmpTransaction Where DocType='Credit Note' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Credit Note - Amendment',DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(RefDocid,0) <>0 And  (isnull(Status,0) & 64)<>0
		And (UserName in (select UserName from #Users))
		Order by CreditID
		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Credit Note',DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(RefDocid,0) =0 And  (isnull(Status,0) & 64) <>0
		And (UserName in (select UserName from #Users))
		And CreditID in (Select TransactionID from #tmpTransaction where DocType='Credit Note')
		Order by DocumentID

		--DebitNote
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 64) <>0 Then 'Debit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Debit Note - Amended' --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then 'Debit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Debit Note - Amendment' --Amendment
		else 'Debit Note' --Open 
		end
		,DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote  SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate ) and (isnull(Status,0) & 64) = 0
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by DebitID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'Debit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Debit Note - Amended' --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then 'Debit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Debit Note - Amendment' --Amendment
		else 'Debit Note' --Open 
		end
		,DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote  SA where  (dbo.StripDateFromTime(Cancelled_Date) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by DebitID

		Delete From #tmpTransaction Where DocType='Debit Note' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Debit Note - Amendment',DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(RefDocid,0) <>0 And  (isnull(Status,0) & 64)<>0
		And (UserName in (select UserName from #Users))
		Order by DebitID
		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Debit Note',DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(RefDocid,0) =0 And  (isnull(Status,0) & 64) <>0
		And (UserName in (select UserName from #Users))
		And DebitID in (Select TransactionID from #tmpTransaction where DocType='Debit Note')
		Order by DebitID



		Select * Into #GRNAbstract From GRNAbstract Where (dbo.StripDateFromTime(CreationTime) 
			Between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)

		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When (isnull(GRNStatus,0) & 32) <> 0 Then UserName 
			--When (isnull(GRNStatus,0) & 64) <> 0 Then CancelUser	
			When (isnull(GRNStatus,0) & 16) <> 0 Then UserName
			Else  UserName End,
		Case When (isnull(GRNStatus,0) & 32) <> 0 Then CreationTime 
			--When (isnull(GRNStatus,0) & 64) <> 0 Then CancelDate	
			When (isnull(GRNStatus,0) & 16) <> 0 Then CreationTime
			Else  CreationTime End,
		Case When (isnull(GRNStatus,0) & 32) <> 0 Then 'GRN - Amended'
			--When (isnull(GRNStatus,0) & 64) <> 0 Then 'GRN - Cancelled'	
			When (isnull(GRNStatus,0) & 16) <> 0 Then 'GRN - Amendment'
			Else  'GRN' End
		, GRNDate, @GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract where (isnull(GRNStatus,0) & 64) = 0 and (dbo.StripDateFromTime(CreationTime) 
			Between @FromDate and @ToDate)
		Order By GRNID




		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='GRN' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'GRN - Amendment',GRNDate,@GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract 
		Where (dbo.StripDateFromTime(CreationTime) Between @FromDate and @ToDate)
			And ISNULL(GRNIDRef,0)<>0 And  (isnull(GRNStatus,0) & 64) <>0 And (UserName in (Select UserName From #Users))
		Order By GRNID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case 
			--When (isnull(GRNStatus,0) & 32) <> 0 Then UserName 
			When (isnull(GRNStatus,0) & 64) <> 0 Then CancelUser	
			--When (isnull(GRNStatus,0) & 16) <> 0 Then UserName
			Else 
			UserName
			End,
		Case 
			--When (isnull(GRNStatus,0) & 32) <> 0 Then CreationTime 
			When (isnull(GRNStatus,0) & 64) <> 0 Then CancelDate	
			--When (isnull(GRNStatus,0) & 16) <> 0 Then CreationTime
			Else  
			CreationTime 
			End,
		Case
			-- When (isnull(GRNStatus,0) & 32) <> 0 Then 'GRN - Amended'
			When (isnull(GRNStatus,0) & 64) <> 0 Then 'GRN - Cancelled'	
			--When (isnull(GRNStatus,0) & 16) <> 0 Then 'GRN - Amendment'
			Else  
			'GRN'
			 End
		, GRNDate, @GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract Where  (isnull(GRNStatus,0) & 64) <>  0  and ( dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)
		Order By GRNID



		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='GRN' and isnull(UserID,'') not in (Select UserName From #Users)
		--
		--/* For Amendment and cancelled Transactions*/
		--Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		--Select @FromDate,@ToDate, UserName,CreationTime,'GRN - Amendment',GRNDate,@GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		--From #GRNAbstract 
		--Where (dbo.StripDateFromTime(CancelDate) Between @FromDate and @ToDate)
		--	And ISNULL(GRNIDRef,0)<>0 And  (isnull(GRNStatus,0) & 64) <>0 And (UserName in (Select UserName From #Users))
		--Order By GRNID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'GRN',GRNDate,@GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract 
		Where (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
			And (UserName in (Select UserName From #Users)) And GRNID in(Select TransactionID From #tmpTransaction Where DocType='GRN')
			And ISNULL(GRNIDRef,0)=0 And  (isnull(GRNStatus,0) & 64) <> 0 
		Order By GRNID

		Drop Table #GRNAbstract


		--Bill		
		Select @BillPrefix = isnull(Prefix, '') From VoucherPrefix Where TranID = 'BILL'

		Select * Into #BillAbstract From BillAbstract Where (dbo.StripDateFromTime(CreationTime) 
			Between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case
		-- When (isnull(Status,0) & 192) = 192 Then CancelUserName 
			When (isnull(Status,0) & 128) = 128 Then UserName	
			When (isnull(BillReference,0)) <> 0 Then UserName
			Else  UserName End,
		Case 
		--When (isnull(Status,0) & 192) = 192 Then CancelDate
			When (isnull(Status,0) & 128) = 128 Then CreationTime	
			When (isnull(BillReference,0)) <> 0 Then CreationTime
			Else  CreationTime End,
		Case 
		--	When (isnull(Status,0) & 192) = 192 Then 'BILL - Cancelled'
			When (isnull(Status,0) & 128) = 128 Then 'BILL - Amended'	
			When (isnull(BillReference,0)) <> 0 Then 'BILL - Amendment'
			Else  'BILL' End
		, BillDate, @BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract Where dbo.StripDateFromTime(CreationTime)  	Between @FromDate and @ToDate and (isnull(Status,0) & 192) <> 192
		Order By BillID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When (isnull(Status,0) & 192) = 192 Then CancelUserName 
		--	When (isnull(Status,0) & 128) = 128 Then UserName	
		--	When (isnull(BillReference,0)) <> 0 Then UserName
			--Else  UserName 
		End,
		Case
			 When (isnull(Status,0) & 192) = 192 Then CancelDate
		--	When (isnull(Status,0) & 128) = 128 Then CreationTime	
		--	When (isnull(BillReference,0)) <> 0 Then CreationTime
		--	Else  CreationTime 
			End,
		Case
		   When (isnull(Status,0) & 192) = 192 Then 'BILL - Cancelled'
		--	When (isnull(Status,0) & 128) = 128 Then 'BILL - Amended'	
		--	When (isnull(BillReference,0)) <> 0 Then 'BILL - Amendment'
		--	Else  'BILL'
			 End
		, BillDate, @BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract Where dbo.StripDateFromTime(CancelDate)  	Between @FromDate and @ToDate  and (isnull(Status,0) & 192) = 192
		Order By BillID




		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='BILL' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'BILL - Amendment',BillDate,@BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract 
		Where  (dbo.StripDateFromTime(CreationTime) Between @FromDate and @ToDate)	
			And ISNULL(BillReference,0)<>0 And  (isnull(Status,0) & 192) = 192 And (UserName in (Select UserName From #Users))
		Order By BillID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'BILL',BillDate,@BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract 
		Where  (dbo.StripDateFromTime(CreationTime) Between @FromDate and @ToDate)	
			And (UserName in (Select UserName From #Users))
			And BillID in (Select TransactionID From #tmpTransaction Where DocType='BILL')
			And ISNULL(BillReference,0)=0 And (isnull(Status,0) & 192) = 192 
		Order By BillID

		Drop Table #BillAbstract

		--Purchase Return		
		Select @PRPrefix = isnull(Prefix, '') from VoucherPrefix Where TranID = 'PURCHASE RETURN'

		Select * Into #AdjustmentReturnAbstract From AdjustmentReturnAbstract 
		Where (dbo.StripDateFromTime(CreationTime) Between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)

		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When (isnull(Status,0) & 64) <> 0 Then CancelUser 
			When (isnull(Status,0) & 128) <> 0 Then UserName	
			When (isnull(DocReference,0)) <> 0 Then UserName
			Else  UserName End,
		Case When (isnull(Status,0) & 64) <> 0 Then CancelDate
			When (isnull(Status,0) & 128) <> 0 Then CreationTime	
			When (isnull(DocReference,0)) <> 0 Then CreationTime
			Else  CreationTime End,
		Case When (isnull(Status,0) & 64) <> 0 Then 'PURCHASE RETURN - Cancelled'
			When (isnull(Status,0) & 128) <> 0 Then 'PURCHASE RETURN - Amended'	
			When (isnull(DocReference,0)) <> 0 Then 'PURCHASE RETURN - Amendment'
			Else  'PURCHASE RETURN' End
		, AdjustmentDate, 
		Case ISNULL(GSTFlag,0) When 0 then @PRPrefix + Cast(DocumentID as nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as TransactionDocID ,
		--@PRPrefix + Cast(DocumentID as nvarchar),
		 AdjustmentID ,'PURCHASE RETURN'
		From #AdjustmentReturnAbstract
		Order By AdjustmentID

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='PURCHASE RETURN' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'PURCHASE RETURN - Amendment',AdjustmentDate,
		Case ISNULL(GSTFlag,0) When 0 then @PRPrefix + Cast(DocumentID as nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as TransactionDocID,
		--@PRPrefix + Cast(DocumentID as nvarchar)
		 AdjustmentID ,'PURCHASE RETURN'
		From #AdjustmentReturnAbstract 
		Where  (dbo.StripDateFromTime(CreationTime) Between @FromDate and @ToDate)
			And (UserName in (Select UserName From #Users))
			And ISNULL(DocReference,0)<>0 And  (isnull(Status,0) & 64) <> 0
		Order By AdjustmentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'PURCHASE RETURN',AdjustmentDate,
		--@PRPrefix + Cast(DocumentID as nvarchar), 
		Case ISNULL(GSTFlag,0) When 0 then @PRPrefix + Cast(DocumentID as nvarchar) ELSE ISNULL(GSTFullDocID,'') END as TransactionDocID ,
		AdjustmentID ,'PURCHASE RETURN'
		From #AdjustmentReturnAbstract 
		Where  (dbo.StripDateFromTime(CreationTime) Between @FromDate and @ToDate)
			And (UserName in (Select UserName From #Users))
			And ISNULL(DocReference,0)=0 And  (isnull(Status,0) & 64) <> 0
			And AdjustmentID in (Select TransactionID From #tmpTransaction Where DocType='PURCHASE RETURN')
		Order By AdjustmentID

		Drop Table #AdjustmentReturnAbstract

		--D&D RFA
		Select * Into #DandDAbstract From DandDAbstract Where (dbo.StripDateFromTime(CreationDate) 
			Between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) Between @FromDate and @ToDate)

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When ClaimStatus in(1, 2, 3) Then UserName	End,
			--When ClaimStatus in(192) Then CancelUser End,
		Case When ClaimStatus in(1, 2) Then CreationDate
			When ClaimStatus in(3) Then DestroyedDate End,	
		--	When ClaimStatus in(192) Then CancelDate End,
		Case When ClaimStatus in(1, 2) Then 'D&D RFA' 
			When ClaimStatus in(3) Then 'D&D Destroyed' End
			--When ClaimStatus in(192) Then 'D&D Cancelled' End
		,ClaimDate,DocumentID,ID,'D&D RFA'
		From #DandDAbstract where ClaimStatus <> 192
		Order By ID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case 
			--When ClaimStatus in(1, 2, 3) Then UserName	
			When ClaimStatus in(192) Then UserName End,
		Case 
		--   When ClaimStatus in(1, 2) Then CreationDate
		--	When ClaimStatus in(3) Then DestroyedDate	
			When ClaimStatus in(192) Then CreationDate End,
		Case 
			--When ClaimStatus in(1, 2) Then 'D&D RFA' 
			--When ClaimStatus in(3) Then 'D&D Destroyed'
			When ClaimStatus in(192) Then 'D&D RFA' End
		,ClaimDate,DocumentID,ID,'D&D RFA'
		From #DandDAbstract where ClaimStatus = 192
		Order By ID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When ClaimStatus in(1, 2, 3) Then UserName	
			When ClaimStatus in(192) Then CancelUser End,
		Case When ClaimStatus in(1, 2) Then CreationDate
			When ClaimStatus in(3) Then DestroyedDate	
			When ClaimStatus in(192) Then CancelDate End,
		Case When ClaimStatus in(1, 2) Then 'D&D RFA' 
			When ClaimStatus in(3) Then 'D&D Destroyed'
			When ClaimStatus in(192) Then 'D&D Cancelled' End
		,ClaimDate,DocumentID,ID,'D&D RFA'
		From #DandDAbstract where ClaimStatus = 192
		Order By ID

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='D&D RFA' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #DandDAbstract


		--RFA
		Select * Into #tbl_merp_RFAAbstract From tbl_merp_RFAAbstract Where (dbo.StripDateFromTime(CreationDate) Between @FromDate and @ToDate)

		Create Table #tmpRFA(RFAID int, RFADocID int)
		Insert Into #tmpRFA Select Max(RFAID), RFADocID From #tbl_merp_RFAAbstract Group By RFADocID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate, UserName,#tbl_merp_RFAAbstract.CreationDate, Case When CN.ClaimType in (1,2) Then 'RFA - Damage' When CN.ClaimType in (3) Then 'RFA - Sampling'
		When CN.ClaimType in (3) Then 'RFA - Loyalty Program' Else 'RFA - Others' End  , SubmissionDate, 
		'RFA' + Cast(RFADocID as nvarchar(50)) + ' - ' + isnull(ActivityCode , ''), 
		RFAID, 'RFA' 
		From #tbl_merp_RFAAbstract,ClaimsNote CN  
		Where CN.ClaimID = #tbl_merp_RFAAbstract.DocReference And  RFAID in(Select Distinct RFAID From #tmpRFA)

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='RFA' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #tbl_merp_RFAAbstract
		Drop Table #tmpRFA


		--Quotation
		Select * Into #QuotationAbstract From QuotationAbstract Where (dbo.StripDateFromTime(CreationDate) Between @FromDate and @ToDate)

		
		Select @QuotationPrefix = isnull(Prefix,'') from VoucherPrefix Where TranID = 'QUOTATION'

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate, UserName, CreationDate, 'Quotation', QuotationDate,  
			@QuotationPrefix + Cast(DocumentID as nvarchar(50)), QuotationID, 'Quotation' 
		From #QuotationAbstract
		Where isnull(ModifiedUser, '') = ''
		Union ALL
		Select @FromDate, @ToDate, ModifiedUser, LastModifiedDate, 'Quotation -  Modified', QuotationDate,  
			@QuotationPrefix + Cast(DocumentID as nvarchar(50)), QuotationID, 'Quotation' 
		From #QuotationAbstract
		Where isnull(ModifiedUser, '') <> ''
		Union ALL
		Select @FromDate, @ToDate, UserName, CreationDate, 'Quotation', QuotationDate,  
			@QuotationPrefix + Cast(DocumentID as nvarchar(50)), QuotationID, 'Quotation' 
		From #QuotationAbstract
		Where isnull(ModifiedUser, '') <> ''

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='Quotation' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #QuotationAbstract

		--Van Loading Slip
		Select * Into #VanStatementAbstract From VanStatementAbstract Where (dbo.StripDateFromTime(CreationTime) Between @FromDate and @ToDate)

		
		Select @VanPrefix = isnull(Prefix,'') from VoucherPrefix Where TranID = 'VAN LOADING STATEMENT'

		/* All Transactions */
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate, UserName, CreationTime, 
			Case When isnull(Status, 0) & 64 <> 0  Then 'Van Loading Slip - Returned' 
			When isnull(Status, 0) & 128 <> 0  Then 'Van Loading Slip - Closed' 
			Else 'Van Loading Slip - Open' End,
			LoadingDate, @VanPrefix + Cast(DocumentID as nvarchar(50)), DocSerial, 'Van Loading Slip' 
		From #VanStatementAbstract
		Order By DocSerial

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='Van Loading Slip' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #VanStatementAbstract


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(RefDocid,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(RefDocid,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 192) =192 Then 'Payment - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Payment - Amended' --Amended
		when isnull(RefDocid,'') <>'' Then 'Payment - Amendment' --Amendment
		else 'Payment' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments  SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate) and (isnull(Status,0) & 192) <> 192
		And (UserName in (select UserName from #Users) )
		Order by DocumentID


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(RefDocid,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(RefDocid,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'Payment - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Payment - Amended' --Amended
		when isnull(RefDocid,'') <>'' Then 'Payment - Amendment' --Amendment
		else 'Payment' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments  SA where  (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate) And (isnull(Status,0) & 192) =192
		And  (Cancelusername in (select UserName from #Users))
		Order by DocumentID

		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Payment - Amendment',DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(RefDocid,'') <>'' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		Order by DocumentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Payment',DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(RefDocid,'') ='' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		--And DocumentID in (Select TransactionID from #tmpTransaction where DocType='Payment')
		Order by DocumentID

		Delete From #tmpTransaction Where DocType='Payment' and isnull(UserID,'') not in (Select UserName From #Users)

		---DSWise Collection 
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 64) =64 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(DocRefID,0) <> 0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 64) =64 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(DocRefID,0) <> 0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 64) =64 Then 'DSWiseCollection - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'DSWiseCollection - Amended' --Amended
		when isnull(DocRefID,0) <> 0 Then 'DSWiseCollection - Amendment' --Amendment
		else 'DSWiseCollection' --Open 
		end
		,CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>64
		And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocumentID


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) =64 Then CancelUser --Cancelled
		--when (isnull(Status,0) & 128) =128 Then UserName --Amended
		--when isnull(DocRefID,0) <> 0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) =64 Then CancelDate --Cancelled
		--when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		--when isnull(DocRefID,0) <> 0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) =64 Then 'DSWiseCollection - Cancelled' --Cancelled
		--when (isnull(Status,0) & 128) =128 Then 'DSWiseCollection - Amended' --Amended
		--when isnull(DocRefID,0) <> 0 Then 'DSWiseCollection - Amendment' --Amendment
		else 'DSWiseCollection' --Open 
		end
		,CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract SA where   (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) =64
		And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocumentID

		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'DSWiseCollection - Amendment',CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(DocRefID,0) <> 0 And  (isnull(Status,0) & 64) =64
		And (UserName in (select UserName from #Users))
		Order by DocumentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'DSWiseCollection',CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract SA where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate)
		And isnull(DocRefID,0) = 0 And  (isnull(Status,0) & 64) =64
		And (UserName in (select UserName from #Users))
		--And DocumentID in (Select TransactionID from #tmpTransaction where DocType='DSWiseCollection')
		Order by DocumentID

		Delete From #tmpTransaction Where DocType='DSWiseCollection' and isnull(UserID,'') not in (Select UserName From #Users)

		/* Dispatch - Start*/
		Select * into #DispatchAbstract From DispatchAbstract   where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate or dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate)

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		select @FromDate,@ToDate,UserName,CreationTime,TransactionType,DispatchDate, @Disp+Cast(Documentid as Nvarchar(50)),DispatchID,Doctype From (
		select UserName,CreationTime,'Dispatch' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract Where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] in (1, 2) and isnull(Original_Reference,'') = ''
		Union
		select UserName,CreationTime,'Dispatch - Amended ' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract Where  (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] in (385, 386) and isnull(Original_Reference,'') = ''
		Union
		select UserName,CreationTime,'Dispatch - Amendment' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract Where (dbo.StripDateFromTime(CreationTime) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] IN (1, 2) and isnull(Original_Reference,'') <> ''
		Union
		select UserName,CreationTime,'Dispatch' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract Where (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] in (193, 194) and isnull(Original_Reference,'') = ''
		UNion
		select cancelusername,CancelDate,'Dispatch - Cancel' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		  #DispatchAbstract Where (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate) And cancelusername in (select UserName from #Users)
		and [Status] in (193, 194) and isnull(Original_Reference,'') = ''
		Union
		select UserName,CreationTime,'Dispatch - Amendment' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract Where  (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] IN (193, 194) and isnull(Original_Reference,'') <> ''
		UNion
		select cancelusername,CancelDate,'Dispatch - Cancel' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract Where (dbo.StripDateFromTime(CancelDate) between @FromDate and @ToDate) And cancelusername in (select UserName from #Users)
		and [Status] in (194,193) and isnull(Original_Reference,'') <> ''
		) As   B  ORder by 5,6,2

		/* Dispatch - End*/
		
Drop Table #InvoiceAbstract 
Drop Table #StockTransferInAbstract
Drop Table #StockTransferOutAbstract
Drop Table #SOAbstract
Drop Table #Collections
Drop Table #CreditNote
Drop Table #DebitNote
Drop Table #Payments
Drop Table #InvoiceWiseCollectionAbstract 
Drop Table #DispatchAbstract
End 
Else
Begin
  /*Transaction - Date */
		Select * into #InvoiceAbstract_Tran From InvoiceAbstract   where  (dbo.StripDateFromTime(InvoiceDate) between @FromDate and @ToDate)




		/* For Invoice */

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		select @FromDate,@ToDate, UserName,CreationTime,TransactionType,InvoiceDate,Cast(Documentid as Nvarchar) as Documentid,InvoiceID,DocType from (

		select UserName,CreationTime, (Case When (isnull(Status,0) & 128) <> 0 Then 'Amended Invoice' Else
		'Invoice' End) TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,
		InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract_Tran Where dbo.StripDateFromTime(InvoiceDate) between @FromDate and @ToDate and  InvoiceType = 1  And isnull(Status,0) & 192 <> 192 
		And (UserName in (select UserName from #Users)) --INvoice,Amended Invoice

		Union 

		select UserName,CreationTime, 'Invoice' TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,
		InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract_Tran Where dbo.StripDateFromTime(InvoiceDate) between @FromDate and @ToDate and  InvoiceType = 1  And isnull(Status,0) & 192 = 192 And (UserName in (select UserName from #Users)) -- Invoice Before Cancel

		Union

		select UserName,CreationTime,(Case When (isnull(Status,0) & 128) <> 0 Then (Case When ((isnull(Status,0) & 192) = 192) Then 'Invoice Amendment' Else  'Amended Invoice'  end )Else
		'Invoice Amendment' End) as TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,
		InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract_Tran  Where  dbo.StripDateFromTime(InvoiceDate) between @FromDate and @ToDate and  InvoiceType = 3 And (UserName in (select UserName from #Users)) -- Invoice Amendment

		Union

		select CancelUser as UserName,CancelDate as CreationTime, 'Cancel Invoice'  TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,
		InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract_Tran Where dbo.StripDateFromTime(InvoiceDate) between @FromDate and @ToDate and   InvoiceType In (1,3)  And isnull(Status,0) & 192 = 192
		And (IsNull(CancelUser,'') in (select UserName from #Users)) --Cancel Invoice

		Union

		select UserName,CreationTime as CreationTime, (Case When (isnull(Status,0) & 32) <> 0 Then 'Sales Return Damages' Else
		'Sales Return Saleable' End) as TransactionType,InvoiceDate,
		Case ISNULL(GSTFlag,0) When 0 then @INV+Cast(Documentid as Nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as Documentid,
		InvoiceID,'Invoice' DocType From 
		#InvoiceAbstract_Tran Where  dbo.StripDateFromTime(InvoiceDate) between @FromDate and @ToDate and  InvoiceType In (4,5)  
		And (IsNull(UserName,'') in (select UserName from #Users)) --Sales Return Invoice
		) As   A  ORder by 5,6,2


		/* Temp Tables to store the data from Main Table to improve the performance */
		/* Start */
		Select * into #StockTransferInAbstract_Tran From StockTransferInAbstract where  dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate
		Select * into #StockTransferOutAbstract_Tran From StockTransferOutAbstract where  dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate 
		Select * into #SOAbstract_Tran From SOAbstract  where  dbo.StripDateFromTime(SODate) between @FromDate and @ToDate 
		Select * into #Collections_Tran From Collections  where  dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate 
		Select * into #CreditNote_Tran From CreditNote  where  dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate 
		Select * into #DebitNote_Tran From DebitNote  where  dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate 
		Select * into #Payments_Tran From Payments  where  dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate 
		Select * into #InvoiceWiseCollectionAbstract_Tran From InvoiceWiseCollectionAbstract  where  dbo.StripDateFromTime(CollectionDate) between @FromDate and @ToDate 
		/* End */

		--STI
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STI - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STI - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STI - Amendment' --Amendment
		else 'STI' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) =0 
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STI - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STI - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STI - Amendment' --Amendment
		else 'STI' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0 
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial

		Delete From #tmpTransaction Where DocType='STI' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STI - Amendment',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And ISNULL(Reference,0)<>0 And  (isnull(Status,0) & 64) <>0 
		And (UserName in (select UserName from #Users))
		Order by DocSerial

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STI',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STI'
		From #StockTransferInAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And (UserName in (select UserName from #Users))
		And ISNULL(Reference,0)=0 And  (isnull(Status,0) & 64) <>0 
		And DocSerial in (Select TransactionID from #tmpTransaction where DocType='STI')
		Order by DocSerial


		--STO
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STO - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STO - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STO - Amendment' --Amendment
		else 'ST0' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) =0
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) <>0 Then UserName --Amended
		when (isnull(Status,0) & 16) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then CancellationDate --Cancelled
		when (isnull(Status,0) & 128) <>0 Then CreationDate --Amended
		when (isnull(Status,0) & 16) <>0 Then CreationDate --Amendment
		else CreationDate --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'STO - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) <>0 Then 'STO - Amended' --Amended
		when (isnull(Status,0) & 16) <>0 Then 'STO - Amendment' --Amendment
		else 'ST0' --Open 
		end
		,DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0
		--And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocSerial
		Delete From #tmpTransaction Where DocType='STO' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STO - Amendment',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And ISNULL(Reference,'')<>'' And  (isnull(Status,0) & 64) <>0 
		And (UserName in (select UserName from #Users))
		Order by DocSerial

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationDate,'STO',DocumentDate,IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),DocSerial,'STO'
		From #StockTransferOutAbstract_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And (UserName in (select UserName from #Users))
		And ISNULL(Reference,'')<>'' And  (isnull(Status,0) & 64) <>0 
		And DocSerial in (Select TransactionID from #tmpTransaction where DocType='STO')
		Order by DocSerial


		--Sales Order
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then UserName --Amended
		when isnull(SORef,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then CreationTime --Amended
		when isnull(SORef,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 192) =192 Then 'SO - Cancelled' --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then 'SO - Amended' --Amended
		when isnull(SORef,0) <>0 Then 'SO - Amendment' --Amendment
		else 'SO' --Open 
		end
		,SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract_Tran  SA,VoucherPrefix where  (dbo.StripDateFromTime(SODate) between @FromDate and @ToDate )
		And VoucherPrefix.TranID = 'SALE CONFIRMATION' 
		and (isnull(Status,0) & 192) <>192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by SONumber


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then UserName --Amended
		when isnull(SORef,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then CreationTime --Amended
		when isnull(SORef,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'SO - Cancelled' --Cancelled
		when (isnull(Status,0) & 256) =256 And  (isnull(Status,0) & 64) =64 Then 'SO - Amended' --Amended
		when isnull(SORef,0) <>0 Then 'SO - Amendment' --Amendment
		else 'SO' --Open 
		end
		,SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract_Tran  SA,VoucherPrefix where  (dbo.StripDateFromTime(SODate) between @FromDate and @ToDate)
		And VoucherPrefix.TranID = 'SALE CONFIRMATION' and (isnull(Status,0) & 192) =192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by SONumber

		Delete From #tmpTransaction Where DocType='SO' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'SO - Amendment',SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract_Tran SA,VoucherPrefix where  (dbo.StripDateFromTime(SODate) between @FromDate and @ToDate)
		And VoucherPrefix.TranID = 'SALE CONFIRMATION'
		And ISNULL(SORef,0)<>0 And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		Order by SONumber

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'SO',SODate,VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),SONumber,'SO'
		From #SOAbstract_Tran SA,VoucherPrefix where  (dbo.StripDateFromTime(SODate) between @FromDate and @ToDate)
		And VoucherPrefix.TranID = 'SALE CONFIRMATION'
		And (UserName in (select UserName from #Users))
		And ISNULL(SORef,0)=0 And  (isnull(Status,0) & 192) =192
		Order by SONumber

		--Collections
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(OriginalRef,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(OriginalRef,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'Collection - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Collection - Amended' --Amended
		when isnull(OriginalRef,'') <>'' Then 'Collection - Amendment' --Amendment
		else 'Collection' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 192) <>192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by DocumentID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(OriginalRef,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(OriginalRef,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'Collection - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Collection - Amended' --Amended
		when isnull(OriginalRef,'') <>'' Then 'Collection - Amendment' --Amendment
		else 'Collection' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 192) =192
		--And (UserName in (select UserName from #Users) or Cancelusername in (select UserName from #Users))
		Order by DocumentID


		Delete From #tmpTransaction Where DocType='Collection' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Collection - Amendment',DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(OriginalRef,'') <>'' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		Order by DocumentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Collection',DocumentDate,FullDocID,DocumentID,'Collection'
		From #Collections_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(OriginalRef,'') ='' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		And DocumentID in (Select TransactionID from #tmpTransaction where DocType='Collection')
		Order by DocumentID

		--CreditNote
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'Credit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Credit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Credit Note - Amendment' --Amendment
		else 'Credit Note' --Open 
		end
		,DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)  and  (isnull(Status,0) & 64) =0 
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by CreditID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'Credit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Credit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Credit Note - Amendment' --Amendment
		else 'Credit Note' --Open 
		end
		,DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0 
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by CreditID

		Delete From #tmpTransaction Where DocType='Credit Note' and isnull(UserID,'') not in (Select UserName From #Users)
		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Credit Note - Amendment',DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(RefDocid,0) <>0 And  (isnull(Status,0) & 64)<>0
		And (UserName in (select UserName from #Users))
		Order by CreditID
		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Credit Note',DocumentDate,DocumentReference,CreditID,'Credit Note'
		From #CreditNote_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(RefDocid,0) =0 And  (isnull(Status,0) & 64) <>0
		And (UserName in (select UserName from #Users))
		And CreditID in (Select TransactionID from #tmpTransaction where DocType='Credit Note')
		Order by DocumentID

		--DebitNote
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 64) <>0 Then 'Debit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Debit Note - Amended' --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then 'Debit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Debit Note - Amendment' --Amendment
		else 'Debit Note' --Open 
		end
		,DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate ) and (isnull(Status,0) & 64) = 0
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by DebitID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) <>0 Then Canceluser --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then UserName --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then UserName --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) <>0 Then Cancelled_Date --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then CreationTime --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then CreationTime --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) <>0 Then 'Debit Note - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128  and Balance = 0 Then 'Debit Note - Amended' --Amended
		when (isnull(Status,0) & 128) =128  and isnull(RefDocid,0) <> 0 Then 'Debit Note - Amended' --Amended
		when isnull(status & 128,0 ) = 0 And isnull(RefDocid,0) <>0 Then 'Debit Note - Amendment' --Amendment
		else 'Debit Note' --Open 
		end
		,DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>0
		--And (UserName in (select UserName from #Users) or Canceluser in (select UserName from #Users))
		Order by DebitID

		Delete From #tmpTransaction Where DocType='Debit Note' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Debit Note - Amendment',DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(RefDocid,0) <>0 And  (isnull(Status,0) & 64)<>0
		And (UserName in (select UserName from #Users))
		Order by DebitID
		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Debit Note',DocumentDate,DocumentReference,DebitID,'Debit Note'
		From #DebitNote_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(RefDocid,0) =0 And  (isnull(Status,0) & 64) <>0
		And (UserName in (select UserName from #Users))
		And DebitID in (Select TransactionID from #tmpTransaction where DocType='Debit Note')
		Order by DebitID



		Select * Into #GRNAbstract_Tran From GRNAbstract Where dbo.StripDateFromTime(GRNDate) 
			Between @FromDate and @ToDate 
		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When (isnull(GRNStatus,0) & 32) <> 0 Then UserName 
			--When (isnull(GRNStatus,0) & 64) <> 0 Then CancelUser	
			When (isnull(GRNStatus,0) & 16) <> 0 Then UserName
			Else  UserName End,
		Case When (isnull(GRNStatus,0) & 32) <> 0 Then CreationTime 
			--When (isnull(GRNStatus,0) & 64) <> 0 Then CancelDate	
			When (isnull(GRNStatus,0) & 16) <> 0 Then CreationTime
			Else  CreationTime End,
		Case When (isnull(GRNStatus,0) & 32) <> 0 Then 'GRN - Amended'
			--When (isnull(GRNStatus,0) & 64) <> 0 Then 'GRN - Cancelled'	
			When (isnull(GRNStatus,0) & 16) <> 0 Then 'GRN - Amendment'
			Else  'GRN' End
		, GRNDate, @GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract_Tran where (isnull(GRNStatus,0) & 64) = 0 and (dbo.StripDateFromTime(GRNDate) 
			Between @FromDate and @ToDate)
		Order By GRNID




		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='GRN' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'GRN - Amendment',GRNDate,@GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract_Tran 
		Where (dbo.StripDateFromTime(GRNDate) Between @FromDate and @ToDate)
			And ISNULL(GRNIDRef,0)<>0 And  (isnull(GRNStatus,0) & 64) <>0 And (UserName in (Select UserName From #Users))
		Order By GRNID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case 
			--When (isnull(GRNStatus,0) & 32) <> 0 Then UserName 
			When (isnull(GRNStatus,0) & 64) <> 0 Then CancelUser	
			--When (isnull(GRNStatus,0) & 16) <> 0 Then UserName
			Else 
			UserName
			End,
		Case 
			--When (isnull(GRNStatus,0) & 32) <> 0 Then CreationTime 
			When (isnull(GRNStatus,0) & 64) <> 0 Then CancelDate	
			--When (isnull(GRNStatus,0) & 16) <> 0 Then CreationTime
			Else  
			CreationTime 
			End,
		Case
			-- When (isnull(GRNStatus,0) & 32) <> 0 Then 'GRN - Amended'
			When (isnull(GRNStatus,0) & 64) <> 0 Then 'GRN - Cancelled'	
			--When (isnull(GRNStatus,0) & 16) <> 0 Then 'GRN - Amendment'
			Else  
			'GRN'
			 End
		, GRNDate, @GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract_Tran Where  (isnull(GRNStatus,0) & 64) <>  0  and ( dbo.StripDateFromTime(GRNDate) between @FromDate and @ToDate)
		Order By GRNID



		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='GRN' and isnull(UserID,'') not in (Select UserName From #Users)
		--
		--/* For Amendment and cancelled Transactions*/
		--Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		--Select @FromDate,@ToDate, UserName,CreationTime,'GRN - Amendment',GRNDate,@GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		--From #GRNAbstract 
		--Where (dbo.StripDateFromTime(CancelDate) Between @FromDate and @ToDate)
		--	And ISNULL(GRNIDRef,0)<>0 And  (isnull(GRNStatus,0) & 64) <>0 And (UserName in (Select UserName From #Users))
		--Order By GRNID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'GRN',GRNDate,@GRNPrefix + Cast(DocumentID as nvarchar), GRNID, 'GRN'
		From #GRNAbstract_Tran 
		Where (dbo.StripDateFromTime(GRNDate) between @FromDate and @ToDate)
			And (UserName in (Select UserName From #Users)) And GRNID in(Select TransactionID From #tmpTransaction Where DocType='GRN')
			And ISNULL(GRNIDRef,0)=0 And  (isnull(GRNStatus,0) & 64) <> 0 
		Order By GRNID

		Drop Table #GRNAbstract_Tran


		--Bill
		
		Select @BillPrefix = isnull(Prefix, '') From VoucherPrefix Where TranID = 'BILL'

		Select * Into #BillAbstract_Tran From BillAbstract Where dbo.StripDateFromTime(BillDate) 
			Between @FromDate and @ToDate 

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case
		-- When (isnull(Status,0) & 192) = 192 Then CancelUserName 
			When (isnull(Status,0) & 128) = 128 Then UserName	
			When (isnull(BillReference,0)) <> 0 Then UserName
			Else  UserName End,
		Case 
		--When (isnull(Status,0) & 192) = 192 Then CancelDate
			When (isnull(Status,0) & 128) = 128 Then CreationTime	
			When (isnull(BillReference,0)) <> 0 Then CreationTime
			Else  CreationTime End,
		Case 
		--	When (isnull(Status,0) & 192) = 192 Then 'BILL - Cancelled'
			When (isnull(Status,0) & 128) = 128 Then 'BILL - Amended'	
			When (isnull(BillReference,0)) <> 0 Then 'BILL - Amendment'
			Else  'BILL' End
		, BillDate, @BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract_Tran Where dbo.StripDateFromTime(BillDate)  	Between @FromDate and @ToDate and (isnull(Status,0) & 192) <> 192
		Order By BillID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When (isnull(Status,0) & 192) = 192 Then CancelUserName 
		--	When (isnull(Status,0) & 128) = 128 Then UserName	
		--	When (isnull(BillReference,0)) <> 0 Then UserName
			--Else  UserName 
		End,
		Case
			 When (isnull(Status,0) & 192) = 192 Then CancelDate
		--	When (isnull(Status,0) & 128) = 128 Then CreationTime	
		--	When (isnull(BillReference,0)) <> 0 Then CreationTime
		--	Else  CreationTime 
			End,
		Case
		   When (isnull(Status,0) & 192) = 192 Then 'BILL - Cancelled'
		--	When (isnull(Status,0) & 128) = 128 Then 'BILL - Amended'	
		--	When (isnull(BillReference,0)) <> 0 Then 'BILL - Amendment'
		--	Else  'BILL'
			 End
		, BillDate, @BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract_Tran Where dbo.StripDateFromTime(BillDate)  	Between @FromDate and @ToDate  and (isnull(Status,0) & 192) = 192
		Order By BillID




		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='BILL' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'BILL - Amendment',BillDate,@BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract_Tran 
		Where  (dbo.StripDateFromTime(BillDate) Between @FromDate and @ToDate)	
			And ISNULL(BillReference,0)<>0 And  (isnull(Status,0) & 192) = 192 And (UserName in (Select UserName From #Users))
		Order By BillID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'BILL',BillDate,@BillPrefix + Cast(DocumentID as nvarchar), BillID, 'BILL'
		From #BillAbstract_Tran 
		Where  (dbo.StripDateFromTime(BillDate) Between @FromDate and @ToDate)	
			And (UserName in (Select UserName From #Users))
			And BillID in (Select TransactionID From #tmpTransaction Where DocType='BILL')
			And ISNULL(BillReference,0)=0 And (isnull(Status,0) & 192) = 192 
		Order By BillID

		Drop Table #BillAbstract_Tran

		--Purchase Return
		
		Select @PRPrefix = isnull(Prefix, '') from VoucherPrefix Where TranID = 'PURCHASE RETURN'

		Select * Into #AdjustmentReturnAbstract_Tran From AdjustmentReturnAbstract 
		Where dbo.StripDateFromTime(AdjustmentDate) Between @FromDate and @ToDate

		/* For All Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When (isnull(Status,0) & 64) <> 0 Then CancelUser 
			When (isnull(Status,0) & 128) <> 0 Then UserName	
			When (isnull(DocReference,0)) <> 0 Then UserName
			Else  UserName End,
		Case When (isnull(Status,0) & 64) <> 0 Then CancelDate
			When (isnull(Status,0) & 128) <> 0 Then CreationTime	
			When (isnull(DocReference,0)) <> 0 Then CreationTime
			Else  CreationTime End,
		Case When (isnull(Status,0) & 64) <> 0 Then 'PURCHASE RETURN - Cancelled'
			When (isnull(Status,0) & 128) <> 0 Then 'PURCHASE RETURN - Amended'	
			When (isnull(DocReference,0)) <> 0 Then 'PURCHASE RETURN - Amendment'
			Else  'PURCHASE RETURN' End
		, AdjustmentDate,
		Case ISNULL(GSTFlag,0) When 0 then @PRPrefix + Cast(DocumentID as nvarchar) ELSE ISNULL(GSTFullDocID,'') END as TransactionDocID,
		-- @PRPrefix + Cast(DocumentID as nvarchar), 
		 AdjustmentID ,'PURCHASE RETURN'
		From #AdjustmentReturnAbstract_Tran Where dbo.StripDateFromTime(AdjustmentDate) Between @FromDate and @ToDate
		Order By AdjustmentID

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='PURCHASE RETURN' and isnull(UserID,'') not in (Select UserName From #Users)

		/* For Amendment and cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'PURCHASE RETURN - Amendment',AdjustmentDate,
		Case ISNULL(GSTFlag,0) When 0 then @PRPrefix + Cast(DocumentID as nvarchar) ELSE ISNULL(GSTFullDocID,'') END  as TransactionDocID,
		--@PRPrefix + Cast(DocumentID as nvarchar), 
		AdjustmentID ,'PURCHASE RETURN'
		From #AdjustmentReturnAbstract_Tran 
		Where  (dbo.StripDateFromTime(AdjustmentDate) Between @FromDate and @ToDate)
			And (UserName in (Select UserName From #Users))
			And ISNULL(DocReference,0)<>0 And  (isnull(Status,0) & 64) <> 0
		Order By AdjustmentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'PURCHASE RETURN',AdjustmentDate,
		Case ISNULL(GSTFlag,0) When 0 then @PRPrefix + Cast(DocumentID as nvarchar) ELSE ISNULL(GSTFullDocID,'') END as TransactionDocID,
		--@PRPrefix + Cast(DocumentID as nvarchar),
		 AdjustmentID ,'PURCHASE RETURN'
		From #AdjustmentReturnAbstract_Tran 
		Where  (dbo.StripDateFromTime(AdjustmentDate) Between @FromDate and @ToDate)
			And (UserName in (Select UserName From #Users))
			And ISNULL(DocReference,0)=0 And  (isnull(Status,0) & 64) <> 0
			And AdjustmentID in (Select TransactionID From #tmpTransaction Where DocType='PURCHASE RETURN')
		Order By AdjustmentID

		Drop Table #AdjustmentReturnAbstract_Tran

		--D&D RFA
		Select * Into #DandDAbstract_Tran From DandDAbstract Where dbo.StripDateFromTime(ClaimDate) 
			Between @FromDate and @ToDate 

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When ClaimStatus in(1, 2, 3) Then UserName	End,
			--When ClaimStatus in(192) Then CancelUser End,
		Case When ClaimStatus in(1, 2) Then CreationDate
			When ClaimStatus in(3) Then DestroyedDate End,	
		--	When ClaimStatus in(192) Then CancelDate End,
		Case When ClaimStatus in(1, 2) Then 'D&D RFA' 
			When ClaimStatus in(3) Then 'D&D Destroyed' End
			--When ClaimStatus in(192) Then 'D&D Cancelled' End
		,ClaimDate,DocumentID,ID,'D&D RFA'
		From #DandDAbstract_Tran where ClaimStatus <> 192
		Order By ID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case 
			--When ClaimStatus in(1, 2, 3) Then UserName	
			When ClaimStatus in(192) Then UserName End,
		Case 
		--   When ClaimStatus in(1, 2) Then CreationDate
		--	When ClaimStatus in(3) Then DestroyedDate	
			When ClaimStatus in(192) Then CreationDate End,
		Case 
			--When ClaimStatus in(1, 2) Then 'D&D RFA' 
			--When ClaimStatus in(3) Then 'D&D Destroyed'
			When ClaimStatus in(192) Then 'D&D RFA' End
		,ClaimDate,DocumentID,ID,'D&D RFA'
		From #DandDAbstract_Tran where ClaimStatus = 192
		Order By ID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate,
		Case When ClaimStatus in(1, 2, 3) Then UserName	
			When ClaimStatus in(192) Then CancelUser End,
		Case When ClaimStatus in(1, 2) Then CreationDate
			When ClaimStatus in(3) Then DestroyedDate	
			When ClaimStatus in(192) Then CancelDate End,
		Case When ClaimStatus in(1, 2) Then 'D&D RFA' 
			When ClaimStatus in(3) Then 'D&D Destroyed'
			When ClaimStatus in(192) Then 'D&D Cancelled' End
		,ClaimDate,DocumentID,ID,'D&D RFA'
		From #DandDAbstract_Tran where ClaimStatus = 192
		Order By ID

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='D&D RFA' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #DandDAbstract_Tran


		--RFA
		Select * Into #tbl_merp_RFAAbstract_Tran From tbl_merp_RFAAbstract Where (dbo.StripDateFromTime(SubmissionDate) Between @FromDate and @ToDate)

		Create Table #tmpRFA_Tran(RFAID int, RFADocID int)
		Insert Into #tmpRFA_Tran Select Max(RFAID), RFADocID From #tbl_merp_RFAAbstract_Tran Group By RFADocID

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate, UserName,#tbl_merp_RFAAbstract_Tran.CreationDate, Case When CN.ClaimType in (1,2) Then 'RFA - Damage' When CN.ClaimType in (3) Then 'RFA - Sampling'
		When CN.ClaimType in (3) Then 'RFA - Loyalty Program' Else 'RFA - Others' End  , SubmissionDate, 
		'RFA' + Cast(RFADocID as nvarchar(50)) + ' - ' + isnull(ActivityCode , ''),
		RFAID, 'RFA' 
		From #tbl_merp_RFAAbstract_Tran,ClaimsNote CN  
		Where CN.ClaimID = #tbl_merp_RFAAbstract_Tran.DocReference And  RFAID in(Select Distinct RFAID From #tmpRFA_Tran)

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='RFA' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #tbl_merp_RFAAbstract_Tran
		Drop Table #tmpRFA_Tran


		--Quotation
		Select * Into #QuotationAbstract_Tran From QuotationAbstract Where dbo.StripDateFromTime(QuotationDate) Between @FromDate and @ToDate

		
		Select @QuotationPrefix = isnull(Prefix,'') from VoucherPrefix Where TranID = 'QUOTATION'

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate, UserName, CreationDate, 'Quotation', QuotationDate,  
			@QuotationPrefix + Cast(DocumentID as nvarchar(50)), QuotationID, 'Quotation' 
		From #QuotationAbstract_Tran
		Where isnull(ModifiedUser, '') = ''
		Union ALL
		Select @FromDate, @ToDate, ModifiedUser, LastModifiedDate, 'Quotation -  Modified', QuotationDate,  
			@QuotationPrefix + Cast(DocumentID as nvarchar(50)), QuotationID, 'Quotation' 
		From #QuotationAbstract_Tran
		Where isnull(ModifiedUser, '') <> ''
		Union ALL
		Select @FromDate, @ToDate, UserName, CreationDate, 'Quotation', QuotationDate,  
			@QuotationPrefix + Cast(DocumentID as nvarchar(50)), QuotationID, 'Quotation' 
		From #QuotationAbstract_Tran
		Where isnull(ModifiedUser, '') <> ''

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='Quotation' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #QuotationAbstract_Tran

		--Van Loading Slip
		Select * Into #VanStatementAbstract_Tran From VanStatementAbstract Where (dbo.StripDateFromTime(LoadingDate) Between @FromDate and @ToDate)

		
		Select @VanPrefix = isnull(Prefix,'') from VoucherPrefix Where TranID = 'VAN LOADING STATEMENT'

		/* All Transactions */
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate, @ToDate, UserName, CreationTime, 
			Case When isnull(Status, 0) & 64 <> 0  Then 'Van Loading Slip - Returned' 
			When isnull(Status, 0) & 128 <> 0  Then 'Van Loading Slip - Closed' 
			Else 'Van Loading Slip - Open' End,
			LoadingDate, @VanPrefix + Cast(DocumentID as nvarchar(50)), DocSerial, 'Van Loading Slip' 
		From #VanStatementAbstract_Tran
		Order By DocSerial

		/* To remove user other then selected user */
		Delete From #tmpTransaction Where DocType='Van Loading Slip' and isnull(UserID,'') not in (Select UserName From #Users)

		Drop Table #VanStatementAbstract_Tran


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(RefDocid,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(RefDocid,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 192) =192 Then 'Payment - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Payment - Amended' --Amended
		when isnull(RefDocid,'') <>'' Then 'Payment - Amendment' --Amendment
		else 'Payment' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) and (isnull(Status,0) & 192) <> 192
		And (UserName in (select UserName from #Users) )
		Order by DocumentID


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 192) =192 Then Cancelusername --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(RefDocid,'') <>'' Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 192) =192 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(RefDocid,'') <>'' Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 192) =192 Then 'Payment - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'Payment - Amended' --Amended
		when isnull(RefDocid,'') <>'' Then 'Payment - Amendment' --Amendment
		else 'Payment' --Open 
		end
		,DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments_Tran  SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate) And (isnull(Status,0) & 192) =192
		And  (Cancelusername in (select UserName from #Users))
		Order by DocumentID

		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Payment - Amendment',DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(RefDocid,'') <>'' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		Order by DocumentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'Payment',DocumentDate,FullDocID,DocumentID,'Payment'
		From #Payments_Tran SA where  (dbo.StripDateFromTime(DocumentDate) between @FromDate and @ToDate)
		And isnull(RefDocid,'') ='' And  (isnull(Status,0) & 192) =192
		And (UserName in (select UserName from #Users))
		--And DocumentID in (Select TransactionID from #tmpTransaction where DocType='Payment')
		Order by DocumentID

		Delete From #tmpTransaction Where DocType='Payment' and isnull(UserID,'') not in (Select UserName From #Users)

		---DSWise Collection 
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		--when (isnull(Status,0) & 64) =64 Then CancelUser --Cancelled
		when (isnull(Status,0) & 128) =128 Then UserName --Amended
		when isnull(DocRefID,0) <> 0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		--when (isnull(Status,0) & 64) =64 Then CancelDate --Cancelled
		when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		when isnull(DocRefID,0) <> 0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		--when (isnull(Status,0) & 64) =64 Then 'DSWiseCollection - Cancelled' --Cancelled
		when (isnull(Status,0) & 128) =128 Then 'DSWiseCollection - Amended' --Amended
		when isnull(DocRefID,0) <> 0 Then 'DSWiseCollection - Amendment' --Amendment
		else 'DSWiseCollection' --Open 
		end
		,CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract_Tran SA where  (dbo.StripDateFromTime(CollectionDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) <>64
		And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocumentID


		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate,case 
		when (isnull(Status,0) & 64) =64 Then CancelUser --Cancelled
		--when (isnull(Status,0) & 128) =128 Then UserName --Amended
		--when isnull(DocRefID,0) <> 0 Then UserName --Amendment
		else UserName --Open 
		end
		,case 
		when (isnull(Status,0) & 64) =64 Then CancelDate --Cancelled
		--when (isnull(Status,0) & 128) =128 Then CreationTime --Amended
		--when isnull(DocRefID,0) <> 0 Then CreationTime --Amendment
		else CreationTime --Open 
		end,
		case 
		when (isnull(Status,0) & 64) =64 Then 'DSWiseCollection - Cancelled' --Cancelled
		--when (isnull(Status,0) & 128) =128 Then 'DSWiseCollection - Amended' --Amended
		--when isnull(DocRefID,0) <> 0 Then 'DSWiseCollection - Amendment' --Amendment
		else 'DSWiseCollection' --Open 
		end
		,CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract_Tran SA where   (dbo.StripDateFromTime(CollectionDate) between @FromDate and @ToDate) and (isnull(Status,0) & 64) =64
		And (UserName in (select UserName from #Users) or CancelUser in (select UserName from #Users))
		Order by DocumentID

		/* For Amendment and then cancelled Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'DSWiseCollection - Amendment',CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract_Tran SA where  (dbo.StripDateFromTime(CollectionDate) between @FromDate and @ToDate)
		And isnull(DocRefID,0) <> 0 And  (isnull(Status,0) & 64) =64
		And (UserName in (select UserName from #Users))
		Order by DocumentID

		/*For NEW AND THEN CANCELLED Transactions*/
		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		Select @FromDate,@ToDate, UserName,CreationTime,'DSWiseCollection',CollectionDate,DocReference,DocumentID,'DSWiseCollection'
		From #InvoiceWiseCollectionAbstract_Tran SA where  (dbo.StripDateFromTime(CollectionDate) between @FromDate and @ToDate)
		And isnull(DocRefID,0) = 0 And  (isnull(Status,0) & 64) =64
		And (UserName in (select UserName from #Users))
		--And DocumentID in (Select TransactionID from #tmpTransaction where DocType='DSWiseCollection')
		Order by DocumentID

		Delete From #tmpTransaction Where DocType='DSWiseCollection' and isnull(UserID,'') not in (Select UserName From #Users)

		/* Dispatch - Start*/
		Select * into #DispatchAbstract_Tran From DispatchAbstract   where  dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate 

		Insert into #tmpTransaction(FromDate,ToDate,UserID,CreationTime,TransactionType,TransactionDate,TransactionDocID,TransactionID,DocType)
		select @FromDate,@ToDate,UserName,CreationTime,TransactionType,DispatchDate, @Disp+Cast(Documentid as Nvarchar(50)),DispatchID,Doctype From (
		select UserName,CreationTime,'Dispatch' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract_Tran Where  (dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] in (1, 2) and isnull(Original_Reference,'') = ''
		Union
		select UserName,CreationTime,'Dispatch - Amended ' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract_Tran Where  (dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] in (385, 386) and isnull(Original_Reference,'') = ''
		Union
		select UserName,CreationTime,'Dispatch - Amendment' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract_Tran Where (dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] IN (1, 2) and isnull(Original_Reference,'') <> ''
		Union
		select UserName,CreationTime,'Dispatch' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract_Tran Where (dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] in (193, 194) and isnull(Original_Reference,'') = ''
		UNion
		select cancelusername,CancelDate,'Dispatch - Cancel' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		  #DispatchAbstract_Tran Where (dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate) And cancelusername in (select UserName from #Users)
		and [Status] in (193, 194) and isnull(Original_Reference,'') = ''
		Union
		select UserName,CreationTime,'Dispatch - Amendment' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract_Tran Where  (dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate) And UserName in (select UserName from #Users)
		and [Status] IN (193, 194) and isnull(Original_Reference,'') <> ''
		UNion
		select cancelusername,CancelDate,'Dispatch - Cancel' TransactionType,DispatchDate,Documentid,DispatchID,'Dispatch' DocType From
		 #DispatchAbstract_Tran Where (dbo.StripDateFromTime(DispatchDate) between @FromDate and @ToDate) And cancelusername in (select UserName from #Users)
		and [Status] in (194,193) and isnull(Original_Reference,'') <> ''
		) As   B  ORder by 5,6,2

		/* Dispatch - End*/	

Drop Table #InvoiceAbstract_Tran 
Drop Table #StockTransferInAbstract_Tran
Drop Table #StockTransferOutAbstract_Tran
Drop Table #SOAbstract_Tran
Drop Table #Collections_Tran
Drop Table #CreditNote_Tran
Drop Table #DebitNote_Tran
Drop Table #Payments_Tran
Drop Table #InvoiceWiseCollectionAbstract_Tran 
Drop Table #DispatchAbstract_Tran

End 


select ID,FromDate,ToDate,UserID,Cast(convert(Nvarchar(10),CreationTime,103) + ' ' + convert(Nvarchar(5),CreationTime,114)  as nvarchar) as [CreationTime],
TransactionType as [Transaction Type],TransactionDate as [Transaction Date],TransactionDocID As [Transaction ID] 
From #tmpTransaction
ORder by UserID,cast (CreationTime as datetime)

Drop Table #tmpTransaction
Drop Table #Users

End 
