CREATE function sp_acc_getVendorCSTLSTNumber  
(@billid INTEGER,@CSTorLST integer)    
returns nvarchar(50)    
as    
begin    
DECLARE @vendor nvarchar(30)    
declare @ReturnCSTorLST nvarchar(50)      

-- -- select * from vendors  
-- -- select * from BillAbstract  
-- -- select * from AdjustmentReturnAbstract  
  
select @vendor = vendorid from billabstract where   
billid = @BILLID
  
If @CSTorLST = 1  
 Begin    
  select @ReturnCSTorLST = isnull(tngst,N'') from vendors  
  where vendorid = @vendor   
 End    
Else If @CSTorLST  = 2  
 Begin    
  select @ReturnCSTorLST = isnull(cst,N'') from vendors  
  where vendorid = @vendor   
 End    
Else If @CSTorLST  = 3  
 Begin    
  select @ReturnCSTorLST = isnull(TIN_number,N'') from vendors  
  where vendorid = @vendor   
 End    
  
return @ReturnCSTorLST  
  
end   
  



