Create Procedure dbo.Sp_PrepareItemDeactivationList
As 
Begin
	Set DateFormat DMY

	Declare @OpeningDate as DateTime
	Declare @Before90Days as DateTime
	Declare @LastMonthEndDate as DateTime
	Declare @Transactiondate as DateTime
	Declare @ValidFromDate as DateTime
	Declare @ValidToDate as DateTime

	Declare @Value as Int

	Create Table #TmpItems (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Select Top 1 @Transactiondate = Transactiondate,@OpeningDate  = OpeningDate From SetUp

	/* ie: @LastMonthEndDate = Last Month date of Transactiondate */
	/* As per project team we have changed Transactiondate to System Date*/
	Select @LastMonthEndDate = DateAdd(d,-1,Cast((Cast(01 as Nvarchar) + '/' + Cast(Month(getdate()) as NVarchar) + '/'+ Cast(year(getdate()) as Nvarchar)) as DateTime))
	Set @Value = (Select Top 1 Isnull(Flag,0) From Tbl_Merp_ConfigAbstract Where Screencode = 'ITEMDEACT')
	/* ie: @ValidFromDate = Last Month End date Minus Config  Month */
	Select @ValidFromDate = DateAdd(d,1,DateAdd(m,(-@Value),@LastMonthEndDate))
	/* ie: @ValidToDate = System Date */
	Set @ValidToDate = Cast((Convert(Nvarchar(10),Getdate(),103)) as DateTime)

	/* ie: @Before90Days = System Date - 90 days */
	Select @Before90Days = DateAdd(d,-90,Cast((Cast(day(getdate()) as Nvarchar) + '/' + Cast(Month(Getdate()) as NVarchar) + '/'+ Cast(year(Getdate()) as Nvarchar)) as DateTime))

	/* If Opening Date is Greater than Last 90 Days then System shoud not perform Deactivation */
	If @OpeningDate >= @Before90Days
	Begin
		Goto OUT
	End
	/* If Last Transaction Date is Less than Last 90 Days then System shoud not perform Deactivation */
	Else If @Transactiondate <= @Before90Days
	Begin
		Goto OUT
	End
	Else
	Begin

		Create Table #BatchProducts(Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Quantity Decimal(18,6))
		Create Table #Sales (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #Purchase (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #STISTO (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #PurchaseReturn (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #SalesOrder (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #ReceivedInvoice (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		Create Table #Adjustments (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


	/* Batch_Products : Nill Stock */

		Insert Into #BatchProducts(Product_Code,Quantity)
		Select Distinct Product_Code,Sum(Isnull(Quantity,0)) From Batch_Products Group By Product_Code Having Sum(Isnull(Quantity,0)) > 0

	/* Sales & Sales Return : */

		Insert Into #Sales (Product_Code)
		Select Distinct ID.Product_Code from InvoiceDetail ID,InvoiceAbstract IA
		Where ID.InvoiceID = IA.InvoiceID
		And Cast((Convert(Nvarchar(10),IA.InvoiceDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
		And Isnull(IA.Status,0) & 128 = 0

	/* Purchase Bill & GRN: */


		Insert into #Purchase (Product_Code)
		Select Distinct BD.Product_Code From BillAbstract BA,BillDetail BD
		Where BA.BillID = BD.BillID
		And Cast((Convert(Nvarchar(10),BA.BillDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
		And Isnull(BA.Status,0) & 192 = 0

		Union

		Select Distinct GD.Product_Code From GRNAbstract GA,GRNDetail GD
		Where GA.GRNID = GD.GRNID
		And Cast((Convert(Nvarchar(10),GA.GRNDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
		--And Isnull(GA.GRNStatus,0) = 129
/* STATUS VALIDATION CHANGED AS PER STOCK AND SALES ITEM REPORT*/
		And (IsNull(GA.GRNStatus, 0) & 64) = 0 
		And (IsNull(GA.GRNStatus, 0) & 32) = 0

	/* STI & STO : */

		Insert into #STISTO (Product_Code)
		Select Distinct SD.Product_Code From StockTransferInAbstract SA,StockTransferInDetail SD
		Where SA.DocSerial = SD.DocSerial
		And Cast((Convert(Nvarchar(10),SA.DocumentDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
		--And Isnull(SA.Status,0) = 0
/* STATUS VALIDATION CHANGED AS PER STOCK AND SALES ITEM REPORT*/
		And isnull(SA.Status,0) & 192 = 0  
		Union

		Select Distinct SD.Product_Code From StockTransferOutAbstract SA,StockTransferOutDetail SD
		Where SA.DocSerial = SD.DocSerial
		And Cast((Convert(Nvarchar(10),SA.DocumentDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
		And Isnull(SA.Status,0) = 0
/* STATUS VALIDATION CHANGED AS PER STOCK AND SALES ITEM REPORT*/
		And isnull(SA.Status,0) & 192 = 0  

	/* Purchase Return: */

		Insert into #PurchaseReturn (Product_Code)
		Select Distinct PD.Product_Code From AdjustmentReturnAbstract PA,AdjustmentReturnDetail PD
		Where PA.AdjustmentID = PD.AdjustmentID
		And Cast((Convert(Nvarchar(10),PA.AdjustmentDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
		--And Isnull(PA.Status,0) = 0
		And (ISNULL(PA.Status, 0) & 64) = 0
		And (ISNULL(PA.Status, 0) & 128) = 0

	/* Sales Order: */

		Insert into #SalesOrder (Product_Code)
		Select Distinct SD.Product_Code From SOAbstract SA,SODetail SD
		Where SA.SONumber = SD.SONumber
		And Cast((Convert(Nvarchar(10),SA.SODate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
		And (SA.Status & 192) = 0    
	--	And Isnull(SA.Status,0) = 0 
	--  Union

	/* AS Discussed with Project Team The Order Header is not Validated. */

	--	Select Distinct OD.Product_Code From Order_Header OA,Order_Details OD
	--	Where OA.OrderNumber = OD.OrderNumber
	--	And Cast((Convert(Nvarchar(10),OA.Order_Date,103)) as DateTime) Between @ValidFromDate And @ValidToDate
	--	And Isnull(OA.Status,0) = 0 

	/* Pending Received Invoice: */

	/* AS Discussed with Project Team Received Invoice Validated between the period only. */

		Insert into #ReceivedInvoice (Product_Code)
		Select Distinct ID.Product_Code From InvoiceAbstractReceived IA,InvoiceDetailReceived ID
		Where IA.InvoiceID = ID.InvoiceID
		And Cast((Convert(Nvarchar(10),IA.InvoiceDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate 
--		And Isnull(IA.Status,0) = 0
		And IsNull(IA.Status,0) & 1 = 0 And IsNull(IA.Status,0) & 32 = (IsNull(IA.Status,0) & 32)
		And IsNull(IA.Status,0) & 64 = 0

	/* Physical Stock & Adjustments: */

		Insert into #Adjustments (Product_Code)
--		Select Distinct D.Product_Code From ReconcileAbstract A,ReconcileDetail D
--		Where A.ReconcileID = D.ReconcileID
--		And Cast((Convert(Nvarchar(10),A.ReconcileDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate
--	--	And Isnull(A.Status,0) = 0
--
--		Union

		Select Distinct D.Product_Code From StockAdjustmentAbstract A,StockAdjustment D
		Where A.AdjustmentID = D.SerialNO
		And Cast((Convert(Nvarchar(10),A.AdjustmentDate,103)) as DateTime) Between @ValidFromDate And @ValidToDate

		Insert Into #TmpItems (Product_Code)
		Select Distinct Product_Code  From Items 
		Where Isnull(Active,0) = 1
		And Product_Code Not In(Select Distinct Product_Code From #BatchProducts)
		And Product_Code Not In(Select Distinct Product_Code From #Sales)
		And Product_Code Not In(Select Distinct Product_Code From #Purchase)
		And Product_Code Not In(Select Distinct Product_Code From #STISTO)
		And Product_Code Not In(Select Distinct Product_Code From #PurchaseReturn)
		And Product_Code Not In(Select Distinct Product_Code From #SalesOrder)
		And Product_Code Not In(Select Distinct Product_Code From #ReceivedInvoice)
		And Product_Code Not In(Select Distinct Product_Code From #Adjustments)

		Drop Table #BatchProducts
		Drop Table #Sales
		Drop Table #Purchase
		Drop Table #STISTO
		Drop Table #PurchaseReturn
		Drop Table #SalesOrder
		Drop Table #ReceivedInvoice
		Drop Table #Adjustments

	End

OUT:
	Update Items Set Active = 0 Where Product_Code in(Select Distinct Product_Code from #TmpItems)

	Exec SP_ValidateItemDeactivation 1

	Select Distinct Product_Code from #TmpItems

	Drop Table #TmpItems
END
