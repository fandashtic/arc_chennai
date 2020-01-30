CREATE PROCEDURE [dbo].[spr_BillVsSales] (@FromDATE DATETIME,@ToDATE DATETIME,@DocType Nvarchar(255))                
	As 
		Begin
Set dateformat dmy

Create Table #Tempdata (
Product_code Nvarchar(255),
Billed Decimal(18,6) Default 0,
Sales Decimal(18,6) Default 0,
[ReturnQty] Decimal(18,6) Default 0)


Create Table #TempVan(
DocType Nvarchar(255))

Create Table #TempInvoice (
DocId Int,
InvId Int)

CREATE TABLE [dbo].[#Tempid](
	[DocSerialType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[invoiceid] [int] NOT NULL,
	[documentid] [int] NULL,
	[status] [int] NULL,
	[Product_code] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Sales] [decimal](18, 6) NOT NULL
) ON [PRIMARY]

create Table #tempOut (
van Nvarchar(255),
ItemCode Nvarchar(255),
ItemName Nvarchar(255),
BillQty Decimal(18,6),
SalesQty Decimal(18,6),
DiffrentQty Decimal(18,6)
)

If @DocType = '%'
	Begin
		Insert into #TempVan select Distinct DocSerialType From InvoiceAbstract Where dbo.stripTimeFromdate(invoicedate) between @FromDATE and @ToDATE  and isnull(DocSerialType,'') <> ''
	End
Else
	Begin
		Insert into #TempVan select @DocType
	End

--select * from #TempVan

Truncate Table #tempOut

Declare @Van as Nvarchar(255)
Declare @clu1 Cursor 
Set @clu1 = Cursor for
Select Distinct DocType from #TempVan
Open @clu1
Fetch Next from @clu1 into @Van
While @@fetch_status =0
		Begin

		Insert into #TempInvoice (DocId) select Distinct  documentid From invoiceabstract Where 
		dbo.stripTimeFromdate(invoicedate) between @FromDATE and @ToDATE 
		and InvoiceType in (1,3) 
		And DocSerialType like @Van
		--And Invoiceid in (select Distinct InvoiceId from Invoicedetail where product_code = '11651')


			Declare @DocId as Int
			Declare @InvId as Int
			Declare @clu Cursor 
			Set @clu = Cursor for
			Select Distinct DocId from #TempInvoice
			Open @clu
			Fetch Next from @clu into @DocId
			While @@fetch_status =0
					Begin
						Set @InvId = (select Top 1 Invoiceid From invoiceabstract Where documentid = @DocId And DocSerialType Like @Van Order by Invoiceid Asc)
						Update #TempInvoice Set Invid = @InvId Where Docid = @DocId
						Fetch Next from @clu into @DocId
					End
			Close @clu
			Deallocate @clu

		--select * from #TempInvoice

		Insert into  #Tempdata (Product_Code) select Distinct Product_Code from invoicedetail ID, invoiceabstract IA
		where IA.invoiceid  = ID.invoiceid 
		And dbo.stripTimeFromdate(IA.invoicedate) between @FromDATE and @ToDATE 
		and IA.InvoiceType in (1,3) 
		And IA.DocSerialType like @Van

		Truncate table #Tempid
		Insert Into #Tempid
		select IA.DocSerialType,ia.invoiceid,ia.documentid,ia.status,ID.Product_code, isnull(Sum(ID.Quantity),0) Sales 
		from invoicedetail ID, invoiceabstract IA
		where IA.invoiceid  = ID.invoiceid 
		And dbo.stripTimeFromdate(IA.invoicedate) between @FromDATE and @ToDATE 
		and IA.InvoiceType in (1,3) 
		And isnull(IA.status,0) in( 4,8)
		And IA.DocSerialType like @Van
		--And ID.product_code = '11651'
		Group By IA.DocSerialType,ia.invoiceid,ia.documentid,ia.status,ID.Product_code

		Update T Set T.Sales = T1.Sales
		From #Tempdata T,
		(select Product_code, isnull(Sum(Sales),0) Sales from #Tempid
		Group By Product_code)T1 Where T.Product_code = T1.Product_code

		Truncate table #Tempid
		Insert Into #Tempid
		select IA.DocSerialType,ia.invoiceid,ia.documentid,ia.status,ID.Product_code, isnull(Sum(ID.Quantity),0) Sales 
		from invoicedetail ID, invoiceabstract IA
		where IA.invoiceid  = ID.invoiceid 
		And dbo.stripTimeFromdate(IA.invoicedate) between @FromDATE and @ToDATE 
		and IA.InvoiceType in (1,3) 
		--And isnull(IA.status,0) in( 132, 136)
		--And isnull(IA.status,0) Not in ( 4,8)
		And IA.DocSerialType like @Van
		and IA.Invoiceid in (select Distinct Invid From #TempInvoice)
		--And ID.product_code = '11651'
		Group By IA.DocSerialType,ia.invoiceid,IA.InvoiceType,ia.documentid,ia.status,ID.Product_code,ia.invoicedate

		Update T Set T.Billed = T1.Sales
		From #Tempdata T,
		(select Product_code, isnull(Sum(Sales),0) Sales from #Tempid
		Group By Product_code)T1 Where T.Product_code = T1.Product_code

		Update #Tempdata Set [ReturnQty] = Isnull((isnull(Billed,0) - Isnull(Sales,0)),0)

		Insert Into #tempOut
		
		select @Van Van , T.Product_code ItemCode,I.Productname ItemName,
		cast((T.Billed / I.UOM2_Conversion) as Decimal(18,6)) ,
		 Cast((T.Sales / I.UOM2_Conversion) as Decimal (18,6))   ,
		cast((T.ReturnQty / I.UOM2_Conversion) as Decimal(18,6))
		from #Tempdata T, Items I Where I.Product_code = T.Product_code
		Order By 2 Asc

		Fetch Next from @clu1 into @Van
		End
Close @clu1
Deallocate @clu1

select 1, * from #tempOut

Drop Table #tempOut
Drop table #TempVan
Drop table #Tempid
Drop table #Tempdata
Drop table #TempInvoice
END
