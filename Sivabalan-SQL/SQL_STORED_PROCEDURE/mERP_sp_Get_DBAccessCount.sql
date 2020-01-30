Create Procedure mERP_sp_Get_DBAccessCount(@DBName as nVarchar(250))  
As  
Begin  
  select Count(loginame)  from master.dbo.sysprocesses     
  where db_name(dbid) = @DBName and  program_name != ''    
End
