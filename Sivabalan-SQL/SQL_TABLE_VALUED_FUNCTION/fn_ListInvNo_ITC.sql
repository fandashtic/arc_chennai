
Create Function fn_ListInvNo_ITC(@DocType as nVarchar(50))  
Returns @Invoice Table(InvoiceID Int)  
As  
Begin  

	if @DocType = N'All DocType' or @DocType ='%'  
		Set @DocType ='%'     
	
	Insert Into @Invoice  
	Select InvoiceID From InvoiceAbstract Where 
	DocSerialType like @DocType And IsNull(Status,0) & 192 =0      

Return  
End  

