CREATE procedure sp_acc_rpt_accountgroup
as
Select  'Account Group' = GroupName,'Account Type'= 
Case When AccountType = 1 Then dbo.LookupDictionaryItem('Asset',Default)
When AccountType = 2 Then dbo.LookupDictionaryItem('Liability',Default)
When AccountType = 3 Then dbo.LookupDictionaryItem('Equity',Default)
When AccountType = 4 Then dbo.LookupDictionaryItem('Direct Income',Default)
When AccountType = 5 Then dbo.LookupDictionaryItem('Income Indirect',Default)
When AccountType = 6 Then dbo.LookupDictionaryItem('Expenditure Direct',Default)
When AccountType = 7 Then dbo.LookupDictionaryItem('Expenditure Indirect',Default)
End,
'Parent Group' = dbo.sp_acc_rpt_getgroupname(IsNull(ParentGroup,0)),
'Status'= 	Case When IsNull(Active,0)=1 then dbo.LookupDictionaryItem('Active',Default) 	Else dbo.LookupDictionaryItem('In Active',Default) End,
'Type'= 	case when IsNull(Fixed,0)= 1 Then dbo.LookupDictionaryItem('Fixed',Default) 	Else dbo.LookupDictionaryItem('User Defined',Default) End,
groupid,'64'
From AccountGroup Where GroupID <> 500
Order By GroupName

