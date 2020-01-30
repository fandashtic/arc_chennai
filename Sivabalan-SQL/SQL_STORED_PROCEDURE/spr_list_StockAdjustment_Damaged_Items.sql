CREATE PROCEDURE spr_list_StockAdjustment_Damaged_Items(@STOCKADJID INT,@UOM nVarchar(30))

AS

Declare @ReconcileID INT
Declare  @ReconID int
Declare @StkAdjid nVarchar(max)


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

SELECT StockAdjustment.Product_Code,
"Item Code" = StockAdjustment.Product_Code,
"Item Name" = Items.ProductName, "Batch" = StockAdjustment.Batch_Number,
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
"Damaged Qty" = CASE @UOM	WHEN 'Base UOM' THEN ISNULL(SUM(StockAdjustment.Quantity),0)
WHEN 'UOM 1' THEN Cast(ISNULL(SUM(StockAdjustment.Quantity),0) / (Case Max(IsNull(Items.UOM1_Conversion, 0)) When 0 Then 1 Else Max(IsNull(Items.UOM1_Conversion,1)) End) As Decimal(18,6))
ELSE Cast(ISNULL(SUM(StockAdjustment.Quantity),0) / (Case Max(IsNull(Items.UOM2_Conversion, 0)) When 0 Then 1 Else Max(IsNull(Items.UOM2_Conversion,1)) End) As Decimal(18,6))
END,

"Damaged Value" = ISNULL(SUM(Rate), 0),
--"Reason" = StockAdjustmentReason.Message
"Reason" = IsNull(RC.Reason,''),
"Tax Type" = case bp.Taxtype When 1 Then 'LST'
When 2 Then 'CST'
When 3 Then 'FLST'
When 5 Then 'GST' End
FROM StockAdjustment
Inner Join  Batch_products bp On bp.batch_Code = StockAdjustment.Batch_code
Inner Join  Items On StockAdjustment.Product_Code = Items.Product_Code
Left Outer Join (
Select Distinct Product_code, Reason, 0 as 'ReasonID' from  ReconcileDetail where ReconcileID = @ReconcileID and isNull(Reason,'') <> ''
UNION ALL
Select Distinct Product_code, [Message], SA.ReasonID From StockadjustmentReason , stockadjustment SA, stockadjustmentAbstract SAA
where SAA.AdjustmentID = SA.serialno And SA.serialno = @STOCKADJID  and SA.ReasonID = StockadjustmentReason.MessageID And SAA.AdjustmentType <> 0
UNION ALL
Select Distinct Product_code, RM.Reason_Description, SA.ReasonID From ReasonMaster RM , stockadjustment SA, stockadjustmentAbstract SAA
where SAA.AdjustmentID = SA.serialno And SA.serialno = @STOCKADJID and RM.Reason_Type_ID = SA.ReasonID  And SAA.AdjustmentType = 0
) RC On  StockAdjustment.Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS = RC.Product_code AND StockAdjustment.ReasonID = IsNull(RC.ReasonID,0)
WHERE StockAdjustment.SerialNo = @STOCKADJID
--AND StockAdjustment.ReasonID *= StockadjustmentReason.MessageID
GROUP BY StockAdjustment.Product_Code, Items.ProductName,
StockAdjustment.Batch_Number, RC.Reason, bp.TaxType,Items.UOM,Items.UOM1,Items.UOM2
