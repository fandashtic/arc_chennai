Create proc [dbo].[spr_Market_Stock_Turnover_Ratio] (@Date datetime)
as
declare @CurrMonth datetime
declare @PrevMonth datetime
set @CurrMonth = DATEADD(m, -1, @Date)
set @PrevMonth = DATEADD(m, -1, @CurrMonth)

create table #temp (beatid int, beatdescription nvarchar(100), invdate datetime, turnover1 Decimal(18,6) , turnover2 Decimal(18,6))
insert into #temp 
select  isnull(invoiceabstract.beatid, 0),  
	case isnull(invoiceabstract.beatid,0) when 0 then 'Others' else beat.description end, 
	invoiceabstract.invoicedate, 
	sum(case invoiceabstract.invoicetype when 4 then 0 - invoiceabstract.netvalue else invoiceabstract.netvalue end ),
	0
from invoiceabstract
Left Outer Join beat On beat.beatid = invoiceabstract.beatid 
where invoicedate between @CurrMonth and dateadd(hh,24,@Date)
	and invoiceabstract.invoicetype in( 1,3,4 )
	and ( invoiceabstract.status & 128 ) = 0
group  by invoiceabstract.beatid, beat.description,  invoiceabstract.invoicedate

insert into #temp 
select  isnull(invoiceabstract.beatid, 0),  
	case isnull(invoiceabstract.beatid,0) when 0 then 'Others' else beat.description end, 
	invoiceabstract.invoicedate, 
	0,
	sum(case invoiceabstract.invoicetype when 4 then 0 - invoiceabstract.netvalue else  invoiceabstract.netvalue  end )
from invoiceabstract
Left Outer Join beat On beat.beatid = invoiceabstract.beatid 
where invoicedate between @PrevMonth  and dateadd(hh,24,@CurrMonth)
	and invoiceabstract.invoicetype in( 1,3,4 )
	and ( invoiceabstract.status & 128 ) = 0
group  by invoiceabstract.beatid, beat.description,  invoiceabstract.invoicedate

select #temp.beatid,  "Beat" = #temp.beatdescription , "Curr-month Sale (%c.)" = sum(#temp.turnover1) , "Prev-month Sale (%c.)" = sum(#temp.turnover2) ,
	"Turnover Ratio" = case sum(#temp.turnover2) when 0 then 0 else ((sum(#temp.turnover1) / sum(#temp.turnover2)) * 30) end
from #temp
group by #temp.beatid,  #temp.beatdescription 
drop table #temp

