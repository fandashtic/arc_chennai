CREATE procedure sp_update_BillItems(@Bill_ID int, @Product_Code as nvarchar(50), 
				     @Qty Decimal(18,6), 
				     @Price Decimal(18,6), 
				     @Amount Decimal(18,6), 
				     @GRNID int, 
				     @BATCH_CODE int,
				     @TaxSuffered Decimal(18,6), 
				     @TaxAmount Decimal(18,6), 
				     @Taxcode int, 
				     @DisPrice Decimal(18,6),
				     @Discount Decimal(18,6),
				     @Free Decimal(18,6),
				     @Batch nvarchar(255),
				     @Expiry datetime,
				     @PKD datetime,
				     @PTS Decimal(18,6),
				     @PTR Decimal(18,6),
				     @ECP Decimal(18,6),
				     @SpecialPrice Decimal(18,6),
					@Promotion int = 0,
					@BatchCode INT = 0,
					@ExciseDuty Decimal(18,6) = 0,
					@PurchasePriceBeforeExciseAmount Decimal(18,6) = 0,
					@ExciseID Int = 0)
as
DECLARE @CSP_SET int
DECLARE @PURCHASEDAT int
If @Promotion = 1 
Begin
	Select @ECP = ECP From Batch_Products Where Batch_Code In (Select BatchReference From
	Batch_Products Where Product_Code = @Product_Code And GRN_ID = @GRNID And Free = 1 And Batch_Code = @BatchCode)
	Update Batch_Products Set ECP = @ECP, TaxSuffered = @TaxSuffered, 
	Promotion = @Promotion
	Where Product_Code = @Product_Code And GRN_ID = @GRNID And Free = 1 
	And Batch_code = @BatchCode
End
insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice, 
Amount, TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,
SpecialPrice, Promotion, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID)
values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount, 
@TaxCode, @Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @Promotion,
@ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID)

if @Free = 0 
Begin
select @CSP_SET = Price_Option, @PURCHASEDAT = Purchased_At from ItemCategories, Items where
ItemCategories.CategoryID = Items.CategoryID and
Items.Product_Code = @Product_Code

--update Items set Purchase_Price = @Price 
--where Product_Code = @Product_Code

if @CSP_SET = 1 
	begin
	if @PURCHASEDAT = 1 
		begin
--		update Items set PTS = @Price where Product_Code = @Product_Code
		update Batch_Products set PurchasePrice = @DisPrice,
		TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID--, PTS = @Price 
		where Product_Code = @Product_Code and GRN_ID = @GRNID 
		and Batch_Code = @BATCH_CODE and Free = 0
		end
	else if @PURCHASEDAT = 2 
		begin
--		update Items set PTR = @Price where Product_Code = @Product_Code	
		update Batch_Products set PurchasePrice = @DisPrice,
		TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID--, PTR = @Price 
		where Product_Code = @Product_Code and GRN_ID = @GRNID 
		and Batch_Code = @BATCH_CODE and Free = 0
		end
	end
else
	begin
	if @PURCHASEDAT = 1
		begin
--		update Items set PTS = @Price where Product_Code = @Product_Code
		update Batch_Products set PurchasePrice = @DisPrice,
		TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID--, PTS = @Price
		where Product_Code = @Product_Code and GRN_ID = @GRNID and Free = 0
		end
	else if @PURCHASEDAT = 2
		begin
--		update Items set PTR = @Price where Product_Code = @Product_Code	
		update Batch_Products set PurchasePrice = @DisPrice,
		TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID--, PTR = @Price 
		where Product_Code = @Product_Code and GRN_ID = @GRNID and Free = 0
		end
	end
End


