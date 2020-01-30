create Function fn_han_Get_ItemGroup(@OrderNumber as nVarchar(50), @grpSalesmanID as Int)  
Returns nvarchar(1000)    
as  
begin 
Declare @GroupID as nvarchar(1000)
declare @OrdSalesManID Int,@CustID nvarchar(30)
set @GroupID=''
Select @OrdSalesManID=SalesManID,@CustId=OutletID from order_header where OrderNumber= @OrderNumber
Declare @TmpGrpID Table(GroupID int,SalesmanID int)
insert into @TmpGrpID
Select distinct IsNull(GD.GroupID,0) 'GroupID', 
				case when (@OrdSalesManID in (select DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1 and TDSCGM.GroupId=IsNull(GD.GroupID,0))) then @OrdSalesManID 
				else (select top 1 DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0)  and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1
			inner join Beat_salesman BS on BS.salesmanid=DSD.Salesmanid and BS.CustomerID=@CustId order by DSD.Salesmanid) end 'SalesmanID'
		From Order_Details OD   
		Inner Join Order_Header OH On Convert(nVarchar,OD.OrderNumber) = @OrderNumber     
		And OH.OrderNumber = OD.OrderNumber
		Inner Join Items ITM On OD.Product_Code = ITM.Product_Code 
		Inner Join ProductCategoryGroupAbstract GD On GD.GroupId = Isnull(dbo.sp_han_GetCategoryGroup(ITM.CategoryId), 0)
		Left outer Join CustomerCreditLimit CCL On CCL.GroupID = GD.GroupId and CCL.CustomerID = @CustId
		group by OD.OrderNumber, GD.GroupID, CCL.CreditTermDays, CCL.CreditLimit
		order by SalesmanID,GroupID
select  @GroupID=@GroupID+cast(GroupID as nvarchar(30))+',' from @TmpGrpID where SalesmanID=@grpSalesmanID
Delete From @TmpGrpID
if(isnull(@GroupID,'')='')
Set @GroupID=''
Else
set @GroupID=left(@GroupID,len(@GroupID)-1)
return @GroupID  
end
