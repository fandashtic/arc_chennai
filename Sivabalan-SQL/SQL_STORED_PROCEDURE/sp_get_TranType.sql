
Create Procedure sp_get_TranType 
As 
Begin
Declare @Temp1 as varchar(100)
Declare @Temp2 as varchar(100)

Select @Temp1=TDN.DocumentType from TransactionDocNumber TDN,TransactionType TT where TT.TransactionName='INVOICE' and 
TT.TransactionID=TDN.TransactionType

Select @Temp2=TDN.DocumentType from TransactionDocNumber TDN,TransactionType TT where TT.TransactionName='DEBIT NOTE' and 
TT.TransactionID=TDN.TransactionType

Select @Temp1,@Temp2
End
