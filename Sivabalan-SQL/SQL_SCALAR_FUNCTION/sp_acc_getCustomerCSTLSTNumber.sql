CREATE function sp_acc_getCustomerCSTLSTNumber(@invoiceid integer,@CSTorLST integer)    
returns nvarchar(50)    
as    
begin    

declare @cusid nvarchar(15)    
declare @CST nvarchar(50),@LST nvarchar(50)    
Declare @TIN nvarchar(20)
declare @ReturnCSTorLST nvarchar(50)    
    
select @cusid = [CustomerID] from InvoiceAbstract    
where [InvoiceID]= @invoiceid    
    
set @cst = N''    
set @lst = N''    
    
select @lst = isnull(tngst,N''),@cst = isnull(cst,N''),@TIN = isnull(TIN_Number,N'') from Customer    
where [CustomerID]=@cusid       
  
if @CSTorLST = 1   
 begin  
  set @ReturnCSTorLST = @lst  
 end  
else if @CSTorLST = 2  
 begin  
  set @ReturnCSTorLST = @cst  
 end  
else if @CSTorLST = 3
 begin  
  set @ReturnCSTorLST = @TIN
 end  

    
    
return @ReturnCSTorLST    
    
end    
  



