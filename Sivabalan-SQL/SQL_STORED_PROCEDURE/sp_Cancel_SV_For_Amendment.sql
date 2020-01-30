CREATE Procedure sp_Cancel_SV_For_Amendment (@SvNumber integer)      
As      
Update SVAbstract Set Status= (Status | 32) where SvNumber=@SvNumber      
Update SOAbstract Set Status= (Status | 192) where SalesVisitNumber=@SvNumber      
  


