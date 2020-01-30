CREATE procedure sp_ShrinkDB(@DBName NVARCHAR(500)) as      
Begin            
declare @tablename nvarchar(128)      
declare @columnname nvarchar(128)      
declare @SQL nvarchar(4000)      
declare @identityflag int 
declare @id int 
declare @Cnt int    
declare @processCnt int
declare @tcnt int

Create table #tbltempBF(ID int Identity(1,1), BFRowCnt int, TableName varchar(100) null,AFRowCnt int ) 
Create table #testtemp (ID int Identity(1,1), Name nvarchar(2000))
insert into #testtemp select name  from sysobjects where xtype = 'U' and name not in 
	('dtproperties', 'items', 'setup', 'ReportAbstractReceived', 'ReportDetailReceived', 'Inbound_Log',
	'tblClientMaster', 'tblDocumentDetail', 'tblErrorLog', 'tblInstallationDetail', 'tblInstalledVersions', 
	'tblMessageDetail', 'tblReleaseDetail','tblUpdateDetail' ) order by name
select @Cnt = count(*) from  #testtemp
SET @processCnt = 0
WHILE @processCnt < @Cnt	 
begin
	SET @processCnt = @processCnt + 1
	select @tablename  = Name, @id = [id]  from #testtemp where [id]= @processCnt
	Exec ('Insert into #tbltempBF Select (Select Count(*) from [' + @tablename + ']), ''' + @tablename + ''',0')  
	select @tcnt = BFRowCnt from  #tbltempBF where TableName  = @tablename   
	if @tcnt > 1000
	begin 
	  Begin Transaction	
		set @SQL = 'alter table [' + @tablename + '] nocheck constraint all'      
		exec (@SQL) -- disable all constraints      
		set @SQL = 'select * into tempdb..temptable from [' + @tablename + ']'      
		exec (@SQL) -- copy all data to a temp table 
		set @SQL = 'truncate table [' + @tablename + ']'      
		exec (@SQL) -- truncate all data from original table      
    
		set @SQL = 'select [name]'    
		set @SQL = @SQL + ' from syscolumns '    
		set @SQL = @SQL + ' where id = object_id(''' + @tablename + ''')'    
		set @SQL = @SQL + ' and isnull(Columnproperty([id],[name],''IsIdentity''),0) = 1'    
		exec (@SQL) -- check if table has identity column      
		set @identityflag = @@rowcount     
		if @identityflag = 1      
		begin      
			set @SQL = 'set identity_insert [' + @tablename + '] on' + char(13) + char(10)      
			set @SQL = @SQL + 'insert into [' + @tablename + ']('      
		end      
		else      
		begin      
			set @SQL = 'insert into [' + @tablename + ']('      
		end      

		declare enumcolumns cursor for      
		select name from syscolumns where id = object_id(@tablename)           
		open enumcolumns      
		fetch from enumcolumns into @columnname      
		while @@fetch_status = 0      
		begin      
			set @SQL = @SQL + '[' + @columnname + '], '      
			fetch next from enumcolumns into @columnname      
		end      
		close enumcolumns      
		deallocate enumcolumns      
		set @SQL = substring(@SQL, 1, len(@SQL) - 1) + ')' + char(13) + char(10) + 'select * from tempdb..temptable'      
		if @identityflag = 1      
			begin      
				set @sql = @SQL + char(13) + char(10) + 'set identity_insert [' + @tablename + '] off'      
				exec (@sql) -- copy data and disable identity insert
			end
		else
			begin
				exec (@SQL) -- copy all the data back to original table from temp table
			end

		Exec ('update #tbltempBF set AFRowCnt = (Select Count(*) from [' + @tablename + '] ) where TableName = '''+@tablename  +'''')  		
		if EXISTS( SELECT * FROM #tbltempBF BF where BF.BFRowCnt <> BF.AFRowCnt and BF.TableName = @tablename) 
		begin		
			Rollback transaction		
		end	
		else
		begin			
			commit transaction
		end
		set @SQL = 'alter table [' + @tablename + '] check constraint all'      
		exec (@SQL) -- re-enable constraints  
		if exists (SELECT name from tempdb..sysobjects where name ='temptable') 
		drop table tempdb..temptable    		
	end 
end      
set @SQL = 'Backup log ' + @DBName  + ' with truncate_only'      
exec (@SQL)      
set @SQL = 'dbcc shrinkdatabase(' + @DBName + ')'      
exec (@SQL)   
End            

