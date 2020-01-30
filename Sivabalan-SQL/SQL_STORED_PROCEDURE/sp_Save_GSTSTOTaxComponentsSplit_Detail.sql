CREATE Procedure sp_Save_GSTSTOTaxComponentsSplit_Detail
	(@InvoiceID Int, @RowNo int, @ProductCode nvarchar(50), @TaxType int, @TaxCode int, @TaxCompSplitup nvarchar(Max))  
As
Begin

	Create Table #tmpTaxComp(TaxComp nVarChar(max))
	Create Table #tmpTaxCompSplitup(RowID int, TC1_TaxComponent_Code Decimal(18,6),TC2_Tax_percentage Decimal(18,6),
			TC3_CS_ComponentCode Decimal(18,6),TC4_ComponentType Decimal(18,6),TC5_ApplicableonComp Decimal(18,6),
			TC6_ApplicableOnCode Decimal(18,6),TC7_ApplicableUOM Decimal(18,6),TC8_PartOff Decimal(18,6),TC9_TaxAmt Decimal(18,6),
			TC10_FirstPoint Decimal(18,6), TC11_STCrFlag Decimal(18,6), TC12_STCrAmt Decimal(18,6), TC13_NetTaxAmt Decimal(18,6))
	
	Insert into #tmpTaxCompSplitup
	Exec sp_SplitIn2Matrix @TaxCompSplitup

	Insert Into GSTSTOTaxComponents(STOID,Product_Code,SerialNo,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value,
			FirstPoint,STCreditFlag,STCreditAmt,NetTaxAmount)
	Select @InvoiceID,@ProductCode,@RowNo,@TaxCode,Cast(TC1_TaxComponent_code as int),TC2_Tax_percentage,TC9_TaxAmt,
			Cast(TC10_FirstPoint as int),Cast(TC11_STCrFlag as int),TC12_STCrAmt,TC13_NetTaxAmt
	From #tmpTaxCompSplitup

	Drop Table #tmpTaxComp
	Drop table #tmpTaxCompSplitup
End
