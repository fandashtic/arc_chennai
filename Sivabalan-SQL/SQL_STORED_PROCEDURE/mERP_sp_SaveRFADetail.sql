Create Procedure dbo.mERP_sp_SaveRFADetail(
	@RFAID Int,
	@ActCode nVarchar(255),
	@CSSchemeID Int,
	@Desc nVarchar(255),	
	@ActiveFrom DateTime,
	@ActiveTo DateTime,
	@BillRef nVarchar(255),
	@OutletID nVarchar(255),
	@RCSID nVarchar(255),
	@ActiveInRCS nVarchar(10),
	@LineType nVarchar(50),
	@Division nVarchar(255),
	@SubCategory nVarchar(255),
	@MarketSKU nVarchar(255),
	@SystemSKU nVarchar(255),
	@UOM nVarchar(255),
	@SaleQty Decimal(18,6),
	@SaleValue Decimal(18,6),
	@PromotedQty Decimal(18,6),
	@PromotedValue Decimal(18,6),
	@PriceExclTax Decimal(18,6),
	@TaxPercentage Decimal(18,6),
	@TaxAmount Decimal(18,6),
	@PriceInclTax Decimal(18,6),
	@RebateQty Decimal(18,6),
	@RebateValue Decimal(18,6),
	@BudgetedQty Decimal(18,6),
	@BudgetedValue Decimal(18,6),
	@DocNo nVarchar(500) = '',
	@TOQ int = 0,
	@ReasonID Int = 0
	)
As
Begin
	Insert Into tbl_mERP_RFADetail
	(
	RFAID,ActivityCode,CSSchemeID,[Description],ActiveFrom,ActiveTo,BillRef,CustomerID,
	RCSID,ActiveInRCS,LineType,Division,SubCategory,MarketSKU,SystemSKU,UOM,SaleQty,SaleValue,PromotedQty,PromotedValue,
	RebateQty,Rebatevalue,Price_Excl_Tax,Tax_Percentage,Tax_Amount,Price_Incl_Tax,BudgetedQty,BudgetedValue,DocNo,TOQ
	)
	
	Values
	(
	@RFAID, @ActCode, @CSSchemeID, @Desc, @ActiveFrom, @ActiveTo, @BillRef, @OutletID,
	@RCSID, @ActiveInRCS, @LineType, @Division, @SubCategory, @MarketSKU, @SystemSKU, @UOM, @SaleQty, @SaleValue, @PromotedQty, @PromotedValue,
	@PriceExclTax, @TaxPercentage, @TaxAmount, @PriceInclTax, @RebateQty, @RebateValue, @BudgetedQty, @BudgetedValue, @DocNo, @TOQ
	)
	
	If 	(@RFAID > 0) and (@CSSchemeID > 0) and (@ReasonID >0 )
		Insert Into tbl_mERP_RFADet_Reason(RFAID ,CSSchemeID ,RFAReason ) Values(@RFAID,@CSSchemeID,@ReasonID)
		
End
