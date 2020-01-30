CREATE Procedure [dbo].[mERP_sp_Get_StockReconcile_BatchInfo](@StockTakingID Int, @ProductCode nVarchar(50), @BatchCode nVarchar(Max), @DisplayUOM as int)
as
Begin
Declare @DamageStock Int
Select @DamageStock = IsNull(DamageStock,0) From ReconcileAbstract Where ReconcileId = @StockTakingID
Declare @Batch_Count Int
Declare @tBatchCodeInfo table(tBatch_code int, tFlag Int)


/*tmpTable to collect the avail batch Info*/
Insert into @tBatchCodeInfo
Select BP.Batch_code, 1
from Batch_products BP, Items
Where BP.Product_code = Items.Product_code and
Items.Product_Code = @ProductCode and
IsNull(BP.Damage,0) >= (Case @DamageStock When 0 then 0 Else 1 End) and
IsNull(BP.Damage,0) <= (Case @DamageStock When 0 then 0 Else 2 End) and
BP.Batch_Code not in (Select ItemValue from dbo.fn_SplitIn2Rows_Int(@BatchCode,','))
Group By Batch_code
Having Sum(BP.Quantity) > 0
Union
Select ItemValue,0 from dbo.fn_SplitIn2Rows_Int(@BatchCode,',')


/*to find any batch exists with stock*/
Select @Batch_Count = Count(tBatch_Code) From @tBatchCodeInfo where tBatch_Code > 0

If IsNull(@Batch_Count,0) = 0
Begin
Select "Batch_Number" =N'', "PKD" = N'', "Expiry" = N'', ISNull(Items.PTS,0), ISNull(Items.PTR,0), IsNull(Items.ECP,0),
"TaxSuffered" = Tax.Percentage, "TaxID" = Items.TaxSuffered, 0 as 'Quantity', 0 as 'Batch_Code', 0 as 'tFalg', 'LST' as 'TaxType',Items.MRPPerPack
,	1 as 'TaxTypeID'
From Tax, Items
Where Tax.Tax_Code = Items.TaxSuffered and
Items.Product_Code = @ProductCode
End
Else
Begin
Select Batch_Number,
"PKD" = Case IsNull(Convert(nVarchar(10),BP.PKD,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.PKD,103),4,Len(Convert(nVarchar(10),BP.PKD,103))) End,
"Expiry" = Case IsNull(Convert(nVarchar(10),BP.Expiry,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.Expiry,103),4,Len(Convert(nVarchar(10),BP.Expiry,103))) End,
ISNull(BP.PTS,0) PTS, ISNull(BP.PTR,0) PTR, IsNull(BP.ECP,0) ECP, BP.TaxSuffered, BP.GRNTaxID,
Cast((Sum(BP.Quantity) / (Case @DisplayUOM When 1 then IsNull(Items.UOM2_Conversion,1)
When 2 then IsNull(Items.UOM1_Conversion,1)
Else 1 End)) as Decimal (18,6)) 'Quantity', Batch_code, tBatch.tFlag, IsNull(TaxType.TaxType,1) as TaxType,isnull(BP.MRPPerPack,0)
, Case isnull(BP.TaxType,1) When 5 Then isnull(GSTTaxType,1) Else isnull(BP.TaxType,1) End as 'TaxTypeID'
from Batch_products BP, Items, @tBatchCodeInfo tBatch, tbl_merp_TaxType TaxType
Where BP.Product_code = Items.Product_code and
TaxType.TaxID = IsNull(BP.TaxType,1)  and
Items.Product_Code = @ProductCode and
BP.Batch_code = tBatch.tBatch_Code
Group By Batch_Number,
Case IsNull(Convert(nVarchar(10),BP.PKD,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.PKD,103),4,Len(Convert(nVarchar(10),BP.PKD,103))) End,
Case IsNull(Convert(nVarchar(10),BP.Expiry,103),'') When '' Then '' Else SubString(Convert(nVarchar(10),BP.Expiry,103),4,Len(Convert(nVarchar(10),BP.Expiry,103))) End,
ISNull(BP.PTR,0), ISNull(BP.PTS,0), IsNull(BP.ECP,0), BP.TaxSuffered, BP.GRNTaxID, Batch_code , (Case @DisplayUOM When 1 then IsNull(Items.UOM2_Conversion,1)
When 2 then IsNull(Items.UOM1_Conversion,1)
Else 1 End), tBatch.tFlag , IsNull(TaxType.TaxType,1),isnull(BP.MRPPerPack,0),isnull(BP.TaxType,1),isnull(GSTTaxType,1)
Order by BP.Batch_Number, PKD, Expiry, tBatch.tFlag
End
End
