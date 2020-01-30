Create Procedure [dbo].Spr_QuotationSales_Detail(@ProductCode Nvarchar(255),@ItemCode Nvarchar(4000),@UOM Nvarchar(4000),@FromDate DateTime,@ToDate DateTime)
As   
Begin

DECLARE @INV AS NVARCHAR(50)  
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'   

	Set DateFormat DMY

	CREATE TABLE #TempDtl(
		[Product_code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Invoice ID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Doc Ref] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Invoice Date] [datetime] NULL,
		[Customer ID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Customer Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[UOM] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Qty] [decimal](18, 6) NULL,
		[Sales Value] [decimal](18, 6) NULL,
		[PTR Value] [decimal](18, 6) NULL,
		[Quotation Name] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL) 

	insert into #TempDtl
	select ID.Product_code, case IsNull(IA.GSTFlag,0) when 0 then @INV + CAST(IA.DocumentID AS nVARCHAR)  else   IsNULL(IA.GSTFullDocID,'')
                End [Invoice ID],
	Cast(IA.DocReference as Nvarchar(255)) [Doc Ref],
	dbo.stripdatefromtime(IA.Invoicedate) [Invoice Date],
	IA.Customerid [Customer ID],
	C.Company_Name [Customer Name],
	U.Description [UOM],

	Cast((Sum(Isnull(Case @UOM 
	When 'UOM1' Then (ID.Quantity / IsNull(I.UOM1_Conversion, 1))
	When 'UOM2' Then (ID.Quantity / IsNull(I.UOM2_Conversion, 1))
	Else (ID.Quantity )	End
	, 0))) as Decimal(18,6)) Qty,

	Cast((Sum(Isnull(((ID.Quantity) * (ID.SalePrice)), 0))) as Decimal(18,6)) [Sales Value],

	Cast((Sum(Isnull(((ID.Quantity) * (ID.PTR)), 0))) as Decimal(18,6))[PTR Value],

	Case When (Isnull(ID.QuotationID,0) > 0) Then Q.QuotationName 
	When (Isnull(ID.QuotationID,0) = 0) Then '' End [Quotation Name]

	from InvoiceAbstract IA(Nolock) , Invoicedetail ID(Nolock),Items I,Customer C,QuotationAbstract Q, UOM U
	where dbo.stripdatefromtime(IA.Invoicedate) Between @FromDate and @ToDate 
	And IA.InvoiceType in (1,3) 
	And (IA.Status & 128) = 0
	And ID.Product_code Like @ProductCode
	And I.Product_code Like @ProductCode
	And ID.Invoiceid = IA.Invoiceid
	And C.Customerid = IA.Customerid
	And Q.QuotationID = Isnull(ID.QuotationID,0) 
	And U.Active = 1
	And U.UOM = (Select case @UOM When 'Base UOM' Then I.UOM When 'UOM1' then I.UOM1 When 'UOM2' then I.UOM2 End) 
	Group By ID.Product_code ,IA.DocReference, IA.Documentid,dbo.stripdatefromtime(IA.Invoicedate),IA.Customerid,C.Company_Name,ID.QuotationID,Q.QuotationName ,U.Description,IA.GSTFlag,IA.GSTFullDocID

	
	select * from #TempDtl

	Drop Table #TempDtl
End
