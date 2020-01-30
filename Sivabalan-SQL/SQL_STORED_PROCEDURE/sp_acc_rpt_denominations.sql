CREATE Procedure sp_acc_rpt_denominations
As
Create Table #Temp(Notes nvarchar(15),Numbers decimal(18,6),Amount decimal(18,6),ColorInfo Int)

Insert #Temp
Select 'Notes'=DenominationTitle,'No of Notes'=DenominationCount,
'Amount'= case when DenominationTitle=dbo.LookupDictionaryItem('Coins',Default) then DenominationCount else  cast(DenominationTitle as int)*DenominationCount end,0 from Denominations
Insert #Temp
Select 'Total',0,
sum(case when DenominationTitle=dbo.LookupDictionaryItem('Coins',Default) then DenominationCount else  cast(DenominationTitle as int)*DenominationCount end),1 from Denominations

Select 'Prefix' = Notes,'Count' = Numbers,'Value' = Amount,ColorInfo  from #Temp
Drop Table #Temp







