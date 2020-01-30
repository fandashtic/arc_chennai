CREATE procedure sp_ser_checkreturnableqty(@JobcardID as int ) 
as
Select Sum(IssuedQty - IsNull(ReturnedQty,0)) from Issuedetail 
Inner Join IssueAbstract On IssueAbstract.IssueID = IssueDetail.IssueID 
and (IsNull(IssueAbstract.Status,0) & 192) = 0 
Where JobCardId = @JobCardID Group by JobCardId




