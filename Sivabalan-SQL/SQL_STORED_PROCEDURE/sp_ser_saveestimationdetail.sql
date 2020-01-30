CREATE procedure sp_ser_saveestimationdetail(@EstimationID Int,
	@ProductCode nvarchar(15), @Type Int, @JobID nvarchar(50), @TaskID nvarchar(50),
	@SpareCode nvarchar(15), @Price Decimal(18,6), @Quantity Decimal(18,6),
	@SalesTaxAmount Decimal(18,6), @SalesTax Decimal(18,6),
	@TaxSuffered_Percentage Decimal(18,6), @TaxSuffered Decimal(18,6),
	@UOM Int, @UOMQty Decimal(18,6), @UOMPrice Decimal(18,6), @ServiceTaxPercentage Decimal(18,6),
	@ServiceTax Decimal(18,6), @DeliveryDate DateTime, @DeliveryTime DateTime, @CustomerID nvarchar(50),
	@Amount Decimal(18,6), @NetValue Decimal(18,6), @ItemSpec1 nvarchar(50), @TaskDuration nvarchar(15), 
	@IsDirJobCard int = 0)
as
Declare @CSTPayable Decimal(18,6)
Declare @LSTPayable Decimal(18,6)
Declare @Locality Int
Declare @VatExists Int
Declare @CollectTaxSuffered Int
Declare @retval int 
If IsNull(@TaskID, '') <> '' and IsNull(@SpareCode, '') = '' 
begin
	Select @TaskDuration = TaskDuration from Task_Items 
	where Task_Items.TaskID = @TaskID and Task_Items.Product_Code = @ProductCode
end  

Set @LSTPayable = 0
Set @CSTPayable = 0

Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID
If @Locality = 1 
Begin
	Set @LSTPayable = @SalesTaxAmount
End
Else If @Locality = 2
Begin
	Set @CSTPayable = @SalesTaxAmount
End
If Isnull(@SpareCode, '') <> ''
begin
	Select @VatExists = Isnull(Vat, 0), 
	@CollectTaxSuffered = (Case When Isnull(Vat, 0) = 1 then 0 else 	Isnull(CollectTaxSuffered, 0) end) 
	from items Where Product_Code = @SpareCode
	if ((Isnull(@VatExists, 0) <> 0 or Isnull(@CollectTaxSuffered, 0) = 0) and @IsDirJobCard <> 0)
	begin 
		set @TaxSuffered_Percentage = 0
		set @TaxSuffered = 0
	end 
end

Insert EstimationDetail(EstimationID,Product_Code,Product_Specification1,Type,JobID,TaskID,
SpareCode,Price,Quantity,LSTPayable,CSTPayable,SalesTax,TaxSuffered_Percentage,
TaxSuffered,UOM,UOMQty,UOMPrice,ServiceTax_Percentage,ServiceTax,DeliveryDate,
DeliveryTime,Amount,NetValue,TaskDuration, Vat_Exists, CollectTaxSuffered_Spares)
Values(@EstimationID,@ProductCode,@ItemSpec1,@Type,@JobID,@TaskID,@SpareCode,@Price,
@Quantity,@LSTPayable,@CSTPayable,@SalesTax,@TaxSuffered_Percentage,@TaxSuffered,
@UOM,@UOMQty,@UOMPrice,@ServiceTaxPercentage,@ServiceTax,@DeliveryDate,@DeliveryTime,
@Amount,@NetValue,@TaskDuration, @VatExists, @CollectTaxSuffered)
set @retval = @@identity

select @retval 



