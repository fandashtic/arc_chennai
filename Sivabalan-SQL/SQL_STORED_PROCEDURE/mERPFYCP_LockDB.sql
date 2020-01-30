--------------------------------------------------- mERPLockDB --------------------------------------------------------
CREATE Procedure mERPFYCP_LockDB( @szDbName as nvarchar(100) ) as    
Declare @Sql Varchar(200)    
begin  
  Select @Sql = 'Alter Database ' + @szDbName + ' Set Single_User With No_Wait'    
  Exec (@Sql)    
  if @@Error <> 0     
  begin    
    select 1  
  end  
  else  
  begin  
    select 0  
  end    
end    
--mERP_LockDB 'Minerva_KIK059_2007'


