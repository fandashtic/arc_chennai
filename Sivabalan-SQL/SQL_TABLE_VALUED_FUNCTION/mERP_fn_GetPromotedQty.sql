Create Function mERP_fn_GetPromotedQty(
@ItemCode as nvarchar (30), @SchemeID Int, @SlabID Int,@SaleQty Decimal(18,6), @SaleValue Decimal(18,6),
@SKUCode nVarchar(2000) = '', @SKUQty nVarchar(2000) = '', @SKUPrice nVarchar(2000) = '' )
Returns @PRQty Table (PromotedQty Decimal(18,6), PromotedValue Decimal(18,6), UOM Int)
As
Begin


Declare @SlabSt Decimal(18,6)
Declare @SlabEd Decimal(18,6)
Declare @PromotedValue Decimal(18,6)
Declare @PromotedQty Decimal(18,6)
Declare @PValue Decimal(18,6)
Declare @UOM Int
Declare @Onward Decimal(18,6)
Declare @SlabType Int
Declare @UOM1_Conversion Decimal(18,6)
Declare @UOM2_Conversion Decimal(18,6)
Declare @tmpQty Decimal (18,6)


Declare @SKU Table(CodeID Int Identity, Code nVarchar(255), Qty Decimal(18,6), UOMConv Decimal(18,6), QtyCon Decimal(16,8))
Declare @QTY Table(ID Int Identity, Quantity Decimal(18,6))

Select @SlabSt = SlabStart, @SlabEd = SlabEnd, @UOM = UOM, @Onward = OnWard, @SlabType = SlabType
From tbl_merp_SchemeSlabdetail
Where SlabID = @SlabID And SchemeID = @SchemeID

If @SKUCode = ''
Begin --@SKUCode <> ''
If @UOM < 4
Begin
Select @UOM1_Conversion = IsNull(UOM1_Conversion,1), @UOM2_Conversion = IsNull(UOM2_Conversion,1)
From Items Where Product_code = @ItemCode
If @UOM = 1
Set @tmpQty = @SaleQty
Else if @UOM = 2
Set @tmpQty = @SaleQty / @UOM1_Conversion
Else if @UOM = 3
Set @tmpQty = @SaleQty / @UOM2_Conversion
End
--Else
Else IF @UOM = 4
Begin
Set @tmpQty = @SaleValue
End
Else IF @UOM = 5
Begin
Set @PromotedQty = 0
Set @PromotedValue = @SaleValue
End

If @tmpQty >= @SlabSt And @tmpQty <= @SlabEd
Begin

If @Onward <> 0
Begin
Set @PValue = Cast((@tmpQty / @Onward) as Int)
--If @UOM <> 4
If @UOM < 4
Set @PromotedQty = @PValue * @Onward
--Else
Else IF @UOM = 4
Set @PromotedValue = @PValue * @Onward
End
Else
Begin
--If @UOM <> 4
If @UOM < 4
Set @PromotedQty = @tmpQty
--Else
Else IF @UOM = 4
Set @PromotedValue = @tmpQty
End
End

If @UOM < 4
Begin
if @UOM = 2
Set @PromotedQty = @PromotedQty * @UOM1_Conversion
Else if @UOM = 3
Set @PromotedQty = @PromotedQty * @UOM2_Conversion
End

End --@SKUCode <> ''
Else --SplCategory Scheme
Begin

Insert Into	@SKU(Code) Select * From  dbo.sp_SplitIn2Rows(@SKUCode, '|')

If @UOM = 4 or @UOM = 5
Insert Into	@QTY(Quantity) Select * From dbo.sp_SplitIn2Rows(@SKUPrice, '|')
--Else
Else IF @UOM < 4
Insert Into	@QTY(Quantity) Select * From dbo.sp_SplitIn2Rows(@SKUQty, '|')


Update @SKU Set Qty = Quantity From  @QTY Where CodeID = ID

If @UOM = 4
Begin

Select @PValue = Sum(Qty) From @SKU

If @PValue >= @SlabSt And @PValue <= @SlabEd
Begin
If @Onward <> 0
Set @PValue = Cast((@PValue / @Onward) as Int) * @Onward
End
--Insert Into @PRQty Values (0, @PValue, @UOM)
Select @PromotedQty = 0, @PromotedValue = @PValue

End
--Else
Else IF @UOM = 5
Begin
Select @PValue = Sum(Qty) From @SKU
Select @PromotedQty = 0, @PromotedValue = @PValue
End
Else IF @UOM < 4
Begin

Declare @Total Decimal(18,6)

If @UOM = 1
Update @SKU Set UOMConv = 1 From  @QTY Where CodeID = ID
Else If @UOM = 2
Update @SKU Set UOMConv = (Select UOM1_Conversion From Items Where Product_Code = Code) From  @QTY Where CodeID = ID
Else If @UOM = 3
Update @SKU Set UOMConv = (Select UOM2_Conversion From Items Where Product_Code = Code) From  @QTY Where CodeID = ID

Update @SKU Set QtyCon = Qty / UOMConv From @Qty Where CodeID = ID

Select @PValue = Sum(QtyCon) From @SKU

If @PValue >= @SlabSt And @PValue <= @SlabEd
Begin
If @Onward <> 0
Set @Total = Cast((@PValue / @Onward) as Int) * @Onward
Else
Set @Total = @PValue
End

Update @SKU Set QtyCon =  (@Total / @PValue) * QtyCon  From @Qty Where CodeID = ID

Update @SKU Set QtyCon = Case @UOM
When 1 Then QtyCon
When 2 Then QtyCon * (Select UOM1_Conversion From Items Where Product_Code = Code)
When 3 Then QtyCon * (Select UOM2_Conversion From Items Where Product_Code = Code)
End
From @Qty Where CodeID = ID

Select @PValue = Sum(QtyCon) From @SKU
--Insert Into @PRQty Values (@PValue, 0 , @UOM)
Select @PromotedQty = @PValue, @PromotedValue = 0
End
End
Insert Into @PRQty Values (@PromotedQty, @PromotedValue, @UOM)
--Select * from @PRQty
Return
End
