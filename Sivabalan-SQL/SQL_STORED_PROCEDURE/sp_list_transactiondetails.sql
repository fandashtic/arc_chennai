create procedure sp_list_transactiondetails (@TransactionType int,@nActive int =0)  
as  
Begin
if @nActive=0 
Begin 
	Select SerialNo,DocumentType,  
	DocumentNumber,"Default Users"=dbo.fn_Get_UserName(SerialNo),Active=IsNull(Active,1) From 	TransactionDocNumber Where TransactionType=@Transactiontype
end 
else
begin  
	Select SerialNo,DocumentType,  
	DocumentNumber,"Default Users"=dbo.fn_Get_UserName(SerialNo),Active=IsNull(Active,1) From 	TransactionDocNumber  
	Where TransactionType=@Transactiontype  And Active=1
end
end
