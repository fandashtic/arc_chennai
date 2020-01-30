Create function mERP_fn_list_PFM_UOMprice(@ITEM_CODE nvarchar(30), @UOM Int = 0, @TaxType Int = 1)
returns @PFMPrices Table(Product_code nVarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, PFM Decimal(18,6))
As
Begin
Insert into @PFMPrices
Select Distinct I.Product_code, 
Cast(Case @UOM When 2 then (Case Isnull(I.UOM1_Conversion,0) When 0 Then 1 Else I.UOM1_Conversion End) * IsNull(BP.PFM,0) 
	When 3 then (Case Isnull(I.UOM2_Conversion,0) When 0 Then 1 Else I.UOM2_Conversion End) * IsNull(BP.PFM,0) 
	Else IsNull(BP.PFM,0) End as Decimal(18,6)) as PFM
From Batch_products BP, Items I 
Where BP.Product_code = @ITEM_CODE 
and IsNull(BP.TaxType,1) = @TaxType
and I.Product_code = BP.Product_Code 
and IsNull(BP.PFM,0) > 0 
Return 
End
