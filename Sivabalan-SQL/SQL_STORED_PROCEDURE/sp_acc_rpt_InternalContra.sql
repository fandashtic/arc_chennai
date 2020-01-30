CREATE procedure sp_acc_rpt_InternalContra
(@Fromdate Datetime,@Todate Datetime,@Active Int = 0)
as
/*  
	For Active documents   
	0 & 192 = 0   
	For all documents   
	0 & 0  
	192 & 0  
*/  

Declare @prefix as nvarchar(20)  
  
select @prefix = Prefix  
from VoucherPrefix  
where TranID = N'INTERNALCONTRA'  

select 
'Document ID' = @prefix + cast(DocumentID as nvarchar(20)),  
ContraDate as 'Document Date',FromUser as 'From User',
ToUser as 'To User',
case 
	When isnull(Status,0) = 192  Then dbo.LookupDictionaryItem('Cancelled',Default)
	Else dbo.LookupDictionaryItem('Active',Default)
End as 'Status',ContraID,Remarks as 'Narration',67 as 'Display'
from ContraAbstract 
where dbo.stripdatefromtime(ContraDate) between @fromdate and @todate 
and  
Isnull(Status,0) & 
			(Case When @Active = 1 then 192 else 0 End) = 0







