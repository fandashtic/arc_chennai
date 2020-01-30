CREATE procedure sp_ser_TransactionSerialExist       
 (@TranType int, @DocType Varchar(100), @VoucherPrefix varchar(100))       
as       
Declare @retVal int       
set @retVal = 1      
/*Estimation */      
if @TranType = 100       
begin      
 if exists(select * from EstimationAbstract       
 where Docref = @VoucherPrefix and DocSerialType = @DocType) set @retVal = 0       
end     
Else if @TranType = 101       
begin      
 if exists(select * from JobCardAbstract       
 where Docref = @VoucherPrefix and DocSerialType = @DocType) set @retVal = 0       
end  
Else if @TranType = 102   
begin  
 if exists(select * from IssueAbstract   
 where Docref = @VoucherPrefix and DocSerialType = @DocType) set @retVal = 0   
End 
Else if @TranType = 103   
begin  
 if exists(select * from ServiceInvoiceAbstract   
 where Docreference = @VoucherPrefix and DocSerialType = @DocType) set @retVal = 0   
End 
     
select @retVal 'retval'      



