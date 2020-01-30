CREATE PROCEDURE sp_localize_masters      
AS      
DECLARE @AccountName nvarchar(255)      
DECLARE @ReportName nvarchar(255)      
DECLARE @LocalName nvarchar(255)      
DECLARE @GroupName nvarchar(255)      
      
DECLARE UpdateAccountsMaster CURSOR FOR      
Select DefaultValue, LocalizedValue From MLang..MLangResources Where Type = 'ACCOUNT'      
      
Open UpdateAccountsMaster      
Fetch From UpdateAccountsMaster Into @AccountName, @LocalName      
      
While @@Fetch_Status = 0      
Begin      
 Update AccountsMaster Set AccountName = @LocalName Where AccountName = @AccountName And Fixed = 1      
 Fetch Next From UpdateAccountsMaster Into @AccountName, @LocalName      
End      
close UpdateAccountsMaster      
deallocate UpdateAccountsMaster      
      
DECLARE UpdateAccountsGroup CURSOR FOR      
Select DefaultValue, LocalizedValue From MLang..MLangResources Where Type = 'ACCOUNTGROUP'      
      
Open UpdateAccountsGroup      
Fetch From UpdateAccountsGroup Into @GroupName, @LocalName      
      
While @@Fetch_Status = 0      
Begin      
 Update AccountGroup Set GroupName = @LocalName Where GroupName = @GroupName And Fixed = 1      
 Fetch Next From UpdateAccountsGroup Into @GroupName, @LocalName      
End      
close UpdateAccountsGroup      
deallocate UpdateAccountsGroup      
      
Update FAReportData Set ReportHeader = dbo.LookupDictionaryItem(ReportHeader, 'LABEL') Where Display = 1      
Update QueryParams Set [Values] = dbo.LookupDictionaryItem([Values], 'LABEL')    
Update QueryParams1 Set [Values] = dbo.LookupDictionaryItem([Values], 'LABEL')    
Update QueryParams2 Set [Values] = dbo.LookupDictionaryItem([Values], 'LABEL')    
Update AdjustmentReason Set Reason = dbo.LookupDictionaryItem(Reason, 'LABEL'), [Description] = dbo.LookupDictionaryItem([Description], 'LABEL')  
Update Customer set Company_Name = dbo.LookupDictionaryItem(Company_Name, 'LABEL') Where CustomerID = '0'  

/*
Since the below lines are incorporated for Checvron and Locale ID is not 1033 for ITC in windows 7
If Exists(select localeid from setup where localeid <> 1033)  Delete from shortcuts  
*/
