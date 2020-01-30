Create Procedure  [dbo].[mERPFYCP_FA_Verification](@SourceDatabase nvarchar(50), @DestinationDatabase nvarchar(50), @szYearEndDate nvarchar(50))      
As      
--Closing balance is calculated on @YearEndDate ( format is dd-mm-yyyy 11:59 PM )  
--Opening balance is calculated on ( @yearenddate + one day ) - format is dd-mm-yyyy 00:00 AM    
  DECLARE @YearEndDate datetime  
  DECLARE @Retval int    
  Declare @Sql as nVarchar(4000)      
  
  SET NOCOUNT ON                
  Set dateformat dmy          
  
  set @YearEndDate = cast( @szYearEndDate as datetime )  
  
  IF EXISTS( SELECT * FROM tempdb.dbo.sysobjects where name like '%fycp_temp%' and xtype = 'U')    
  drop table [#fycp_temp]    
  CREATE TABLE [#fycp_temp] (              
   [accountid] [int] NOT NULL ,              
   [accountname] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,    
   [closingbalance] Decimal(18,6),    
   [OpeningBalance] Decimal(18,6)     
  )     
  Set @Sql = N'DECLARE @ACCOUNTID int' + Char(13) + Char(10)      
  Set @Sql = @Sql + N'DECLARE @LastBalance Decimal(18,6)' + Char(13) + Char(10)      
  Set @Sql = @Sql + N'DECLARE @CurrentBalance Decimal(18,6)' + Char(13) + Char(10)      
  Set @Sql = @Sql + N'DECLARE @OpeningBalance Decimal(18,6)' + Char(13) + Char(10)      
  Set @Sql = @Sql + N'DECLARE @LastTranDate datetime' + Char(13) + Char(10)      
  Set @Sql = @Sql + N'declare @AccountName nvarchar(510)' + Char(13) + Char(10)  
  Set @Sql = @Sql + N'DECLARE @closingbalance Decimal(18,6)' + Char(13) + Char(10)          
  Set @Sql=@Sql + N'DECLARE ScanAccountMaster CURSOR KEYSET FOR' + Char(13) + Char(10)     
-- accountid     accountname  
--22            Opening Stock  
--23            Closing Stock  
--88            Tax on Closing Stock  
--89            Tax on Opening Stock  
/* Accounts openingbalance which is not exist for year end date no need to verify because as per the earlier Openingbalance of Accounts master getting update with first entry of new database which is created after dayclose day the reports displaying as opening*/
  Set @Sql=@Sql+N'Select AccountID, accountname  from ' + @SourceDatabase + N'..AccountsMaster   
      where accountid not in ( 22, 23, 88, 89 ) and accountid in(Select distinct Accountid from ' + @SourceDatabase + N'..accountopeningbalance 
where Openingdate < ''' + Cast(dateadd(day,1,dbo.stripdatefromtime(@YearEndDate)) as nvarchar) + N''') order by accountname ' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'OPEN ScanAccountMaster' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'FETCH FROM ScanAccountMaster INTO @ACCOUNTID, @AccountName' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'While @@FETCH_STATUS=0' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Set @LastBalance =0' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'If Not exists(Select top 1 openingvalue from ' + @SourceDatabase + N'..AccountOpeningBalance     
    where OpeningDate= ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar)+ N'''     
    and AccountID= @AccountID)' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Select @LastTranDate = Max(OpeningDate) From ' + @SourceDatabase + N'..AccountOpeningBalance     
    where AccountID = @AccountID' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'If @LastTranDate Is Not Null' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Select @LastBalance = OpeningValue From ' + @SourceDatabase + N'..AccountOpeningBalance     
    where AccountID = @AccountID And OpeningDate = @LastTranDate' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'End' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Else' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Select @LastBalance = isNull(OpeningBalance,0) from ' + @SourceDatabase + N'..AccountsMaster  
    where AccountId=@AccountID' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Select @LastTranDate = OpeningDate From Setup' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'End' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'End' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Else' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Begin' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Select @LastBalance = OpeningValue From ' + @SourceDatabase + N'..AccountOpeningBalance     
    where OpeningDate= ''' + cast(dbo.stripdatefromtime(@YearEndDate) as nvarchar)+ N'''     
    and AccountID= @AccountID' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Set @LastTranDate = dbo.StripDateFromTime(''' + cast( dbo.stripdatefromtime( @YearEndDate ) as nvarchar ) + N''')'      
  Set @Sql=@Sql+N'End' + Char(13) + Char(10)      
    
  Set @Sql=@Sql+N'Select @CurrentBalance = isnull( sum( Debit - Credit ), 0 ) from ' + @SourceDatabase       
    + N'..GeneralJournal where dbo.stripdatefromtime( TransactionDate ) between @LastTranDate And '''     
    + cast(@YearEndDate as nvarchar) + N''' and AccountID = @AccountID   
 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)   
 and isnull(status,0) <> 128 and isnull(status,0) <> 192 ' + Char(13) + Char(10)    
    
  Set @Sql=@Sql+N'Set @closingbalance = isnull( @LastBalance, 0 ) + isnull( @CurrentBalance, 0 )' + Char(13) + Char(10)      
  Set @Sql = @Sql + N'Insert into #fycp_temp( accountid, accountname, closingbalance, openingbalance )     
    values ( @accountid, @accountname, @closingbalance, null)'    
  Set @Sql=@Sql+N'Set @LastBalance=0' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Set @CurrentBalance=0' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Set @closingbalance=0' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Set @OpeningBalance=0' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'Set @LasttranDate=NULL' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'FETCH NEXT FROM ScanAccountMaster INTO @AccountID, @AccountName' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'End' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'CLOSE ScanAccountMaster' + Char(13) + Char(10)      
  Set @Sql=@Sql+N'DEALLOCATE ScanAccountMaster' + Char(13) + Char(10)      
  --print @sql      
  --get closing balance for all accounts from sourcedb and set in #fycp_temp  
  Exec sp_ExecuteSql @Sql      
  
  Set @Sql = N'update #fycp_temp set OpeningBalance = ( select openingbalance   
    from ' + @DestinationDatabase + '.dbo.accountsmaster acnt where acnt.accountid = #fycp_temp.accountid ) ' + Char(13) + Char(10)      
  --print @sql      
  --get openingbalance for all accounts from destdb and set in #fycp_temp  
  
  Exec sp_ExecuteSql @Sql      
--  select * from #fycp_temp order by accountname  
  
  If exists( Select top 1 * from #fycp_temp   
    where Convert( Decimal(18, 2), isnull( closingbalance, 0 )) != Convert( Decimal(18, 2), isnull( openingbalance, 0 ) ))
    begin   
      Select * from #fycp_temp   
        where Convert( Decimal(18, 2), isnull( closingbalance, 0 )) != Convert( Decimal(18, 2), isnull( openingbalance, 0 ))  
        order by accountname  
      Set @Retval = 1  
    end  
  else  
    Set @Retval = 0  
  IF EXISTS( SELECT * FROM tempdb.dbo.sysobjects where name like '%fycp_temp%' and xtype = 'U')    
  drop table [#fycp_temp]    
  return @Retval  
