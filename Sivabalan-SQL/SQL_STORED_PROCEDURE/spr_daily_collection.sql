CREATE PROCEDURE spr_daily_collection (  
  @fromdate datetime,  
  @todate datetime  
  )  
as  
select paymentmode,"Payment Mode"='Cash',
"Value"=sum(value) from collections 
where documentdate between @fromdate and @todate and paymentmode=0
group by paymentmode
union
select paymentmode,"Payment Mode"='Post Dated Cheque',
"Value"=sum(value) from collections 
where documentdate between @fromdate and @todate and paymentmode=2 and chequedate>getdate()
group by paymentmode
union
select paymentmode,"Payment Mode"='Cheque',
"Value"=sum(value) from collections 
where documentdate between @fromdate and @todate and paymentmode=2 and chequedate<=getdate()
group by paymentmode
union
select paymentmode,"Payment Mode"='DD',
"Value"=sum(value) from collections 
where documentdate between @fromdate and @todate and paymentmode=1
group by paymentmode
