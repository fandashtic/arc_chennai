CREATE procedure spr_CustomerStatus_Abstract (@FromDate datetime,@ToDate datetime)       
As       
Begin      
Declare @qry as nvarchar(1000)      
Declare @cnt as int      
Declare @acnt as int      
Declare @ccnt as int      
Create Table #Customer(Code int,Customer nvarchar(50),Count int)      
      
-- To insert Total distinct customer count      
set @qry='insert into #Customer values (1,''Total'','      
Select @cnt=count(Distinct CustomerID) From customer Where CustomerCategory <>4 And CustomerCategory <>5      
set @qry=@qry + cast(isnull(@cnt,0) as nvarchar) + ')'      
exec sp_executesql @qry      
      
-- To insert Active distinct customer count      
set @qry='insert into #Customer values (2,''Active'','      
Select @cnt=count(Distinct CustomerID) From Customer Where Active=1 And CustomerCategory <>4 And CustomerCategory <>5      
set @qry=@qry + cast(isnull(@cnt,0) as nvarchar) + ')'      
set @acnt=isnull(@cnt,0)      
exec sp_executesql @qry      
      
-- To insert Contacted distinct customer count      
set @qry='insert into #Customer values (3,''Contacted'','      
Select @cnt=count(Distinct customerid) From WcpAbstract WCPAB, wcpdetail WCPDT      
where (isnull(WCPAB.status,0) & 128) = 0 And (isnull(WCPAB.status,0) & 32) = 0 And WCPAB.code=WCPDT.code And WCPDT.wcpdate Between @FromDate And @ToDate      
set @qry=@qry + cast(isnull(@cnt,0) as nvarchar) + ')'      
exec sp_executesql @qry     
     
-- To insert Not Contacted distinct customer count      
set @qry='insert into #Customer values (4,''Not Contacted'','      
Select @ccnt=Count(Distinct(CustomerID)) From Customer where CustomerId Not in ( Select WCPDT.CustomerID From WcpDetail WCPDT, WcpAbstract WCPAB Where WCPDT.wcpdate Between @FromDate And @ToDate   
And (isnull(WCPAB.status,0) & 128) = 0 And (isnull(WCPAB.status,0) & 32) = 0 And WCPAB.code=WCPDT.code) And Active = 1 And CustomerCategory <>4 And CustomerCategory <>5      
set @qry=@qry + cast(isnull(@ccnt,0) as nvarchar) + ')'      
  
exec sp_executesql @qry      
    
-- To insert Productive distinct customer count      
set @qry='insert into #Customer values (5,''Productive'','      
Select @cnt=Count(Distinct (CustomerId)) From SoAbstract Where (isnull(status,0) & 64) = 0 And (isnull(status,0) & 32) = 0  And sodate Between @FromDate And @ToDate      
set @qry=@qry + cast(isnull(@cnt,0) as nvarchar) + ')'      
exec sp_executesql @qry      
      
select * from #Customer      
drop table #Customer      
End      
  
  


