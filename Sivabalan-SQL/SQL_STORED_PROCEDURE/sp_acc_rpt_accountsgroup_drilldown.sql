CREATE procedure sp_acc_rpt_accountsgroup_drilldown (@groupid int)
as  

set dateformat dmy  

Select 'Account' = AccountName,
'Opening Balance' = Case When (Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) > 0 Then dbo.LookupDictionaryItem('Dr',Default) + Cast(Abs(Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) as nvarchar(100)) Else Case When (Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) = 0 Then '0' Else dbo.LookupDictionaryItem('Cr',Default) + Cast(Abs(Case When AccountID = 22 or AccountID = 89 Then dbo.sp_acc_computestockbalancefn(AccountID)  
Else IsNull(OpeningBalance,0) End) as nvarchar(100))End End,  
'Closing Balance' =   
Case When (Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End) > 0 Then dbo.LookupDictionaryItem('Dr',Default) + Cast(Abs(Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End) as nvarchar(100)) Else Case When  
(Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End)= 0 Then '0' Else dbo.LookupDictionaryItem('Cr',Default) + Cast(Abs(Case When AccountID = 23 or AccountID = 88 Then dbo.sp_acc_computestockbalancefn(AccountID)   
Else dbo.sp_acc_getaccountbalance(AccountID,dbo.Sp_Acc_GetOperatingDate(getdate())) End) as nvarchar(100)) End End,    
'Status' = Case When IsNull(Active,0) = 1 Then dbo.LookupDictionaryItem('Active',Default) Else dbo.LookupDictionaryItem('In Active',Default) End,  
'Type'= Case When IsNull(Fixed,0)=1 Then dbo.LookupDictionaryItem('Fixed',Default) Else dbo.LookupDictionaryItem('User Defined',Default) End    ,5
From AccountsMaster Where AccountID <> 500 
and groupid = @groupid
Order By AccountName  



