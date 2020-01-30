create function sp_acc_rpt_getgroupname(@GroupID Int)
returns nvarchar(100)
Begin
Declare @GroupName nVarChar(100)
Select @GroupName = GroupName
from AccountGroup
Where GroupID = @GroupID  
return @GroupName
End


