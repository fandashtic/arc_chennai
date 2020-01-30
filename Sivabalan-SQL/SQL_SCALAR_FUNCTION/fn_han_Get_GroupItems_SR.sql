create Function fn_han_Get_GroupItems_SR(@ReturnNumber as nVarchar(50),@GroupID as nVarchar(500))  
Returns nvarchar(1000)    
as  
begin 
Declare @ItemID as nvarchar(1000)
declare @GroupName as nvarchar(1000)
set @ItemID=''
select @GroupName=isnull(GroupName,'') from ProductCategoryGroupAbstract where groupid=@GroupID  
		 select @ItemID=@ItemID+isnull(SR.Product_Code,'')+',' from Stock_Return SR
		 inner join (Select Product_Code from dbo.sp_Get_Items_ITC(@GroupID)) GI 
		 on isnull(@GroupID,'')<> '' and GI.Product_Code=SR.Product_Code
		 where SR.ReturnNumber = @ReturnNumber
set @ItemID=case when isnull(@ItemID,'')='' then '' else left(@ItemID,len(@ItemID)-1) end
return @GroupName+'('+ @ItemID +')' 
End
