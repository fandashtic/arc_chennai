Create Function mERP_fn_GetPointsSchValue
(@SchemeID Int, @GroupID Int, @Qty Decimal(18,6), @SaleValue Decimal(18,6), @UOM1Qty Decimal(18,6), @UOM2Qty Decimal(18,6), @Flag Int = 0)
Returns @SchValue Table(PromotedQty Decimal(18,6), PromotedValue Decimal(18,6), RebateQty Decimal(18,6), RebateValue Decimal(18,6), UOM Int) 
As
Begin

	Declare @UOM Int	
	Declare @SlabStart Decimal(18,6)
	Declare @SlabEnd Decimal(18,6)
	Declare @Onward Decimal(18,6)
	Declare @Value Decimal(18,6)
	Declare @UnitRate Decimal(18,6)
	Declare @PromotedQty Decimal(18,6)
	Declare @PromotedValue Decimal(18,6)
	Declare @RebateQty Decimal(18,6)
	Declare @RebateValue Decimal(18,6)
	Declare @Quantity Decimal(18,6)

		Declare SlabCur Cursor For
			Select UOM, SlabStart, SlabEnd, Onward, [Value], UnitRate 
				From tbl_mERP_SchemeSlabDetail 
				Where SchemeID = @SchemeID 
				And GroupID = @GroupID
				And SlabType = 5
		Open SlabCur
		Fetch Next From SlabCur Into @UOM, @SlabStart, @SlabEnd, @Onward, @Value, @UnitRate
		While @@Fetch_Status = 0
		Begin

			Set @PromotedValue = 0
			Set @PromotedQty = 0

			If @UOM = 4
			Begin
				If @SaleValue >= @SlabStart And @SaleValue <= @SlabEnd
				Begin
					If @Onward > 0
					Begin
						Set @PromotedValue = Cast(@SaleValue/@Onward as Int) * @Onward
						Set @RebateQty = Cast(@SaleValue/@Onward as Int) * @Value
						Set @RebateValue = @RebateQty * @UnitRate
					End
					Else
					Begin
						Set @PromotedValue = @SaleValue 
						--Set @RebateQty = @SaleValue*@Value
						Set @RebateQty = @Value
						Set @RebateValue = @RebateQty * @UnitRate
					End
					Goto Skip
				End
			End
			Else
			Begin
				Set @Quantity = 0

--				If @Flag = 0
--				Begin
--					If @UOM = 1
--						Set @Quantity = @Qty
--					If @UOM = 2
--						If @UOM1Qty > 0 
--							Set @Quantity = @Qty/@UOM1Qty
--					If @UOM = 3
--						If @UOM2Qty > 0
--							Set @Quantity = @Qty/@UOM2Qty 
--				End		
--				Else
--				Begin

					If @UOM = 1
						Set @Quantity = @Qty
					If @UOM = 2
						If @UOM1Qty > 0
							Set @Quantity = @UOM1Qty
					If @UOM = 3
						If @UOM1Qty > 0
							Set @Quantity = @UOM2Qty	
--				End

				If @Quantity > 0
				Begin
					If @Quantity >= @SlabStart And @Quantity <= @SlabEnd		
					Begin
						If @Onward > 0 
						Begin
							Set @PromotedQty = Cast(@Quantity/@Onward as Int) * @Onward
							Set @RebateQty = Cast(@Quantity/@Onward as Int) * @Value		
						End
						Else
						Begin
							Set @PromotedQty = @Quantity
							--Set @RebateQty = @Quantity * @Value		
							Set @RebateQty =  @Value		
						End
						Set @RebateValue = @RebateQty * @UnitRate		

--						If @Flag = 0
--						Begin		
--							If @UOM = 2
--								Set @PromotedQty = @PromotedQty * @UOM1Conv
--							Else If @UOM = 3
--								Set @PromotedQty = @PromotedQty * @UOM2Conv
--						End 
						Goto Skip
					End
				End
			End		
		Fetch Next From SlabCur Into @UOM, @SlabStart, @SlabEnd, @Onward, @Value, @UnitRate
		End
	Skip:
		Insert Into @SchValue Values(@PromotedQty, @PromotedValue, @RebateQty, @RebateValue, @UOM)
		Close SlabCur
		Deallocate SlabCur
	--Select * From @SchValue
	Return 
End

