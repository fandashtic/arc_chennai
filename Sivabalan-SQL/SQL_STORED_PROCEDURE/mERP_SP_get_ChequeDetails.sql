Create Procedure mERP_SP_get_ChequeDetails @CusID nvarchar(255)    
AS    
BEGIN 
Select Count(isnull(C.ChequeNumber,0)) as ChequeNumber, isnull(sum(isnull(C.Value,0)),0) as Value from Collections C 
Where C.CustomerID=@CusID and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and isnull(realised,0) not in(1,2,3) 
END 
