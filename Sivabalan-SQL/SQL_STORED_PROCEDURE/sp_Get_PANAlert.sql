CREATE PROCEDURE sp_Get_PANAlert(@INVOICEID INT)    
AS  
Begin
	IF Exists(Select 'x' from tbl_merp_ConfigAbstract Where ScreenCode = 'PANALERT' and IsNull(Flag,0) = 1)
	 BEGIN		
		IF Exists(
			Select 'x' 
			From InvoiceAbstract IA 
			Join Customer C On IA.CustomerID = C.CustomerID And IsNull(C.PANNumber,'') = ''
			Where IA.InvoiceID = @INVOICEID 
			And IA.NetValue >= (Select  IsNull(Value, 0) From tblConfigPAN Where ScreenCode = 'PRINTPAN')
					)
		 Begin
			--Select 'PAN of the Customer does not exist. Please input the same in Customer Master.'
			Select 'PAN of the outlet is not available, Please input the same in customer master.'
		 End
		Else
		 Begin
			Select ''
		 End
	 End
	Else
	 Begin
		Select ''	
	 End
End
