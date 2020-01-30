  
Create Procedure dbo.sp_get_CustomerInvoiceLimit(@Cust nvarchar(150))  
As  
Begin  
Select count(InvoiceID) from InvoiceAbstract ia, Customer Where Customer.Company_Name = @Cust and Customer.CustomerID=ia.CustomerID and IsNull(ia.status,0) & 128 = 0 and IsNull(ia.Balance,0) > 0  and InvoiceType <>4
End  
  
