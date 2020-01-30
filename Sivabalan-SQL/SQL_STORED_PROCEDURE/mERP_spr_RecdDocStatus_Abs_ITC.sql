Create Procedure mERP_spr_RecdDocStatus_Abs_ITC
(@FromDate Datetime,
 @ToDate Datetime)
as
Begin 
create table #temp(id int,trantype nvarchar(500))
insert into #temp(id,trantype)
select id,
'Transaction Type'=
case TransactionType 
when 'CHL001' THEN 'Channel'
when 'CGD001' THEN 'CategoryGroupDefinition'
when 'CHC001' THEN 'CategoryHandlerConfig'
when 'CTG01' THEN 'Add New Category'
when 'CTG02' THEN 'Modify Category'
when 'CTG03' THEN 'Import Category Add'
when 'CTG04' THEN 'Import Category Modify'
when 'ITM01' THEN 'Add New Item'
when 'ITM02' THEN 'Add Item Variant'
when 'ITM03' THEN 'Modify Item'
when 'ITM04' THEN 'Import Item Add'
when 'ITM05' THEN 'Import Item Modify'
when 'CST01' THEN 'Add New Customer'
when 'CST02' THEN 'Modify Customer'
when 'CST03' THEN 'Import Customer Add'
when 'CST04' THEN 'Import Customer Modify'
when 'CST05' THEN 'Import Customer TMD Add'
when 'CST06' THEN 'Import Customer TMD Modify' 
else 
TransactionType
end 
from tbl_mERP_RecdErrMessages where processdate Between @FromDate And @ToDate
And transactiontype not in ('WDSKUList','SKU Portfolio')
select  distinct trantype, trantype as 'Transaction Type' from #temp
End
