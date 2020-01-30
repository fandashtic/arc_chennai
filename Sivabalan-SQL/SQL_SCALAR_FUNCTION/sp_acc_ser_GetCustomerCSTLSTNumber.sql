CREATE function sp_acc_ser_GetCustomerCSTLSTNumber(@InvoiceID integer,@CSTorLST integer)      
returns nvarchar(50)      
As      
Begin      
 DECLARE @CustomerID nvarchar(15)      
 DECLARE @CST nvarchar(50),@LST nvarchar(50)      
 DECLARE @TIN nvarchar(20)  
 DECLARE @ReturnCSTorLST nvarchar(50)      
      
 Select @CustomerID=[CustomerID] from ServiceInvoiceAbstract Where [ServiceInvoiceID]= @InvoiceID      
      
 Set @CST = N''      
 Set @LST = N''      
      
 Select @LST = IsNULL(TNGST,N''),@CST = IsNULL(CST,N''),@TIN = IsNULL(TIN_Number,N'') from Customer      
 Where [CustomerID]=@CustomerID         
    
 If @CSTorLST = 1     
  Begin    
   Set @ReturnCSTorLST = @LST    
  End    
 Else If @CSTorLST = 2    
  Begin    
   Set @ReturnCSTorLST = @CST    
  End    
 Else If @CSTorLST = 3  
  Begin    
   Set @ReturnCSTorLST = @TIN  
  End    
 Return @ReturnCSTorLST      
End 
