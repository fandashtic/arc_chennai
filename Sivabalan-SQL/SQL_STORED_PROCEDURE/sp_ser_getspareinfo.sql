CREATE procedure [dbo].[sp_ser_getspareinfo](@EstimationID int,@ProductCode nvarchar(15),
@JobID nvarchar(50),@TaskID nvarchar(50),@Mode Int,@ItemSpec1 nvarchar(50), 
@SpareCode nVarchar(30) = '')
as
If @Mode = 1
Begin
	Select SpareCode,'SpareName' = dbo.sp_ser_getitemname(EstimationDetail.SpareCode),
	'SalePrice' = Price,'UOMDescription' = UOM.[Description],SalesTax,
	'SalesTaxPayable' = Case When IsNull(LSTPayable,0)= 0 Then IsNull(CSTPayable,0)
	Else IsNull(LSTPayable,0) End,TaxSuffered_Percentage,TaxSuffered,EstimationDetail.UOM,
	EstimationDetail.Quantity,EstimationDetail.UOMPrice,Amount,NetValue,UOMQty
	from EstimationDetail,UOM Where EstimationDetail.EstimationID = @EstimationID
 	and Product_Code = @ProductCode and Product_Specification1 = @ItemSpec1
	and IsNull(JobID, '') = @JobID and IsNull(TaskID, '') = @TaskID	and 
	IsNUll(SpareCode, '') <> '' and EstimationDetail.UOM *= UOM.UOM
End
Else If @Mode = 2
Begin
	Select SpareCode,'SpareName' = dbo.sp_ser_getitemname(EstimationDetail.SpareCode),
	'SalePrice' = Price,'UOMDescription' = UOM.[Description],SalesTax,
	'SalesTaxPayable' = Case When IsNull(LSTPayable,0)= 0 Then IsNull(CSTPayable,0)
	Else IsNull(LSTPayable,0) End,TaxSuffered_Percentage,TaxSuffered,EstimationDetail.UOM,
	EstimationDetail.Quantity,EstimationDetail.UOMPrice,Amount,NetValue,UOMQty
	from EstimationDetail,UOM
	Where EstimationDetail.EstimationID = @EstimationID and Product_Code = @ProductCode
	and Product_Specification1 = @ItemSpec1	and IsNull(TaskID, '') = @TaskID and 
	Isnull(JobID, '') = '' and IsNUll(SpareCode, '') <> '' and EstimationDetail.UOM *= UOM.UOM
End
Else If @Mode = 3
Begin
	Select SpareCode, 'SpareName' = dbo.sp_ser_getitemname(EstimationDetail.SpareCode),
	'SalePrice' = Price,'UOMDescription' = UOM.[Description],SalesTax,
	'SalesTaxPayable' = Case When IsNull(LSTPayable,0)= 0 Then IsNull(CSTPayable,0)
	Else IsNull(LSTPayable,0) End,TaxSuffered_Percentage,TaxSuffered,EstimationDetail.UOM,
	EstimationDetail.Quantity,EstimationDetail.UOMPrice,Amount,NetValue,UOMQty
	from EstimationDetail,UOM where EstimationDetail.EstimationID = @EstimationID and 
	Product_Code = @ProductCode and Product_Specification1 = @ItemSpec1 
	and IsNull(TaskID, '') ='' and IsNUll(JobID, '') = '' and 
	IsNull(SpareCode, '') = @SpareCode and EstimationDetail.UOM *= UOM.UOM
End
