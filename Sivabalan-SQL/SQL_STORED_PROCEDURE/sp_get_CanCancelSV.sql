CREATE procedure sp_get_CanCancelSV(@SVNumber Int)  
As  
Select Status From SVAbstract   
Where (IsNull(Status,0) & 128) = 0 and (IsNull(Status,0) & 32) = 0  
And SvNumber = @SvNumber  
  
  


