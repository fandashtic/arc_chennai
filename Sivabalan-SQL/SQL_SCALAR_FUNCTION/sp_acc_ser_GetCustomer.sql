CREATE Function sp_acc_ser_GetCustomer(@InvoiceID INT)  
Returns nvarchar(255)  
As  
Begin  
DECLARE @Customer nVarChar(255),@CustomerID nVarChar(50)  
Select @CustomerID=[CustomerID] from ServiceInvoiceAbstract  
Where [ServiceInvoiceID]=@InvoiceID  
  
Select @Customer=Company_Name from Customer Where [CustomerID]=@CustomerID  
  
Return @Customer  
End 
