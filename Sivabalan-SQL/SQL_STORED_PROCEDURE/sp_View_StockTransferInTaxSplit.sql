Create Procedure sp_View_StockTransferInTaxSplit(@DocSerial int,@Serial int)        
As 
Begin
--Exec sp_View_StockTransferInTaxSplit 1,1
	Declare @TaxSplitup nVarChar(Max)
	Set @TaxSplitup = ''
	
	Select @TaxSplitup = @TaxSplitup +  Case When IsNull(@TaxSplitup,'') = '' Then '' Else '|' End +
									Cast(Tax_Component_Code As nVarChar) + ';' +  Cast(Tax_Percentage As nVarChar)
									+ ';0;0;0;0;0;0;' + Cast(Tax_Percentage As nVarChar) + ';0;0;0;' + Cast(Tax_Value As nVarChar)  
	From GSTSTITaxComponents Where STIID = @DocSerial And SerialNo = @Serial
	
	Select TaxSplitup = @TaxSplitup

End
