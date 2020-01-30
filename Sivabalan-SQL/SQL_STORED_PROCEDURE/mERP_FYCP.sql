CREATE PROCEDURE mERP_FYCP (            
 @szDBName nVarchar(50),             
 @szYearEndDate nVarchar(50),
 @CompanyID nVarchar(15),
 @debugFlag int) AS          
DECLARE @SQL Varchar(8000)           
DECLARE @SqlOtherDB nVarchar(4000)           
DECLARE @DelTableCursor CURSOR            
DECLARE @Table_Name nVarchar(100)           
DECLARE @Del_Where nVarchar(4000)           
DECLARE @Sort_Order int          
DECLARE @Is_Processed int          
DECLARE @IsConstraint int          
DECLARE @PreSql nVarchar(1000)       
DECLARE @PostSql nVarchar(1000)       
DECLARE @Error_Code int          
DECLARE @Stage_Name Varchar(100)          
DECLARE @Procedure_Name Varchar(100)          
DECLARE @Log_Message nVarchar(4000)           
DECLARE @No_of_record_del int          
DECLARE @CurDate datetime        
DECLARE @YearEndDate datetime        

SET NOCOUNT ON          
Set dateformat dmy      

        
Select @CurDate = getdate()        
/*Select @YearEndDate = convert( datetime, @szYearEndDate, 103 )*/      
SELECT @Procedure_Name =  'mERP_FYCP'            
----------------------------------------------------------          
----  Create mERPFYCP_log in ForumMessageClient           ----          
----------------------------------------------------------          
IF Not EXISTS( SELECT * FROM ForumMessageClient.dbo.sysobjects where name = 'mERPFYCP_log')            
begin        
  Select @SqlOtherDB = N'Use ForumMessageClient        
  CREATE TABLE [mERPFYCP_log] (          
   [ID] [int] IDENTITY (1, 1) NOT NULL ,
   [CompanyID] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,          
   [Log_Date] [datetime] NULL CONSTRAINT [DF__Log_Date] DEFAULT (getdate()),          
   [Procedure_name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,          
   [Stage_Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,          
   [Log_Message] [nvarchar] (3800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,          
   [No_of_record_del] [int] NULL           
   CONSTRAINT [PK_mERPFYCP_log] PRIMARY KEY  CLUSTERED           
   (          
    [ID]          
   )  ON [PRIMARY]           
  ) ON [PRIMARY]'          
  EXECUTE sp_executesql @SqlOtherDB        
      
  SELECT @Stage_Name = 'Create mERPFYCP_log...'      
  Select @Log_Message = 'Created mERPFYCP_log in ForumMessageClient', @No_of_record_del = Null      
  IF @debugFlag > 0      
  BEGIN      
   EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del        
  END      
end        
----------------------------------------------------------          
----  Create #del_Table_List                          ----          
----------------------------------------------------------          
IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects where name Like '#del_Table_List')            
DROP TABLE #del_Table_List          
CREATE TABLE [#del_Table_List] (          
 [Table_ID] [int]  NOT NULL ,          
 [Table_Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,          
 [Del_Where] [nvarchar] (3850) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,          
 [Sort_Order] [int] NOT NULL ,          
 [Is_Processed] [int] NOT NULL,      
 [Istruncate] [int] NOT NULL CONSTRAINT [df_del_table_list_Istruncate] DEFAULT (0),      
 [IsConstraint] [int] NOT NULL CONSTRAINT [df_del_table_list_IsConstraint] DEFAULT (0),      
 [PreSql] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,      
 [PostSql] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL      
 )          
        
SELECT @Stage_Name = 'Create #del_Table_List...'           
Select @Log_Message = 'Completed Creation of #del_Table_List', @No_of_record_del = Null        
IF @debugFlag > 0        
BEGIN        
 EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del        
END          
        
----------------------------------------------------------          
----  Populate #del_Table_List                        ----          
----------------------------------------------------------          
SELECT @Stage_Name = 'Populate #del_Table_List...'
SELECT @SQL = 'INSERT INTO #del_Table_List( Table_ID, Table_Name, Del_Where, Sort_Order, Is_Processed, Istruncate, IsConstraint, PreSql, PostSql ) '
SELECT @SQL = @SQL + ' SELECT  dlist.Table_ID  as  Table_ID, ltrim(dlist.Table_Name) as Table_Name, ltrim(dlist.Del_Where) as Del_Where, dlist.Sort_Order as Sort_Order, dlist.Is_Processed as Is_Processed, dlist.Istruncate as Istruncate, dlist.IsConstraint as IsConstraint  , ltrim(dlist.PreSql) as PreSql, ltrim(dlist.PostSql) as PostSql '
SELECT @SQL = @SQL + ' FROM ' + @szDBName + '.dbo.' + 'del_Table_List dlist '
SELECT @SQL = @SQL + ' Inner Join sysobjects obj on dlist.Table_Name = obj.Name where obj.xtype = ''u'' '
IF @debugFlag = 2          
BEGIN          
 SELECT @Log_Message = 'Debug SQL: ' + @SQL          
 EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
END          
EXEC (@SQL)            
SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
IF @Error_Code <> 0        
BEGIN        
 SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL          
 EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del        
 SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
 EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
 EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, '**Stopped**', Null        
 DROP TABLE #del_Table_List
 Return 1      
End        
ELSE        
Begin        
 SELECT @Log_Message = 'Records copied to #del_Table_List from del_Table_List '        
 EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del        
END          
        
----------------------------------------------------------          
----  Delete table data ( no criteria )               ----          
----------------------------------------------------------          
SET @DelTableCursor = CURSOR FOR SELECT Table_Name          
 ,Del_Where          
 ,Sort_Order          
 ,Is_Processed      
 ,PreSql      
 ,PostSql      
FROM #del_Table_List          
WHERE           
--Is_Processed  = 1  AND           
Istruncate = 1      
ORDER BY Sort_Order Asc          
        
OPEN @DelTableCursor          
FETCH NEXT FROM @DelTableCursor INTO @Table_Name, @Del_Where, @Sort_Order, @Is_Processed, @PreSql, @PostSql      
WHILE @@FETCH_STATUS = 0        
BEGIN        
  /*-------- Pre Sql for Delete( no Criteria ) -------------*/      
  If @PreSql != ''       
  begin      
    SELECT @Stage_Name = 'Delete table data ( no criteria )...PreSql'          
    SELECT @SQL = @PreSql      
    IF @debugFlag = 2        
      BEGIN        
      SELECT @Log_Message = 'Debug SQL: ' + @SQL        
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
    END        
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN      
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL          
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1     
    End        
  end      
	If @IsConstraint = 1       
  Begin       
    SELECT @Stage_Name = 'Delete table data ( using criteria )...Disable foreign key constraints'          
    exec mERPFYCP_DisableForeignKeys @Table_Name, 1
    Select @Sql = 'exec mERPFYCP_DisableForeignKeys ' + @Table_Name + ', 1 '
    IF @debugFlag = 2        
    BEGIN          
      SELECT @Log_Message = 'Debug SQL: ' + @SQL
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, null        
    END          
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN            
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL            
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1      
    End
  end    

  /*-------------------  Delete --------------------------*/         
  SELECT @Stage_Name = 'Delete table data ( no criteria )...'           
  --SELECT @SQL = 'Truncate table ' + @szDBName + '.dbo.' + Substring(@Table_Name, 2, 100) + '  '        
  SELECT @SQL = 'Truncate table ' + @Table_Name + '  '        
  IF @debugFlag = 2        
    BEGIN        
    SELECT @Log_Message = 'Debug SQL: ' + @SQL        
    EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
  END        
  EXEC (@SQL)        
  SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
  IF @Error_Code <> 0            
  BEGIN            
    SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL          
    EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
    SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
    EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
    EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, '**Stopped**', Null        
    DROP TABLE #del_Table_List
    Return 1      
  End        
  ELSE        
  Begin        
    --SELECT @Log_Message = 'Records Deleted from the table  ' + Substring(@Table_Name, 2, 100)        
    SELECT @Log_Message = 'Records Deleted from the table  ' + @Table_Name      
    EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del        
  END          
	If @IsConstraint = 1       
  Begin       
    SELECT @Stage_Name = 'Delete table data ( using criteria )...Disable foreign key constraints'          
    exec mERPFYCP_DisableForeignKeys @Table_Name, 0
    Select @Sql = 'exec mERPFYCP_DisableForeignKeys ' + @Table_Name + ', 0 '
    IF @debugFlag = 2        
    BEGIN          
      SELECT @Log_Message = 'Debug SQL: ' + @SQL
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, null        
    END          
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN            
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL            
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null 
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1      
    End
  end  
      
  /*-------- Post Sql for Delete( no Criteria ) ------------*/          
  If @PostSql != ''       
  begin      
    SELECT @Stage_Name = 'Delete table data ( no criteria )...PostSql'          
    SELECT @SQL = @PostSql      
    IF @debugFlag = 2        
      BEGIN        
      SELECT @Log_Message = 'Debug SQL: ' + @SQL        
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
    END        
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN            
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL          
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, @Log_Message, Null        
      EXEC mERPFYCP_Log_Insert @CompanyID, @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1      
    End        
  end      
      
  FETCH NEXT FROM @DelTableCursor INTO @Table_Name, @Del_Where, @Sort_Order, @Is_Processed, @PreSql, @PostSql      
END        
CLOSE @DelTableCursor          
DEALLOCATE @DelTableCursor          
          
----------------------------------------------------------          
----  Delete table data ( using criteria )            ----          
----------------------------------------------------------          
SELECT @Stage_Name = 'Delete table data ( using criteria )...'          
SET @DelTableCursor = CURSOR FOR SELECT Table_Name          
 ,Del_Where          
 ,Sort_Order          
 ,Is_Processed        
 ,IsConstraint      
 ,PreSql      
 ,PostSql      
FROM #del_Table_List          
WHERE           
--Is_Processed  = 1  AND           
IsTruncate != 1      
ORDER BY Sort_Order Asc          
          
OPEN @DelTableCursor          
FETCH NEXT FROM @DelTableCursor INTO @Table_Name, @Del_Where, @Sort_Order, @Is_Processed      
  , @IsConstraint, @PreSql, @PostSql      
WHILE @@FETCH_STATUS = 0            
BEGIN      
      
  /*-------- Run Pre Sql -------------*/      
  If @PreSql != ''       
  begin      
    SELECT @Stage_Name = 'Delete table data ( using criteria )...PreSql'          
    SELECT @SQL = @PreSql      
    IF @debugFlag = 2        
      BEGIN        
      SELECT @Log_Message = 'Debug SQL: ' + @SQL        
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
    END        
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN            
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null      
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1      
    End        
  end      
      
  /*----  Disable all constraints including (foreign key constraint) ----*/          
  If @IsConstraint = 1       
  Begin       
    SELECT @Stage_Name = 'Delete table data ( using criteria )...Disable foreign key constraints'          
    exec mERPFYCP_DisableForeignKeys @Table_Name, 1
    Select @Sql = 'exec mERPFYCP_DisableForeignKeys ' + @Table_Name + ', 1 '
    IF @debugFlag = 2        
    BEGIN          
      SELECT @Log_Message = 'Debug SQL: ' + @SQL
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, null        
    END          
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN            
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL            
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1      
    End
  end      
      
  /*----  delete records  ----*/      
  SELECT @Stage_Name = 'Delete table data (using criteria)...'          
  Select @Del_Where = Replace( @Del_Where, '<DATE>', '''' +  @szYearEndDate + '''')        
  SELECT @SQL = 'Delete from '  + @Del_Where + '   '            
  IF @debugFlag = 2          
  BEGIN          
    SELECT @Log_Message = 'Debug SQL: ' + @SQL          
    EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, null        
  END          
  EXEC (@SQL)        
  SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
  IF @Error_Code <> 0            
  BEGIN            
    SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL            
    EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
    SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
    EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
    EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, '**Stopped**', Null        
    DROP TABLE #del_Table_List
    Return 1      
  End        
  ELSE        
  Begin        
    SELECT @Log_Message = 'Records Deleted from the table  ' + @Table_Name        
    EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del        
  END          
      
  /*----  Enable all constraints including (foreign key constraint)  ----*/      
  If @IsConstraint = 1       
  Begin       
    SELECT @Stage_Name = 'Delete table data ( using criteria )...Enable foreign key constraints'          
    exec mERPFYCP_DisableForeignKeys @Table_Name, 0
    Select @Sql = 'exec mERPFYCP_DisableForeignKeys ' + @Table_Name + ', 0 '
    IF @debugFlag = 2        
    BEGIN          
      SELECT @Log_Message = 'Debug SQL: ' + @SQL
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, null        
    END          
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN            
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL            
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1      
    End
  end      

  /*-------- Run Post Sql -------------*/      
  If @PostSql != ''       
  begin      
    SELECT @Stage_Name = 'Delete table data ( using criteria )...PostSql'          
    SELECT @SQL = @PostSql      
    IF @debugFlag = 2        
      BEGIN        
      SELECT @Log_Message = 'Debug SQL: ' + @SQL        
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
    END        
    EXEC (@SQL)        
    SELECT @Error_Code = @@ERROR, @No_of_record_del = @@ROWCOUNT            
    IF @Error_Code <> 0            
    BEGIN            
      SELECT @Log_Message = '**ERROR** Error Running SQL: ' + @SQL          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      SELECT @Log_Message = '**ERROR** Error Type: ' + Description FROM Master.dbo.sysmessages WHERE Error = @Error_Code          
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, Null        
      EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, '**Stopped**', Null        
      DROP TABLE #del_Table_List
      Return 1      
    End        
  end      
      
  FETCH NEXT FROM @DelTableCursor INTO @Table_Name, @Del_Where, @Sort_Order, @Is_Processed      
    , @IsConstraint, @PreSql, @PostSql      
END            
CLOSE @DelTableCursor          
DEALLOCATE @DelTableCursor          

----------------------------------------------------------          
----  Procedure completed                             ----          
----------------------------------------------------------          
SELECT @Stage_Name = 'Procedure completed...'          
Select @Log_Message = 'Completed Execution of Procedure', @No_of_record_del = Null        
IF @debugFlag > 0          
BEGIN          
 EXEC mERPFYCP_Log_Insert @CompanyID,  @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del        
END          
DROP TABLE #del_Table_List
Return 0      
