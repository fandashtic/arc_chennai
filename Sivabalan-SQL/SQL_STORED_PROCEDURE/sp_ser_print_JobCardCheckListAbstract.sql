Create Procedure sp_ser_print_JobCardCheckListAbstract(@JobCardID INT)
As
Declare @totCheckLists Int,@totListItem Int,@SerialNo Int
Select @totCheckLists = 0,@totListItem =0
Select 
@totCheckLists = Case when JCCL.SerialNo = @SerialNo then 0
					else 1 end + @totCheckLists
,@totListItem  = Case 
				when IsNull(JCCL.CheckListItemID,'') = '' then 0
				else 1 end + @totListItem 
,@SerialNo = JCCL.SerialNo 
from JobCardDetail JCD
Inner Join JobCardCheckList JCCL On JCD.SerialNo = JCCL.SerialNo 
and JCD.Type = 0 and JCD.JobCardID = @JobCardID
and IsNull(CheckListID,'') <> '' 
Select  "Total CheckLists" = @totCheckLists,"Total CheckListItems" = @totListItem where @totCheckLists <> 0

