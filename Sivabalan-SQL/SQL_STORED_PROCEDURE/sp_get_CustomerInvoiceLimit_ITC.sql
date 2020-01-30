
Create Procedure dbo.sp_get_CustomerInvoiceLimit_ITC(@Cust nvarchar(150), @Group int)  
As  
Begin  
	Select Count(InvoiceID) From InvoiceAbstract, CustomerCreditLimit  
	Where CustomerCreditLimit.CustomerID = InvoiceAbstract.CustomerID  
	And CustomerCreditLimit.GroupID = InvoiceAbstract.GroupID  
	And CustomerCreditLimit.CustomerID = @Cust
	And CustomerCreditLimit.GroupID = @Group
	And IsNull(InvoiceAbstract.Status,0) & 128 =0   
	And IsNull(InvoiceAbstract.Balance,0)>0  
	And Invoicetype <> 4  
End  

