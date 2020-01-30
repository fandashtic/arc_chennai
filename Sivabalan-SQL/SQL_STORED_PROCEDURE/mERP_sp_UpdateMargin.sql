Create Procedure mERP_sp_UpdateMargin(@SKUCode nVarchar(30),@Margin Decimal(18,6),@EffectiveDate as Datetime)
As
Begin
	
	
	/* Insert the records Going to get affected in the log first */
	Insert Into tbl_mERP_Margin_Log(BatchCode,ItemCode,OrgPTS,OrgPTR,OrgTaxSuff,MargnPercnt,MarginPTR,EffectiveDate)
	Select 
		Batch_Code,Product_Code,PTS,PTR,isNull(TaxSuffered,0) 'TaxSuffered',@Margin,
		Cast((PTS + (PTS + (PTS * isNull(TaxSuffered,0)/100)) * @Margin /100 ) as Decimal(18,6)) 'MarginPTR',
		@EffectiveDate
	From 
		Batch_Products 
	Where 
		isNull(PTS,0) <> 0 And
		Product_Code = @SKUCode

	/*Update the MarginCalculatedPTR */
	
	Update 
		Batch_Products 
	Set	
		PTR = Cast((PTS + (PTS + (PTS * isNull(TaxSuffered,0)/100)) * @Margin/100 ) as Decimal(18,6))
	Where 
		isNull(PTS,0) <> 0 And
		Product_Code = @SKUCode


	/* Return 1 on successful Updation */
	Select 1
	
End
