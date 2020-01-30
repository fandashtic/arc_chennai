
Create Procedure mERPFYCP_DBWho( @szDbName as nvarchar(100) ) as
select db_name(dbid) as Dbname, loginame, hostname as ComputerName, program_name 
  from master.dbo.sysprocesses 
  where db_name(dbid) = @szDbName and  program_name != ''
--mERPFYCP_DBWho 'Minerva_KIK059_2006'
