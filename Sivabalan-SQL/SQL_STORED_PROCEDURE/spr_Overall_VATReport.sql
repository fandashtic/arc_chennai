CREATE procedure [dbo].[spr_Overall_VATReport]
(
	@FromDate Datetime,
	@ToDate DateTime
)
AS
Begin

	Declare @WDCode NVarchar(255),@WDDest NVarchar(255)
	Declare @CompaniesToUploadCode NVarchar(255)
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
	Select Top 1 @WDCode = RegisteredOwner From Setup
	  
	IF @CompaniesToUploadCode='ITC001'
	Begin
		Set @WDDest = @WDCode
	End
	Else
	Begin
		Set @WDDest = @WDCode
		Set @WDCode = @CompaniesToUploadCode
	End

	Set DateFormat DMY
	Declare @InvoiceFromDate Datetime
	Declare @InvoiceToDate Datetime

	Set @InvoiceFromDate = dbo.Striptimefromdate(@FromDate)
	Set @InvoiceToDate = dbo.Striptimefromdate(@ToDate)

	/* To get Invoice table into Temp table */
	Select InvoiceID, InvoiceType
	Into #tmpInvoiceAbs
	From InvoiceAbstract
	Where dbo.Striptimefromdate(InvoiceDate) Between @InvoiceFromDate and @InvoiceToDate and isnull(Status,0) & 128 = 0

	Select ID.InvoiceID, ID.Product_Code, ID.Batch_Code, ID.Quantity, ID.SalePrice, ID.TaxCode, ID.TaxCode2,
		isnull(ID.STPayable,0) STPayable, isnull(ID.CSTPayable,0) CSTPayable, ID.TAXONQTY
	Into #tmpInvoiceDet
	From InvoiceDetail ID, #tmpInvoiceAbs IA
	Where IA.InvoiceID = ID.InvoiceID

	/* Creating Temp table */
	Create Table #tmpVATRepDet(InvDocID int, InvDocType int, Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Batch_Code int, SalesTOQ int, Quantity Decimal(18,6), SalePrice Decimal(18,6), SalesTaxPerc Decimal(18,6),
			SalesTaxAmount Decimal(18,6), PurchasePTS Decimal(18,6), PurchaseTaxPerc Decimal(18,6), PurchaseTOQ int,
			PurchaseTaxAmount Decimal(18,6), VATType nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #tmpVATRepAbs(TaxRate Decimal(18,6), InputVAT Decimal(18,6), OutputVAT Decimal(18,6))

	Create Table #tmpFinalVATRep(TaxRate Decimal(18,6), InputVAT Decimal(18,6), OutputVAT Decimal(18,6))

	/* To Calculate Sales and Purchase Tax */
	Insert Into #tmpVATRepDet
	(InvDocID, InvDocType, Product_Code, Batch_Code, SalesTOQ, Quantity, SalePrice, SalesTaxPerc, SalesTaxAmount,
			PurchasePTS, PurchaseTaxPerc, PurchaseTOQ, VATType)
	Select IA.InvoiceID, IA.InvoiceType, ID.Product_Code, ID.Batch_Code, ID.TAXONQTY,
		Case When IA.InvoiceType in(4,5,6) Then (0 - ID.Quantity) Else ID.Quantity End Qty, ID.SalePrice,
		Case When ID.STPayable > 0 Then ID.TaxCode Else ID.TaxCode2 End TaxCode,
		Case When  IA.InvoiceType in(4,5,6) Then Case When ID.STPayable > 0 Then -ID.STPayable Else -ID.CSTPayable End
			Else Case When ID.STPayable > 0 Then ID.STPayable Else ID.CSTPayable End End SalesTaxAmt,
		--isnull(BP.PTS,0) PTS, 
		--Case When ID.SalePrice = 0 and isnull(BP.TaxType,0) in (2,3) Then 0 Else isnull(BP.PTS,0) End PTS,
		Case When isnull(BP.TaxType,0) in (2,3) Then 0 Else isnull(BP.PTS,0) End PTS,
		BP.TaxSuffered, BP.TOQ, 'Sales'
	From #tmpInvoiceAbs IA, #tmpInvoiceDet ID, Batch_Products BP
	Where IA.InvoiceID = ID.InvoiceID --and ID.SalePrice > 0
		and ID.Product_Code = BP.Product_Code
		and ID.Batch_Code = BP.Batch_Code

	/* To Calculate STO and Purchase Tax */
	Insert Into #tmpVATRepDet
	(InvDocID, InvDocType, Product_Code, Batch_Code, SalesTOQ, Quantity, SalePrice, SalesTaxPerc, SalesTaxAmount,
			PurchasePTS, PurchaseTaxPerc, PurchaseTOQ, VATType)
	Select SA.DocSerial, 10, SD.Product_Code, SD.Batch_Code, SD.TOQ, SD.Quantity, SD.Rate, SD.TaxSuffered, SD.TaxAmount,
			isnull(BP.PTS,0) PTS, BP.TaxSuffered, BP.TOQ, 'STO'
	From StockTransferOutAbstract SA,StockTransferOutDetail SD, Batch_Products BP
	Where
		(isnull(SA.Status,0) & 192 )  = 0
		and dbo.Striptimefromdate(SA.DocumentDate) Between @InvoiceFromDate and @InvoiceToDate
		and SA.Docserial = SD.Docserial
		and SD.Product_Code = BP.Product_Code
		and SD.Batch_Code = BP.Batch_Code

	/* Update Purchase Tax */
	Update #tmpVATRepDet Set PurchaseTaxAmount = Case When isnull(PurchaseTOQ,0) = 1 Then (Quantity * isnull(PurchaseTaxPerc,0))
		Else (Quantity * PurchasePTS) * (isnull(PurchaseTaxPerc,0)/100) End

--	/* Deleting 0% Sale Tax */
--	Delete From #tmpVATRepDet Where SalesTaxPerc = 0 Or SalesTaxAmount = 0

	/* Insert VAT into Temp table */
	Insert Into #tmpVATRepAbs(TaxRate, OutputVAT)
	Select SalesTaxPerc, Sum(isnull(SalesTaxAmount,0)) From #tmpVATRepDet Group By SalesTaxPerc

	Insert Into #tmpVATRepAbs(TaxRate, InputVAT)
	Select PurchaseTaxPerc, Sum(isnull(PurchaseTaxAmount,0)) From #tmpVATRepDet Group By PurchaseTaxPerc

	Insert Into #tmpFinalVATRep(InputVAT, OutputVAT)
	Select Sum(isnull(InputVAT,0)), Sum(isnull(OutputVAT,0)) From #tmpVATRepAbs

	Select @WDCode [WD Code], @WDCode [WD Code],@WDDest [WD Dest],@FromDate [From Date], @ToDate [To Date],
		InputVAT [Input VAT], OutputVAT [Output VAT] From #tmpFinalVATRep
	Where isnull(InputVAT,0) <> 0 or isnull(OutputVAT,0) <> 0

	Drop Table #tmpInvoiceAbs
	Drop Table #tmpInvoiceDet
	Drop Table #tmpVATRepDet
	Drop Table #tmpVATRepAbs
	Drop Table #tmpFinalVATRep
End
