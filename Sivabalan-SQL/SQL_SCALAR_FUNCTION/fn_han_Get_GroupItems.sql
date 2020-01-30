create Function fn_han_Get_GroupItems(@OrderNumber as nVarchar(50),@GroupID as nVarchar(500))  
Returns nvarchar(1000)    
as  
begin 
Declare @ItemID as nvarchar(1000)
declare @GroupName as nvarchar(1000)
set @ItemID=''
select @GroupName=isnull(GroupName,'') from ProductCategoryGroupAbstract where groupid=@GroupID  
		 select @ItemID=@ItemID+isnull(OD.Product_Code,'')+',' from order_details OD
		 inner join (Select Product_Code from dbo.sp_Get_Items_ITC(@GroupID)) GI 
		 on isnull(@GroupID,'')<> '' and GI.Product_Code=OD.Product_Code
		 where OD.ORDERNUMBER = @OrderNUmber
set @ItemID=case when isnull(@ItemID,'')='' then '' else left(@ItemID,len(@ItemID)-1) end
return @GroupName+'('+ @ItemID +')' 
end
