CREATE Procedure sp_Save_GSTBillTaxComponentsSplit(@BillID Int)  
As
Begin
	IF Exists(Select 'x' From BillTaxComponents Where BillID = @BillID)
		Delete From BillTaxComponents Where BillID = @BillID
	
	Insert Into BillTaxComponents(BillID,Product_Code,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value)
	Select GST.BillID,GST.Product_Code,GST.Tax_Code,GST.Tax_Component_Code,GST.Tax_Percentage,Sum(isnull(GST.Tax_Value,0))
	From GSTBillTaxComponents GST Inner Join BillAbstract BA
		On GST.BillID = BA.BillID
	Where GST.BillID = @BillID
	Group By GST.BillID,GST.Product_Code,GST.Tax_Code,GST.Tax_Component_Code,GST.Tax_Percentage
End
