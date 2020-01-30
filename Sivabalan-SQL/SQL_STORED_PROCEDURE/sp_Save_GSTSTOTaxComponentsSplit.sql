CREATE Procedure sp_Save_GSTSTOTaxComponentsSplit(@InvoiceID Int)  
As
Begin
	Insert Into STOTaxComponents(STOID,Product_Code,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value)
	Select GST.STOID,GST.Product_Code,GST.Tax_Code,GST.Tax_Component_Code,GST.Tax_Percentage,Sum(isnull(GST.NetTaxAmount,0))
	From GSTSTOTaxComponents GST Inner Join StockTransferOutAbstract IA
		On GST.STOID = IA.DocSerial
	Where GST.STOID = @InvoiceID
	Group By GST.STOID,GST.Product_Code,GST.Tax_Code,GST.Tax_Component_Code,GST.Tax_Percentage
End
