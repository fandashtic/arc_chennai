
Create Procedure [dbo].[sp_Insert_RecdTax] (
					 @CS_TaxCode int,
					 @TaxDescription nvarchar(255),
					 @EffectiveFromDate Datetime,
					 @InterStateApplicableOn int,
					 @InterStatePartOff decimal(18,6),
					 @IntraStateApplicableOn int,
					 @IntraStatePartOff decimal(18,6),
					 @GSTFlag int,
					 @xmlDocNumber int,
					 @Intra_Percentage decimal(18,6),
					 @Inter_Percentage decimal(18,6)
				     )
As
Begin
	Insert Into Recd_Tax (CS_TaxCode,TaxDescription, EffectiveFromDate, InterStateApplicableOn, 
	InterStatePartOff, IntraStateApplicableOn,IntraStatePartOff,GSTFlag,xmlDocNumber,AlertCount,Intra_Percentage,Inter_Percentage) 
	Values (@CS_TaxCode, @TaxDescription, @EffectiveFromDate, 
	@InterStateApplicableOn, @InterStatePartOff, @IntraStateApplicableOn,@IntraStatePartOff,@GSTFlag,@xmlDocNumber,0,@Intra_Percentage,@Inter_Percentage)
	select @@Identity
End
