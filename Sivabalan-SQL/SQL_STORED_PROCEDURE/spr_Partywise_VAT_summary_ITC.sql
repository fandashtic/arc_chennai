CREATE PROCEDURE spr_Partywise_VAT_summary_ITC (@fromdate datetime, @todate datetime, @yn nvarchar(5))
AS  
Begin
DECLARE @strsql  nVARCHAR(max) 	
DECLARE @strsql1 nVARCHAR(max)
DECLARE @strsqlUnion nVARCHAR(max)
DECLARE @ExecQry nVARCHAR(max)
DECLARE @ExecQry1 nVARCHAR(max)
DECLARE @ExecQry2 nVARCHAR(max)
DECLARE @ExecQry3 nVARCHAR(max)
DECLARE @ExecQry4 nVARCHAR(max)
DECLARE @strsql2 nVARCHAR(max)
DECLARE @strsql3 nVARCHAR(max)
DECLARE @strsql4 nVARCHAR(max)
DECLARE @Columns nVARCHAR(max)
DECLARE @InvoiceType INT
declare @temp datetime 
DECLARE @percentageid nVarchar(255)

Set DATEFormat DMY
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
if(@FROMDATE > @temp )
begin
	select 0,'This report cannot be generated for GST period' as Reason
	goto GSTOut
end               
                 
if(@TODATE > @temp )
begin
	set @TODATE  = @temp 
	--goto GSTOut
end                 

if @yn = N'Yes'
Begin
-------
Declare @Tax_ids as Integer
Declare @Com_flag as integer
declare @Lst_flag as integer
-------
---------------------------------------------------------------------
-- Dynamic columns generation
---------------------------------------------------------------------
Declare @TRC As Integer
Declare @taxid as integer
declare @oldid as integer
declare @newid as integer
declare @maxid as integer
declare @flag as integer
declare @taxcomdesc as nvarchar(255)
declare @taxcomid as integer
declare @flagid as integer
declare @lstflag as integer
declare @ParentId as integer
set @oldid = 0
set @newid = 0
set @flag = 0
set @taxcomdesc = N''

create table #taxdesc(staxid integer IDENTITY(1, 1), 
tax_desc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
tax_id integer, flag integer, LstFlag integer, ParentId integer)

-- create table #taxdesc(staxid integer IDENTITY(1, 1), 
-- tax_desc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
-- Select Distinct [tax_id] = t.tax_code, 
-- 
-- [tax_desc] = case when isnull(ids.taxid, 0) != 0 then 
-- case when isnull(ids.taxcode, 0) > 0 then N'LST' 
-- when isnull(ids.taxcode2, 0) > 0 then N'CST' else N'' end end + N' ' + 
-- t.Tax_Description, 
-- 
-- [col3] = tc.taxcomponent_code, 
-- 
-- [col4] = case when isnull(ids.taxid, 0) != 0 then 
-- case when isnull(ids.taxcode, 0) > 0 then N'LST' 
-- when isnull(ids.taxcode2, 0) > 0 then N'CST' else N'' end end + N' ' + 
-- tcd.taxcomponent_desc + N'_Of_' + t.Tax_Description,
-- 
-- [lstflag] = 
-- case when isnull(ids.taxid, 0) != 0 then 
-- case when isnull(ids.taxcode, 0) > 0 then 1
-- when isnull(ids.taxcode2, 0) > 0 then 2 else 0 end end 
-- into #innertemp
-- From Tax t, taxcomponents tc, taxcomponentdetail tcd,
-- InvoiceAbstract ia, InvoiceDetail ids
-- Where t.tax_code = tc.tax_code and tc.taxcomponent_code = tcd.taxcomponent_code and
-- ia.invoiceid = ids.invoiceid and ids.taxid = t.tax_code and
-- (ids.TaxCode + ids.TaxCode2) > 0 and 
-- (ia.Status & 128) = 0

--drop table #innertemp
--select * from #innertemp

--------------------------------
Select Distinct [tax_id] = t.tax_code, 
[tax_desc] = case when isnull(tc.lst_flag, 0) = 1 then N'LST' 
when isnull(tc.lst_flag, 0) = 0 then N'CST' else N'' end + N' ' + 
t.Tax_Description, 

[col3] = tc.taxcomponent_code, 

[col4] = case when isnull(tc.lst_flag, 0) = 1 then N'LST' 
when isnull(tc.lst_flag, 0) = 0 then N'CST' else N'' end + N' ' + 
tcd.taxcomponent_desc + N'_Of_' + t.Tax_Description,

[lstflag] = case when isnull(tc.lst_flag, 0) = 1 then 1
when isnull(tc.lst_flag, 0) = 0 then 2 else 0 end 
into #innertemp
From Tax t, taxcomponents tc, taxcomponentdetail tcd --,
--InvoiceAbstract ia, InvoiceDetail ids
Where 
--ia.invoiceid = ids.invoiceid  and 
--ids.taxid = tc.tax_code and 
tc.taxcomponent_code = tcd.taxcomponent_code
and t.tax_code = tc.tax_code 
--and t.tax_code --in 
--(select distinct taxid 

-- t.tax_code = tc.tax_code and tc.taxcomponent_code = tcd.taxcomponent_code and
-- and ids.taxid = t.tax_code and
-- (ids.TaxCode + ids.TaxCode2) > 0 and 
-- (ia.Status & 128) = 0
---------------------------------

-----------------------------
--set dateformat dmy
--select * from #innertemp

-- select distinct [tax_id] = t.tax_code, 
-- [tax_desc] = case when isnull(ids.taxid, 0) != 0 then 
-- case when isnull(ids.taxcode, 0) > 0 then N'LST' 
-- when isnull(ids.taxcode2, 0) > 0 then N'CST' else N'' end end + N' ' + 
-- t.Tax_Description, 
-- [col3] = trc.[col3], [col4] = trc.[col4], 
-- [lstflag] = case when isnull(ids.taxid, 0) != 0 then 
-- case when isnull(ids.taxcode, 0) > 0 then 1
-- when isnull(ids.taxcode2, 0) > 0 then 2 else 0 end end 
-- into #innertemp_two
-- --trc.[lstflag] 
-- from 
-- #innertemp  trc, tax t, InvoiceAbstract ia, InvoiceDetail ids
-- where t.tax_code *= trc.[tax_id] 
-- and ia.invoiceid = ids.invoiceid 
-- and ids.taxid = t.tax_code and
-- (ids.TaxCode + ids.TaxCode2) > 0 and 
-- (ia.Status & 128) = 0 and ia.invoicedate between @fromdate and @todate

------------------------------------

Select Distinct [tax_id] = t.tax_code, 
[tax_desc] = case when isnull(tc.lst_flag, 0) = 1 then N'LST' 
when isnull(tc.lst_flag, 0) = 0 then N'CST' else N'' end + N' ' + 
t.Tax_Description, 

[col3] = tc.taxcomponent_code, 

[col4] = case when isnull(tc.lst_flag, 0) = 1 then N'LST' 
when isnull(tc.lst_flag, 0) = 0 then N'CST' else N'' end + N' ' + 
tcd.taxcomponent_desc + N'_Of_' + t.Tax_Description,

[lstflag] = case when isnull(tc.lst_flag, 0) = 1 then 1
when isnull(tc.lst_flag, 0) = 0 then 2 else 0 end 
into #innertemp_two
From Tax t, taxcomponents tc, taxcomponentdetail tcd --,
--InvoiceAbstract ia, InvoiceDetail ids
Where 
--t.tax_code *= trc.[tax_id] and 
--ia.invoiceid = ids.invoiceid  and 
--ids.taxid = tc.tax_code and 
tc.taxcomponent_code = tcd.taxcomponent_code
and t.tax_code = tc.tax_code 

-- select distinct [tax_id],  [tax_desc] , [col3], [col4] ,[lstflag] into #innertemp_two
-- from #innertemp_inner_two

-----------------------
-- select distinct [tax_id] = t.tax_code, 
-- [tax_desc] = case when isnull(ids.taxid, 0) != 0 then 
-- case when isnull(ids.taxcode, 0) > 0 then N'LST' 
-- when isnull(ids.taxcode2, 0) > 0 then N'CST' else N'' end end + N' ' + 
-- t.Tax_Description, 
-- [col3] = trc.[col3], [col4] = trc.[col4], 
-- [lstflag] = case when isnull(ids.taxid, 0) != 0 then 
-- case when isnull(ids.taxcode, 0) > 0 then 1
-- when isnull(ids.taxcode2, 0) > 0 then 2 else 0 end end 
-- --into #innertemp_two
-- --trc.[lstflag] 
-- from 
-- #innertemp  trc, tax t, InvoiceAbstract ia, InvoiceDetail ids
-- where t.tax_code *= trc.[tax_id] 
-- and ia.invoiceid = ids.invoiceid 
-- and ids.taxid = t.tax_code and
-- (ids.TaxCode + ids.TaxCode2) > 0 and 
-- (ia.Status & 128) = 0 and ia.invoicedate between @fromdate and @todate

-----------------------
--@fromdate and @todate
-- select * from #innertemp_two 

insert into #innertemp_two (tax_id, tax_desc, lstflag)
select distinct t.tax_code , 
case when isnull(ids.taxid, 0) != 0 then 
case when isnull(ids.taxcode, 0) > 0 then N'LST' 
when isnull(ids.taxcode2, 0) > 0 then N'CST' else N'' end end + N' ' + 
t.Tax_Description, 
case when isnull(ids.taxid, 0) != 0 then 
case when isnull(ids.taxcode, 0) > 0 then 1
when isnull(ids.taxcode2, 0) > 0 then 2 else 0 end end 
from tax t, 
invoiceabstract ia, invoicedetail ids 
where ia.invoiceid = ids.invoiceid and
ids.taxid = t.tax_code and 
(ids.taxcode + ids.taxcode2) > 0 
and t.tax_code not in (select tax_id from #innertemp_two)


Delete from #innertemp_two 
Where lstflag = 1 and 
isnull(col3, 0) not in
(select ivtc.tax_component_code from invoicetaxcomponents ivtc, 
invoiceabstract ia, invoicedetail ids
Where ia.invoiceid = ids.invoiceid and 
(ia.Status & 128) = 0 and ia.invoicedate between @fromdate and @todate
and ids.invoiceid = ivtc.invoiceid 
and #innertemp_two.tax_id = ivtc.tax_code
and ids.taxcode > 0

union 

select 0
)

--set dateformat dmy

Delete from #innertemp_two 
Where lstflag = 2 and 
isnull(col3, 0) not in
(select ivtc.tax_component_code from invoicetaxcomponents ivtc, 
invoiceabstract ia, invoicedetail ids
Where ia.invoiceid = ids.invoiceid and 
(ia.Status & 128) = 0 and ia.invoicedate between @fromdate and @todate
and ids.invoiceid = ivtc.invoiceid 
and #innertemp_two.tax_id = ivtc.tax_code
and ids.taxcode2 > 0

union 

select 0
)

Delete from #innertemp_two Where isnull(Tax_id, 0) not in
(select ids.taxid from 
invoiceabstract ia, invoicedetail ids
Where ia.invoiceid = ids.invoiceid and 
(ia.Status & 128) = 0 and ia.invoicedate between @fromdate and @todate
and ids.taxcode + ids.taxcode2 > 0 )



--select @trc

--select * from #innertemp_two
-- drop table #innertemp_two
-- drop table #innertemp

Select @TRC = Count(*) From #innertemp_two

while (@TRC > 0 and @flag = 0)
begin

select top 1 @taxid = trd.[tax_id] from 
#innertemp_two trd
where trd.[tax_id] > @oldid 
order by trd.[tax_id]

select @maxid= max(trd.[tax_id]) from 
#innertemp_two trd
where trd.[tax_id] > @oldid 

--select @taxid

if @taxid = @maxid 
begin
set @flag = 1
end

Insert Into #taxdesc select top 1 [tax_desc], [tax_id], 1, [lstflag], [tax_id] from 

#innertemp_two trc
where trc.[tax_id] = @taxid and trc.[lstflag] = 1

--select * from #taxdesc

declare taxcomp cursor for
select [col4], [col3], 2, [lstflag], [tax_id] from 
#innertemp_two trd
where trd.[tax_id] = @taxid and trd.[lstflag] = 1
--Into @taxcomdesc

open taxcomp
fetch next from taxcomp into @taxcomdesc, @taxcomid, @flagid, @lstflag, @Parentid

while @@fetch_status = 0
begin
insert into #taxdesc select @taxcomdesc, @taxcomid, @flagid, @lstflag, @Parentid

fetch next from taxcomp into @taxcomdesc, @taxcomid, @flagid, @lstflag, @Parentid
end
close taxcomp
deallocate taxcomp
--select * from #taxdesc

------------------------------------------------------
--set dateformat dmy
Insert Into #taxdesc select top 1 [tax_desc], [tax_id], 1, [lstflag], [tax_id] from 

#innertemp_two trd
where [tax_id] = @taxid and [lstflag] = 2

declare taxcomp cursor for
select [col4] , [col3] , 2, [lstflag], [tax_id] from 
#innertemp_two  trd
where trd.[tax_id] = @taxid and trd.[lstflag] = 2
--Into @taxcomdesc

open taxcomp
fetch next from taxcomp into @taxcomdesc, @taxcomid, @flagid, @lstflag, @parentid

while @@fetch_status = 0
begin
insert into #taxdesc select @taxcomdesc, @taxcomid, @flagid, @lstflag, @parentid

fetch next from taxcomp into @taxcomdesc, @taxcomid, @flagid, @lstflag, @parentid
end
close taxcomp
deallocate taxcomp

-------------------------------------------------------------------------

set @oldid = @taxid

set @TRC = @TRC - 1
end

--select * from #taxdesc
--drop table #taxdesc

-----------------------------------------------------------------------------------
declare @tabscr as nvarchar(max)
declare @tabscr1 as nvarchar(max)
declare @extscr as nvarchar(max)
declare @interv as decimal(18, 6)
--set @strsql = 'select "Slno" = IDENTITY( int,1,1), "Party Name" = customer.company_name'
set @strsql = N'select "Party Name" = customer.company_name'
--set @strsqlUnion = 'select "Slno" = IDENTITY( int,1,1), "Party Name" = Cash_customer.CustomerName'
set @strsqlUnion = N'select "Party Name" = case When customer.company_name Is Null then "Other Customers" else customer.company_name end'
set @strsql2 = N''
set @strsql3 = N''
set @strsql4 = N''
set @Columns = N''

Create table #temps ([Party Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #temps ([Party Name])
select "Party Name" = customer.company_name
from invoicedetail,invoiceabstract,customer where 
Customer.CustomerID = InvoiceAbstract.CustomerID and 
invoicedetail.invoiceid = invoiceabstract.invoiceid and 
invoiceabstract.invoicetype Not In (4, 5, 6) and 
InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 
and (InvoiceAbstract.Status & 128) = 0 and 
InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
group by customer.company_name,Customer.CustomerID

-------------------------------

Create table #temps_one ([Party Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #temps_one ([Party Name])
select "Party Name" = customer.company_name
from invoicedetail,invoiceabstract,customer where 
Customer.CustomerID = InvoiceAbstract.CustomerID and 
invoicedetail.invoiceid = invoiceabstract.invoiceid and 
invoiceabstract.invoicetype In (4, 5, 6) and 
InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 
and (InvoiceAbstract.Status & 128) = 0 and 
InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
group by customer.company_name,Customer.CustomerID

declare @tabscr_one nvarchar(max)
declare @Columns_one nvarchar(max)
declare @strsqlUnion_one nvarchar(max)
set @Columns_one = N''
---------------------------------------------------------------
Select diStinct [StatuS] =  caSe when idS.taxcode > 0 then 1 
	when idS.taxcode2 > 0 then 2 end, 
[invoiceid] = tc.invoiceid, 
[tcc] = tc.tax_code, 
[tcomc] = tc.Tax_component_code, 
[tcv] = tc.Tax_Value
into #ivtcom
from invoicetaxcomponents tc, invoiceabStract ia, invoicedetail idS
where ia.invoiceid = idS.invoiceid and 
idS.invoiceid = tc.invoiceid and 
ia.invoicedate between @fromdate and @todate


--Select * from #ivtcom

--drop table #ivtcom


DECLARE percentagecursor CURSOR FOR
-- Select Distinct TaxCode + TaxCode2 from InvoiceAbstract, InvoiceDetail WHERE 
-- InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID 
-- And InvoiceDetail.TaxCode <> 0 Or InvoiceDetail.TaxCode2 <> 0 and 
-- (InvoiceAbstract.Status & 128) = 0 --group by TaxCode

Select tax_desc, tax_id, flag, LstFlag, parentid
From #taxdesc 
order by staxid

OPEN percentagecursor	
FETCH NEXT FROM percentagecursor into @percentageid, @Tax_ids, @Com_flag, @Lst_flag , @parentid

WHILE @@FETCH_STATUS =0
 		BEGIN
--			SELECT @Columns = @Columns + 'isnull([' + @percentageid + '], 0) + ' --'[' + @percentageid + '%],'

set @tabscr = N'Alter table #temps add [' + @percentageid + N'] decimal(18, 6) default(0)'

set @tabscr_one = N'Alter table #temps_one add [' + @percentageid + N'] decimal(18, 6) default(0)'

exec(@tabscr)
exec(@tabscr_one)


if @Com_flag = 1
Begin

SELECT @Columns = @Columns + N'isnull([' + @percentageid + N'], 0) + ' 
select @Columns_one = @Columns_one + N'isnull([' + @percentageid + N'], 0) + ' 
			
	SELECT @strsql1 = N'select "Party Name" = customer.company_name,
	 "' + @percentageid + N'" = 
	sum( case when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as nvarchar) + N' 
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1 
	then 0 - (invoicedetail.stPayable) 
	when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as nvarchar) + N'
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then 0 - (invoicedetail.cstpayable) 
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as  nvarchar) + N'
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1 
	then (invoicedetail.stPayable) 
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as nvarchar) + N'
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then (invoicedetail.cstpayable) 
	else 0 end), "Total" =  sum(case when InvoiceAbstract.InvoiceType in (4,5,6) 
	then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) else 
	invoicedetail.stPayable+invoicedetail.cstpayable end) 
	into #tempone from invoicedetail,invoiceabstract,customer where 
	Customer.CustomerID = InvoiceAbstract.CustomerID and 
	invoicedetail.invoiceid = invoiceabstract.invoiceid and 
	invoiceabstract.invoicetype Not In (4, 5, 6) and 
	InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 
	and (InvoiceAbstract.Status & 128) = 0 and 
	InvoiceAbstract.InvoiceDate BETWEEN ' + N'''' +  convert(varchar,@FROMDATE ) + N'''' + 
	N' AND ' + N'''' + convert( varchar,@TODATE ) + N'''' + N'  
	group by customer.company_name,Customer.CustomerID, InvoiceAbstract.InvoiceType, 
	InvoiceAbstract.invoiceid;update #temps set [' + @percentageid + '] = 
Isnull([' + @percentageid + N'], 0)  + isnull((select 
sum(isnull(#tempone.[' + @percentageid + N'], 0)) 
from #tempone
where #temps.[Party Name] = #tempone.[Party Name]), 0);'

----------------------------------------------------------------------

	SELECT @strsqlUnion_one = N'select "Party Name" = 
	case When customer.company_name Is Null then "Other Customers" 
	else customer.company_name end, 
	 "' + @percentageid + N'" = 
	sum( case when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as nvarchar) + N' 
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1 
	then 0 - (invoicedetail.stPayable) 
	when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as nvarchar) + N'
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then 0 - (invoicedetail.cstpayable) 
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as  nvarchar) + N'
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1 
	then (invoicedetail.stPayable) 
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and InvoiceDetail.taxid = '+ cast(@tax_ids as nvarchar) + N'
	and ' + Cast(@Com_flag as nvarchar) + N' = 1 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then (invoicedetail.cstpayable) 
	else 0 end), "Total" =  sum(case when InvoiceAbstract.InvoiceType in (4,5,6) 
	then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) else 
	invoicedetail.stPayable+invoicedetail.cstpayable end) 
	into #tempone_one from invoicedetail,invoiceabstract,customer where 
	Customer.CustomerID = InvoiceAbstract.CustomerID and 
	invoicedetail.invoiceid = invoiceabstract.invoiceid and 
	invoiceabstract.invoicetype In (4, 5, 6) and 
	InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 
	and (InvoiceAbstract.Status & 128) = 0 and 
	InvoiceAbstract.InvoiceDate BETWEEN ' + N'''' +  convert(varchar,@FROMDATE ) + N'''' + 
	N' AND ' + N'''' + convert( varchar,@TODATE ) + N'''' + N' 
	group by customer.company_name,Customer.CustomerID, InvoiceAbstract.InvoiceType, 
	InvoiceAbstract.invoiceid;update #temps_one set [' + @percentageid + N'] = 
Isnull([' + @percentageid + N'], 0)  + isnull((select 
sum(isnull(#tempone_one.[' + @percentageid + N'], 0)) 
from #tempone_one
where #temps_one.[Party Name] = #tempone_one.[Party Name]), 0);'

exec (@strsql1)
exec (@strsqlUnion_one)

end
else
begin

	SELECT @strsql1 = N'select "Party Name" = customer.company_name,
	 "' + @percentageid + N'" = 
	( case when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1
	then 0 - isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 1
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1 ), 0)
	when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then 0 - isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 2
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2), 0)
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1
	then isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 1
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1), 0)
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 2
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2), 0)
	else 0 end), "Total" =  sum(case when InvoiceAbstract.InvoiceType in (4,5,6) 
	then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) else 
	invoicedetail.stPayable+invoicedetail.cstpayable end) 
	into #tempone from invoicedetail,invoiceabstract,customer where 
	Customer.CustomerID = InvoiceAbstract.CustomerID and 
	invoicedetail.invoiceid = invoiceabstract.invoiceid and 
	invoiceabstract.invoicetype Not In (4, 5, 6) and 
	InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 
	and (InvoiceAbstract.Status & 128) = 0 and 
	InvoiceAbstract.InvoiceDate BETWEEN ' + '''' +  convert(varchar,@FROMDATE ) + N'''' + 
	N' AND ' + N'''' + convert( varchar,@TODATE ) + N'''' + N' 
	group by customer.company_name,Customer.CustomerID, InvoiceAbstract.InvoiceType, 
	InvoiceAbstract.invoiceid;update #temps set [' + @percentageid + N'] = 
Isnull([' + @percentageid + N'], 0)  + isnull((select 
sum(isnull(#tempone.[' + @percentageid + N'], 0)) 
from #tempone
where #temps.[Party Name] = #tempone.[Party Name]), 0);' --select * from #tempone'

---------------------------------------------------------------

	SELECT @strsqlUnion_one = N'select "Party Name" = customer.company_name,
	 "' + @percentageid + N'" = 
	( case when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1
	then 0 - isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 1
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1 ), 0)
	when InvoiceAbstract.InvoiceType In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then 0 - isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 2
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2), 0)
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1
	then isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 1
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 1), 0)
	when InvoiceAbstract.InvoiceType Not In (4, 5, 6) 
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2
	then isnull((Select sum(isnull(tcv, 0)) From #ivtcom itcm
	where itcm.invoiceid = InvoiceAbstract.invoiceid 
	and itcm.tcomc = ' + cast(@Tax_ids as nvarchar) + N' 
	and itcm.tcc = ' + cast(@parentid as nvarchar) + N'
	and itcm.status = 2
	and ' + Cast(@Com_flag as nvarchar) + N' = 2 
	and ' + cast(@Lst_flag as nvarchar) + N' = 2), 0)
	else 0 end), "Total" =  sum(case when InvoiceAbstract.InvoiceType in (4,5,6) 
	then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) else 
	invoicedetail.stPayable+invoicedetail.cstpayable end) 
	into #tempone_one from invoicedetail,invoiceabstract,customer where 
	Customer.CustomerID = InvoiceAbstract.CustomerID and 
	invoicedetail.invoiceid = invoiceabstract.invoiceid and 
	invoiceabstract.invoicetype  In (4, 5, 6) and 
	InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 
	and (InvoiceAbstract.Status & 128) = 0 and 
	InvoiceAbstract.InvoiceDate BETWEEN ' + '''' +  convert(varchar,@FROMDATE ) + N'''' + 
	N' AND ' + N'''' + convert( varchar,@TODATE ) + N'''' + N' 
	group by customer.company_name,Customer.CustomerID, InvoiceAbstract.InvoiceType, 
	InvoiceAbstract.invoiceid;update #temps_one set [' + @percentageid + N'] = 
Isnull([' + @percentageid + N'], 0)  + isnull((select 
sum(isnull(#tempone_one.[' + @percentageid + N'], 0)) 
from #tempone_one
where #temps_one.[Party Name] = #tempone_one.[Party Name]), 0)' --;select * from #tempone'

--select @strsql1
exec (@strsql1)
exec (@strsqlUnion_one)

end 


			SELECT @strsql2 = @strsql2 + @strsql1
--            select @strsql2
FETCH NEXT FROM percentagecursor into @percentageid, @Tax_ids, @Com_flag, @Lst_flag , @parentid
END	
CLOSE percentagecursor
DEALLOCATE percentagecursor 

set @tabscr = N'Alter table #temps add Total decimal(18, 6) default(0)'
set @tabscr_one = N'Alter table #temps_one add Total decimal(18, 6) not null default(0)'

exec(@tabscr)
exec(@tabscr_one)

set @tabscr = N'update #temps set Total = (' + @Columns + ' 0)'
set @tabscr_one = N'update #temps_one set Total = (' + @Columns_one + N' 0)'

exec(@tabscr)
exec(@tabscr_one)


--select [Party Name], * from #temps
set @tabscr_one = N'insert into #temps select * from #temps_one where Total != 0'
exec(@tabscr_one)
set @tabscr_one = N'select [Party Name], * from #temps where Total != 0'
exec(@tabscr_one)
drop table #temps
drop table #temps_one
end
else
Begin
--set @strsql = 'select "Slno" = IDENTITY( int,1,1), "Party Name" = customer.company_name'
set @strsql = N'select "Party Name" = customer.company_name'
--set @strsqlUnion = 'select "Slno" = IDENTITY( int,1,1), "Party Name" = Cash_customer.CustomerName'
set @strsqlUnion = N'select "Party Name" = case When customer.company_name Is Null then "Other Customers" else customer.company_name end'
set @strsql2 = N''
set @strsql3 = N''
set @strsql4 = N''
set @Columns = N''

DECLARE percentagecursor CURSOR FOR
Select Distinct TaxCode + TaxCode2 from InvoiceAbstract, InvoiceDetail WHERE 
InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID 
And InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 and 
(InvoiceAbstract.Status & 128) = 0 --group by TaxCode


OPEN percentagecursor	
FETCH NEXT FROM percentagecursor into @percentageid
	WHILE @@FETCH_STATUS =0
  		BEGIN
			SELECT @Columns = @Columns + N'[' + @percentageid + '%],'

			SELECT @strsql1 = N',"' + @percentageid + N'%" = sum( case when InvoiceAbstract.InvoiceType In (4, 5, 6) and InvoiceDetail.TaxCode = "'+ @percentageid + '" then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) when InvoiceAbstract.InvoiceType Not In (4, 5, 6) and (InvoiceDetail.TaxCode = "'+ @percentageid + '" or InvoiceDetail.TaxCode2 = "' + @percentageid + '") then invoicedetail.stPayable+invoicedetail.cstpayable else 0 end)'
			SELECT @strsql2 = @strsql2 + @strsql1
--            select @strsql2
	FETCH NEXT FROM percentagecursor into @percentageid
   	END	
CLOSE percentagecursor
DEALLOCATE percentagecursor 


SELECT @strsql3 = @strsql + @strsql2 + N',"Total" =  sum(case when InvoiceAbstract.InvoiceType in (4,5,6) then 0 - (invoicedetail.stPayable+invoicedetail.cstpayable) else invoicedetail.stPayable+invoicedetail.cstpayable end) into #temp from invoicedetail,invoiceabstract,customer where Customer.CustomerID = InvoiceAbstract.CustomerID and invoicedetail.invoiceid = invoiceabstract.invoiceid and invoiceabstract.invoicetype Not In (4, 5, 6) and InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 and (InvoiceAbstract.Status & 128) = 0 and InvoiceAbstract.InvoiceDate BETWEEN ' + '''' +  convert(varchar,@FROMDATE ) + '''' + ' AND ' + '''' + convert( varchar,@TODATE ) + '''' +' group by customer.company_name,Customer.CustomerID;'

SELECT @strsql4 = @strsqlUnion + @strsql2 + N',"Total" =  0- sum(stpayable+cstpayable) INTO #temp1 from invoiceabstract, customer, InvoiceDetail where Customer.CustomerID = InvoiceAbstract.CustomerID and invoicedetail.invoiceid = invoiceabstract.invoiceid and invoiceabstract.invoicetype In (4, 5, 6) and InvoiceDetail.TaxCode + InvoiceDetail.TaxCode2 <> 0 and (InvoiceAbstract.Status & 128) = 0 and InvoiceAbstract.InvoiceDate BETWEEN ' + '''' +  convert(varchar,@FROMDATE ) + '''' + ' AND ' + '''' + convert( varchar,@TODATE ) + '''' +' group by customer.company_name,Customer.CustomerID'

SELECT @ExecQry = @strsql3
--SELECT @ExecQry = @ExecQry + '; INSERT #temp([Party Name],' + @Columns + 'Total) SELECT [Party Name], ' + @Columns + 'Total FROM #temp1'
--SELECT @ExecQry = @ExecQry + '; INSERT INTO #temp([Party Name]) VALUES("Grand Total");'
--SELECT @ExecQry = @ExecQry + 'UPDATE #temp SET [Total]=(SELECT SUM(Total) FROM #temp) WHERE [Party Name] = "Grand Total" AND Total is null; select * into #temp from #temp1; ALTER TABLE #temp2 ALTER COLUMN Slno INT; UPDATE #temp2 SET Slno=NULL WHERE Slno =(SELECT MAX(Slno) FROM #temp2); SELECT * FROM #TEMP2 WHERE Total <> 0 ORDER BY SerialNo; DROP TABLE #temp, #temp1, #temp2 ' --DROP TABLE #temp'

--SELECT @ExecQry 
SELECT @ExecQry1 =  N'; INSERT #temp([Party Name],' + @Columns + N'Total) SELECT [Party Name], ' + @Columns + N'Total FROM #temp1'
--SELECT @ExecQry2 =  '; INSERT INTO #temp([Party Name]) VALUES("Grand Total");'
SELECT @ExecQry2 =  N';'
SELECT @ExecQry3 =  N'UPDATE #temp SET [Total]=(SELECT SUM(Total) FROM #temp) WHERE [Party Name] = "Grand Total" AND Total is null; SELECT "Customer_Name" = [Party Name],* FROM #TEMP WHERE Total <> 0 order by Total ; DROP TABLE #temp, #temp1' --DROP TABLE #temp'

EXEC(@ExecQry+@strsql4 + @ExecQry1+ @ExecQry2 + @ExecQry3)
end
GSTOut:
End
