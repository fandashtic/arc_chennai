CREATE Procedure  sp_ser_cancelissue(@IssueID int, @IssuedDate datetime)
as
Declare @JobCardId as int 

/* changing Issue abstract Status */
Update IssueAbstract Set Status = (isnull(Status, 0) | 192), @JobcardId = JobCardId 
Where IssueID = @IssueID

/* Reversing JobCardSpares */
Update J Set J.PendingQty = IsNUll(J.PendingQty,0) + 
	((IssuedQty - IsNull(ReturnedQty,0)) / (IssuedQty / UOMQty)),
	J.SpareStatus = 0 from JobCardSpares J 
Inner Join Issuedetail On ReferenceID = J.SerialNo 
where J.JobcardID = @JobCardID and Issuedetail.IssueID = @IssueId 
	
/* Reversing Batch Product*/
Update Batch_Products 
Set Batch_Products.Quantity = Batch_Products.Quantity + (Issuedet.IssuedQty - IsNull(Issuedet.ReturnedQty,0)) 
From Batch_Products Inner Join 
(Select Sum(IsNull(I.IssuedQty,0)) IssuedQty, Sum(IsNull(I.ReturnedQty,0)) ReturnedQty,  
I.Batch_Code from Issuedetail I Where I.IssueID = @IssueID Group by Batch_Code) IssueDet
On Issuedet.Batch_Code = Batch_Products.Batch_Code 

select @IssueID



