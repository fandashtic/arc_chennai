CREATE Procedure sp_ser_CancelJobCard(@JobCardID Int)
as

-- Update abstract
Update JobCardAbstract
Set Status = (isnull(status,0) | 192)
Where JobCardId = @JobCardID

-- Reversing last Jobcard in Item Information 
Update i Set i.Product_Status = 0, i.LastJobCardID = lJ.lastJobCardID, 
i.lastModifiedDate = Getdate(), i.LastServiceDate = (Select JobCardDate from JobCardAbstract 
Where JobCardId = lJ.lastJobCardID)
From Item_Information i 
left Join 
(Select d.Product_Specification1, 
	IsNull((Select Max(jd.JobCardID) from JobCardDetail jd
	Inner Join JobCardAbstract j On j.JobCardID = jd.JobCardID 
	Where IsNull(ServiceInvoiceID,0) > 0 and (Isnull(Status,0) & 32) <> 0 
	and jd.Product_Specification1 = d.Product_Specification1),0) lastJobCardID 
	from JobCardDetail d where d.jobCardId = @JobCardID and d.Type = 0) lJ

on lJ.Product_Specification1 = i.Product_Specification1
Inner Join JobCardAbstract JA On i.lastjobcardid = ja.jobcardid
and JA.JobCardID = @JobCardID


