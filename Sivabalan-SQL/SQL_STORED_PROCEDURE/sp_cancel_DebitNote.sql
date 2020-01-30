CREATE Procedure sp_cancel_DebitNote (  @Debit_no as int,     
				        @Cancel_Remark as nvarchar(255),  
					@Cancel_User as nvarchar(100),  
					@Cancel_Date as DateTime)    
as    
DECLARE @Status int    
    
IF NOT EXISTS (Select DebitID From DebitNote Where DebitID = @Debit_no)    
BEGIN    
	SELECT 0    
	GOTO THEEND    
END    

SELECT @Status = Isnull(Status,0) From DebitNote Where DebitID = @Debit_no    

IF @Status = 0    
BEGIN    
	Update DebitNote Set Status = isnull(Status,0) | 64, Balance = 0, Cancel_Memo = @Cancel_Remark,  CancelUser = @Cancel_User, Cancelled_Date = @Cancel_Date Where DebitID = @Debit_no    
	SELECT 1    
END    
ELSE    
	SELECT 0    
THEEND:
