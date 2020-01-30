Create Procedure Sp_han_GetSalesManGroup(@SalesmanID Int,@CustId nvarchar(30))
As
Begin
declare @GrpId nvarchar(200)
set @GrpId=''
create table #TmpGrpID (GroupID int)
insert into #TmpGrpID
select distinct  cast(TDSCGM.GroupID as int) 'GroupID'
from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and DSD.SalesManid=@SalesmanID and TDSCGM.Active = 1
				inner join Beat_salesman BS on BS.salesmanid=DSD.Salesmanid and BS.CustomerID=@CustId
where dstypectlpos = 1 and tdscgm.active = 1 order by GroupID
select  @GrpId=@GrpId+cast(GroupID as nvarchar(30))+',' from #TmpGrpID
drop table #TmpGrpID
select case when @GrpId='' then '' else left(@GrpId,len(@GrpId)-1) end 'SalesmanGrpID'
end
