Create Procedure sp_get_Count_Recd_Items
As
Select Distinct Count(ForumCode) From ItemsReceivedDetail
Where Flag & 32 = 0
