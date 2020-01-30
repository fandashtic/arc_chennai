Create  PROCEDURE sp_Validate_Adjusted_documents(@CUSTOMER nvarchar(15),@DocType int,  
 @DocID nvarchar(20))      
AS      
declare @DocExist int  
set @DocExist = 0   
if @Doctype = 1   
begin  
 Select @DocExist = count(*) From InvoiceAbstract, VoucherPrefix      
 Where InvoiceType =4 And (Status & 128) = 0 And Balance > 0       
 And CustomerID = @CUSTOMER And TranID = N'INVOICE'    
 and invoiceid = @DocID  
end  
else if @Doctype = 7   
begin  
 Select @DocExist = count(*) From InvoiceAbstract, VoucherPrefix      
 Where InvoiceType in(5,6) And (Status & 128) = 0 And Balance > 0       
 And CustomerID = @CUSTOMER And TranID = N'INVOICE'      
 and invoiceid = @DocID  
end  
else if @Doctype = 2   
begin      
 Select @DocExist = count(*) From CreditNote, VoucherPrefix      
 Where Balance > 0 And CustomerID = @CUSTOMER AND TranID = N'CREDIT NOTE'      
 and CreditID = @DocID  
end  
else if @Doctype = 10
begin      
 Select @DocExist = count(*) From CreditNote, VoucherPrefix      
 Where Balance > 0 And CustomerID = @CUSTOMER AND TranID = N'GIFT VOUCHER'      
 and CreditID = @DocID  
end  
else if @Doctype = 3   
begin  
 select @DocExist = count(*) from Collections      
 where Balance > 0 and  CustomerID = @CUSTOMER And       
 IsNull(Status, 0) & 128 = 0 and DocumentID = @DocID  
end    

select @DocExist   
