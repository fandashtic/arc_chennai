Create Procedure mERPFYCP_get_Count_Recd_Items ( @yearenddate datetime )
As
Select Distinct Count(ForumCode) From ItemsReceivedDetail
Where Flag & 32 = 0 and CreationDate <= @yearenddate
