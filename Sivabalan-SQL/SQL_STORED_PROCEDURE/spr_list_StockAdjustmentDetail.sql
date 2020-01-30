CREATE PROCEDURE spr_list_StockAdjustmentDetail(@STOCKADJID Int, @UOM nVarchar(15))
AS
Begin

Declare @temp TABLE(
[SerialNO] [int] NOT NULL ,
[Product_Code] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
[Batch_Code] [int] NULL ,
[Batch_Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
[Quantity] [decimal](18, 6) NULL ,
[Rate] [decimal](18, 6) NULL ,
[ReasonID] [int] NULL ,
[OldQty] [decimal](18, 6) NULL ,
[OldValue] [decimal](18, 6) NULL,
IDField int identity not null,
UOM int,
UOMQty Decimal(18,6)  ,
UOMPrice Decimal(18,6)
)
Declare @STOCKADJID1 nVarchar(255)
Declare @ReconcileID INT
Declare  @ReconID int
Declare @StkAdjid nVarchar(max)
Declare @NewBatch Int
Declare @BatchType int
Declare @ReconBatch_Code nVarchar(Max)

Set @NewBatch = 0

Insert into @temp select * from stockadjustment where serialno = @STOCKADJID

--Select * from @temp

Declare Cur_GetBatch Cursor For
Select ReconcileID, IsNull(StockAdjID,'') From ReconcileAbstract
Where IsNull(StockAdjID,'') Like '%' + CAst(@STOCKADJID As nVarchar(MAX)) + '%'
Open Cur_GetBatch
Fetch Next From Cur_GetBatch into @ReconID, @StkAdjid
While @@Fetch_Status = 0
Begin
If Exists(Select * from dbo.fn_SplitIn2Rows_Int(@StkAdjid,',') Where ItemValue = @STOCKADJID)
Set @ReconcileID =  @ReconID

Fetch Next From Cur_GetBatch into @ReconID, @StkAdjid
End
Close Cur_GetBatch
Deallocate Cur_GetBatch

SELECT
"Item Code" = TMP.Product_Code,
"Item Code" = TMP.Product_Code,
"Item Name" = Items.ProductName,
"Batch" = TMP.Batch_Number,
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
"Orig Qty" = CASE @UOM	WHEN 'Base UOM' THEN ISNULL(SUM(OldQty),0)
WHEN 'UOM 1' THEN Cast(ISNULL(SUM(OldQty),0) / (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(ISNULL(SUM(OldQty),0) / (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,


"Orig Value" = ISNULL(SUM(OldValue),0),
"New Qty" = CASE @UOM	WHEN 'Base UOM' THEN ISNULL(SUM(TMP.Quantity),0)
WHEN 'UOM 1' THEN Cast(ISNULL(SUM(TMP.Quantity),0) / (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast(ISNULL(SUM(TMP.Quantity),0) / (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"New Value" = ISNULL(SUM(Rate), 0),
"Adj Qty" = CASE @UOM	WHEN 'Base UOM' THEN ISNULL(SUM(TMP.Quantity),0) - IsNull(Sum(OldQty), 0)
WHEN 'UOM 1' THEN Cast((ISNULL(SUM(TMP.Quantity),0) - IsNull(Sum(OldQty), 0)) / (Case IsNull(Max(Items.UOM1_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM1_Conversion),1) End) As Decimal(18,6))
ELSE Cast((ISNULL(SUM(TMP.Quantity),0) - IsNull(Sum(OldQty), 0)) / (Case IsNull(Max(Items.UOM2_Conversion), 0) When 0 Then 1 Else IsNull(Max(Items.UOM2_Conversion),1) End) As Decimal(18,6))
END,
"Adj Value" = ISNULL(SUM(Rate), 0) - ISNULL(SUM(OldValue),0)
,"Reason" = IsNull(RC.Reason,''),
"Tax Type" = case bp.Taxtype when 1 Then 'LST'
When 2 Then 'CST'
When 3 Then 'FLST' End
FROM @temp TMP
Inner Join Items  On TMP.Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS = Items.Product_Code
Inner Join Batch_products bp On bp.batch_Code = TMP.Batch_code
Left Outer Join (
Select Distinct Product_code, Reason, 0 'ReasonID' from  ReconcileDetail where ReconcileID = @ReconcileID and IsNull(Reason,'') <> ''
UNION ALL
Select Distinct Product_code, [Message], SA.ReasonID From StockadjustmentReason , stockadjustment SA where SA.serialno = @STOCKADJID  and SA.ReasonID = StockadjustmentReason.MessageID
) RC On TMP.ReasonID = IsNull(RC.ReasonID,0) AND TMP.Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS = RC.Product_code
WHERE TMP.SerialNo = @STOCKADJID
GROUP BY TMP.Product_Code, Items.ProductName, TMP.Batch_Number, RC.Reason, bp.TaxType,Items.UOM,Items.UOM1,Items.UOM2
Order By MAX(TMP.IDField)

End

