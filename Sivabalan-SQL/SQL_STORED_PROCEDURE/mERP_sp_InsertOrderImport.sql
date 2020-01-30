Create Procedure mERP_sp_InsertOrderImport
( 
@CustomerID nVarchar(1000),
@OrderRefNumber nVarchar(100),
@SalesmanID int,
@BeatID int,
@ItemInfo varchar(8000) 
)
AS
Begin
	Declare @MaxID as Int
	Declare @OHMaxID as Int
	Declare @SOMaxID as Int
	Declare @ERPID as nvarchar(50)
	Declare @ItemCode as nvarchar(150)
	Declare @ItemName as nvarchar(150)
	Declare @Uom as nvarchar(150)
	Declare @Qty DEcimal(18,6)
	Declare @ItemDetails as nvarchar(2000)
	Declare @RowCount as Int
	Declare @ncounter as Int
	Declare @UOMID  as Int



	SELECT @OHMaxID = MAX(CAST(REPLACE(ORDERNUMBER,'ERP','') AS INT)) FROM Order_Header
	WHERE upper(SUBSTRING(ORDERNUMBER,1,3)) = 'ERP'
	
	SELECT @SOMaxID = MAX(CAST(REPLACE(POReference,'ERP','') AS INT)) FROM SOAbstract
	WHERE upper(SUBSTRING(POReference,1,3)) = 'ERP'

	IF @OHMaxID > @SOMaxID
		SET @MAXID = @OHMaxID
	Else
		SET @MAXID = @SOMaxID
	
	SET @MAXID = Isnull(@MAXID,0) + 1
	Set @ERPID = 'ERP' + Cast(@MAXID as nvarchar)

	Insert Into Order_Header(OrderNumber,Order_Date,Delivery_Date,SalesmanID,BeatID,OutletID, Processed, VanOrder, Paymenttype, DiscountAmt, DiscountPer,OrderRefNumber,
							 ProfitCenter,VanLoadingSlipNumber,CreationDate,InvoicedYN,Supervisor_ID) 
	Values (@ERPID, getdate(), getdate() , @SalesmanID, @beatID, @CustomerID, 0, 0, 0, 0, 0,@OrderRefNumber,
			0,0,getdate(),0,0)

	Create table #TblItemDetails(ID Int identity(1,1), ItemValue nvarchar(150)) 
	Declare @TblItemInfo table([ID] Int Identity(1,1), ItemInfo nvarchar(2000))

	Set @ncounter = 1

	Insert Into @TblItemInfo 
	select * from dbo.sp_splitin2Rows(@ItemInfo,'|')
	Set @RowCount = (select max(ID) from @TblItemInfo)


	While (@ncounter <= @RowCount)
	Begin
		Set @ItemDetails = (select ItemInfo from @TblItemInfo where [ID] = @ncounter)

		Insert Into #TblItemDetails
		select * from dbo.sp_splitin2Rows(@ItemDetails,'~')

		Set @ItemCode = (select [ItemValue] from #TblItemDetails where [ID] = 1)
		Set @ItemName = (select [ItemValue] from #TblItemDetails where [ID] =2)
		Set @Uom = (select [ItemValue] from #TblItemDetails where [ID] = 3)
		Set @Qty = (select [ItemValue] from #TblItemDetails where [ID] = 4)
		Select @UOMID = UOM from UOM where DEscription = @Uom

		Truncate Table #TblItemDetails
		
		Insert Into Order_details (OrderNumber, Order_Detail_ID, Product_Code, OrderedQty, UOMID, Processed )
		Values(@ERPID, @ncounter, @ItemCode, @qty, @UOMID, 0)
		Set @ncounter = @ncounter + 1

	End
	Select 1
	drop table #TblItemDetails
End
