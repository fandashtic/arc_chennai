CREATE Procedure spr_DandDInvoiceReport_Detail
(
@DInvID INT
)
AS
BEGIN
set dateformat DMY

Declare @DandDID int
Declare @UTGSTFlag int
	
	Select @DandDID = DandDID from DandDInvAbstract where DandDInvID = @DInvID

	Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST' -- UTGST flag
	
	---- TAX
	Select DandDID,Product_code,Batch_Code,Tax_Code,
	SGSTTaxRate = MAX(Case When TCD.TaxComponent_desc = 'SGST' Then DTax.Tax_Percentage Else 0 End),
	SGSTTaxAmount = SUM(Case When TCD.TaxComponent_desc = 'SGST' Then DTax.Tax_Value Else 0 End),
	CGSTTaxRate = MAX(Case When TCD.TaxComponent_desc = 'CGST' Then DTax.Tax_Percentage Else 0 End),
	CGSTTaxAmount = SUM(Case When TCD.TaxComponent_desc = 'CGST' Then DTax.Tax_Value Else 0 End),
	IGSTTaxRate = MAX(Case When TCD.TaxComponent_desc = 'IGST' Then DTax.Tax_Percentage Else 0 End),
	IGSTTaxAmount = SUM(Case When TCD.TaxComponent_desc = 'IGST' Then DTax.Tax_Value Else 0 End),
	CessRate = MAX(Case When TCD.TaxComponent_desc = 'CESS' Then DTax.Tax_Percentage Else 0 End),
	CessAmount = SUM(Case When TCD.TaxComponent_desc = 'CESS' Then DTax.Tax_Value Else 0 End),
	AddlCessRate = MAX(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then DTax.Tax_Percentage Else 0 End),
	AddlCessAmount = SUM(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then DTax.Tax_Value Else 0 End),
	MRPPerPack = 0
	Into #TempDandDTax
	From DandDTaxComponents DTax
	Inner Join TaxComponentDetail TCD ON TCD.TaxComponent_code = DTax.Tax_Component_Code
	Where DTax.DandDID  = @DandDID 
	Group by DandDID,Product_Code,Batch_Code,Tax_Code  --- DandDtaxComponents & TaxComponentdetail (Join)
	
		--- Update MRPPerPack
	Update TDandDTax Set TDandDTax.MRPPerPack = IsNull(BP.MRPPerPack,0) 
	From #TempDandDTax TDandDTax Join Batch_Products BP On BP.Batch_Code = TDandDTax.Batch_Code -- DandDtaxComponents & TaxComponentdetail & Batch_products (Join) 
	--Select * from #TempDandDTax
	
	--- select 
	Select  DD.ID,
	"ItemCode" = DD.Product_code,
	"ItemName" = I.ProductName,
	"MRPPerPAC" = (Case When #TempDandDTax.MRPPerPack = 0 Then I.MRPPerPack Else #TempDandDTax.MRPPerPack End),
	"Quantity" = Case When IsNull(I.UOM2_Conversion,0) = 0 Then 0 Else Sum(Isnull(DD.RFAQuantity,0) / I.UOM2_Conversion) End,
	"UOM" = U.Description,
	--"SalesPrice" = DD.PTS / Case When IsNull(I.UOM2_Conversion,0) = 0 Then 1 Else I.UOM2_Conversion End,
	"SalesPrice" = DD.PTS * IsNull(I.UOM2_Conversion,0),
	"GoodsValue" = SUM(DD.RFAQuantity * DD.PTS) ,
	"SalvageUOM" = U.Description,
	--"SalvageQTY" = Sum(Isnull(DD.SalvageQuantity,0)),
	--"SalvageRate" = DD.SalvageRate,
	"SalvageQTY" = Case When IsNull(I.UOM2_Conversion,0) = 0 Then 0 Else Max(Isnull(DD.SalvageQuantity,0)/ Isnull(I.UOM2_Conversion,0)) End,
	"SalvageRate" = MAX(Isnull(DD.SalvageRate,0) * IsNull(I.UOM2_Conversion,0)),
	"DiscountValue" = Max(ISNULL(DD.SalvageValue,0)),
	"GrossValue" = SUM(DD.RFAQuantity * DD.PTS) - Max(ISNULL(DD.SalvageValue,0)),
	"TotalTaxValue" =Sum(Isnull(DD.TaxAmount,0)),
	"TotalAmount" =SUM(ISNULL(DD.BatchRFAValue,0)),
	"HSNCode" = I.HSNNumber,
	"TaxableValue" = Sum(Isnull(DD.BatchTaxableAmount,0)),
	"CGSTTaxRate" =MAX(#TempDandDTax.CGSTTaxRate),
	"CGSTTaxAmount" = Sum(#TempDandDTax.CGSTTaxAmount) ,
	"SGSTTaxRate" = MAX(#TempDandDTax.SGSTTaxRate),
	"SGSTTaxAmount" =Sum(#TempDandDTax.SGSTTaxAmount) ,
	"IGSTTaxRate" = MAX(#TempDandDTax.IGSTTaxRate),
	"IGSTTaxAmount" = Sum(#TempDandDTax.IGSTTaxAmount),
	"CessRate" = MAX(#TempDandDTax.CessRate),
	"CessAmount" = Sum(#TempDandDTax.CessAmount),
	"AddlCessRate" = MAX(#TempDandDTax.AddlCessRate),
	"AddlCessAmount" = Sum(#TempDandDTax.AddlCessAmount)
		
	Into #TempFinal
	From DandDDetail DD ,Items I,#TempDandDTax,UOM U--,DandDAbstract DA,DandDinvabstract DinvA
	where 
	DD.ID=#TempDandDTax.DandDID
	And DD.Product_code= I.Product_Code
	And DD.Batch_code = #TempDandDTax.Batch_Code
	And I.UOM2 = U.UOM
	--DinA.claimid = DA.claimid
	--And DD.ID = DA.ID
	--And DD.ID = @DInvID
	
	--And DD.RFAQuantity > 0
	Group by
	I.HSNNumber,DD.Product_code,I.ProductName,#TempDandDTax.MRPPerPack,I.MRPPerPack,DD.PTS,DD.SalvageRate,U.Description,DD.id,I.UOM2_Conversion 
	order by ProductName	

	

    --Final o/p

	Select ID, "Item Code" = ItemCode ,"Item Name" = ItemName , "MRP Per PAC" = MRPPerPAC ,"Quantity" = SUM(Quantity),"UOM" = UOM,
	"Sales Price" = SalesPrice ,"Goods Value" = GoodsValue, "Salvage UOM"= SalvageUOM , "Salvage Qty" = SUM(SalvageQTY),"Salvage Rate" =SalvageRate,
	"Discount Value" = SUM(DiscountValue) , "Gross Value" = SUM(GrossValue),"Total Tax Value"  = SUM(TotalTaxValue),"Total Amount" =SUM(TotalAmount),
	"HSNCode"= HSNCode,	"Taxable Value" =SUM(TaxableValue),"CGST Tax Rate" =MAX(CGSTTaxRate),"CGST Tax Amount" =SUM(CGSTTaxAmount),"SGST Tax Rate" = MAX(SGSTTaxRate),
	"SGST Tax Amount" =SUM(SGSTTaxAmount),"IGST Tax Rate" = MAX(IGSTTaxRate) , "IGST Tax Amount" = SUM(IGSTTaxAmount),"Cess Rate" =MAX(CessRate),
	"Cess Amount" = SUM(CessAmount),"AddlCess Rate" =MAX(AddlCessRate),"Addlcess Amount"=SUM(AddlCessAmount)
	From #TempFinal
	Group By ItemCode,ItemName,MRPPerPAC,UOM,SalesPrice,GoodsValue,SalvageUOM,SalvageRate,HSNCode,ID


IF OBJECT_ID('tempdb..#TempDandDTax') IS NOT NULL
		Drop Table #TempDandDTax
IF OBJECT_ID('tempdb..#TempFinal') IS NOT NULL
		Drop Table #TempFinal	

END
