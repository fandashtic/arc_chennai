CREATE procedure sp_acc_rpt_accounts  
as  
Declare @GroupID Int  
Declare @GroupName nvarchar(255)  
  
set dateformat dmy  

Create Table #tempgroup(AccountID int,AccountName nvarchar(50),Status integer)  
   
Insert into #tempgroup select GroupID,GroupName,1 From AccountGroup  
Where ParentGroup = 13  
  
Declare Parent Cursor Dynamic For  
Select AccountID,AccountName From #tempgroup where status=1  
Open Parent  
  
Fetch From Parent Into @GroupID,@GroupName  
While @@Fetch_Status = 0  
Begin  
 Insert into #tempgroup   
 Select GroupID,GroupName,1 From AccountGroup  
 Where ParentGroup = @GroupID  
   
 Insert into #tempgroup   
 Select AccountID,AccountName,2 From AccountsMaster  
 Where GroupID = @GroupID   
  
Fetch Next From Parent Into @GroupID,@GroupName   
End  
Close Parent  
DeAllocate Parent  
Insert into #tempgroup  
select AccountID,AccountName,2 From AccountsMaster   
Where GroupID = 13  
  
Select 'Account' = AccountName,'Account Group' = (Select GroupName from AccountGroup Where GroupID = AccountsMaster.GroupID),  
'Opening Balance' = Case When (Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) > 0 Then dbo.LookupDictionaryItem('Dr',Default) + Cast(Abs(Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) as nvarchar(100)) Else Case When (Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) = 0 Then '' Else dbo.LookupDictionaryItem('Cr',Default) + Cast(Abs(Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) as nvarchar(100))End End,  
'Closing Balance' =   
Case When (Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End) > 0 Then dbo.LookupDictionaryItem('Dr',Default) + Cast(Abs(Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End) as nvarchar(100)) Else Case When  
(Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End)= 0 Then '' Else dbo.LookupDictionaryItem('Cr',Default) + Cast(Abs(Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End) as nvarchar(100)) End End,    
'Status' = Case When IsNull(Active,0) = 1 Then dbo.LookupDictionaryItem('Active',Default) Else dbo.LookupDictionaryItem('In Active',Default) End,  
'Type'= Case When IsNull(Fixed,0)=1 Then dbo.LookupDictionaryItem('Fixed',Default) Else '' End    
--'ColorInfo' =IsNull(Fixed,0)  
From AccountsMaster Where AccountID <> 500 and AccountID Not in (Select AccountID from #tempgroup where Status=2)  
Order By AccountName  
Drop table #tempgroup 

