Create Procedure sp_han_SplitOrders(
@OrderNumber nVarchar(100), @CustId nVarchar(50), @SalesManID Int)
As
declare @GroupName nVarchar(100)
declare @CustName  nVarchar(300)
declare @msg nvarchar(500)

If Exists(select * from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid Where DSD.SalesmanID = @SalesManID and TDSCGM.GroupID = 0 and
(select Count(*) from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid Where DSD.SalesmanID = @SalesManID) = 1)
Begin
-- Salesman handle all category
Select IsNull(@OrderNumber,''), 0 'CreditTerm', 0 'CreditLimit',0 'SalesmanID'
End
Else
Begin
-- Salesman handle Specific category
create table #TmpSalesmanCat (OrderNumber nVarchar(100),CreditTermDays int,CreditLimit decimal(20,6),SalesManID Int,GroupName nVarchar(100),GroupID int)
insert into #TmpSalesmanCat
Select distinct  IsNull(OD.OrderNumber,'') 'OrderNumber'
--min(Isnull(CCL.CreditTermDays, 0)) 'CreditTerm', 
--min(IsNull(CCL.CreditLimit,0)) 'CreditLimit'
,(Select min(IsNull(CCL.CreditTermDays,0)) From CustomerCreditLimit CCL Where CCL.CustomerID= @CustId ) 'CreditTerm'
,(Select min(IsNull(CCL.CreditLimit,0)) From CustomerCreditLimit CCL Where CCL.CustomerID= @CustId ) 'CreditLimit' 
, case when (@SalesManID in (select DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0))) then @SalesManID
else (
select top 1 DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM 
on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0)
inner join Beat_salesman BS on BS.salesmanid=DSD.Salesmanid and BS.CustomerID=@CustId order by DSD.Salesmanid) end 'SalesmanID'
,GD.GroupName
,GD.GroupId
From Order_Details OD
Inner Join Order_Header OH On Convert(nVarchar,OD.OrderNumber) = @OrderNumber
And OH.OrderNumber = OD.OrderNumber And OH.Processed = 0
Inner Join Items ITM On OD.Product_Code = ITM.Product_Code
Inner Join ProductCategoryGroupAbstract GD On GD.GroupId = Isnull(dbo.sp_han_GetCategoryGroup(ITM.CategoryId), 0)
Left outer Join CustomerCreditLimit CCL On CCL.GroupID = GD.GroupId and CCL.CustomerID = @CustId
group by OD.OrderNumber, GD.GroupID, SalesmanID
--, CCL.CreditTermDays, CCL.CreditLimit
,GD.GroupName,GD.GroupId
end

if exists(select * from #TmpSalesmanCat where SalesManID is null)
begin
	set @GroupName=''
	set @CustName=''
	select @GroupName=@GroupName+dbo.fn_han_Get_GroupItems(@OrderNumber,GroupID)+',' from #TmpSalesmanCat where SalesManID is null
	select @GroupName= left(@GroupName,len(@GroupName)-1)
	select @CustName=isnull(Company_Name,'') from customer where customerid= @CustId 
	set @msg='No Salesman attached to the Category Group(s) '+ @GroupName+' for Customer '+@CustId+' - '+@CustName
	exec sp_han_InsertErrorlog @OrderNumber,1,'Error','Aborted' ,@msg,@SalesmanID
end
	select distinct  OrderNumber 'OrderNumber',
	CreditTermDays 'CreditTerm',CreditLimit 'CreditLimit',isnull(SalesManID,0) 'SalesmanID' from #TmpSalesmanCat

drop table #TmpSalesmanCat
