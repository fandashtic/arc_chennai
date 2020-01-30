CREATE Function sp_acc_ser_GetCustomerLocality(@InvoiceID INT)    
returns INT    
As    
Begin    
 DECLARE @Locality INT    
    
 Select @Locality=IsNULL(Locality,0) from Customer     
 Where [CustomerID]=(Select [CustomerID] from ServiceInvoiceAbstract    
 Where [ServiceInvoiceID]=@InvoiceID)    
    
 return @Locality    
End
