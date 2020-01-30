Create Procedure  sp_ser_CancelInvoice (@InvoiceID int, @BackDated int)
as 
Declare @JobcardID int, @EstimationID int
Declare @retVal int 
/* Back dated transaction */
Declare @BatchCode int 
Declare @SpareCode nvarchar(15) 
Declare @QUANTITY decimal (18,6)
Declare @FreeRow Int
Declare @COST decimal (18,6)
Declare @InvoiceDate DateTime

Select @JobCardID = JobCardID,@InvoiceDate = ServiceInvoiceDate from ServiceInvoiceAbstract where ServiceInvoiceID = @InvoiceID

Update JobCardAbstract Set Status = Null, ServiceInvoiceID = Null, 
@EstimationID = EstimationID 
Where JobCardId = @jobCardId 
set @retVal = @@RowCount
If @retVal = 0 goto OvernOut
/* Cancellation of related transactions for the given Direct Invoice*/
if exists(select * from ServiceinvoiceAbstract Where ServiceInvoiceId = @InvoiceId 
	and (Isnull(Status, 0) & 8) = 8) 
begin
	/* Issue Cancellation
		changing Issue abstract Status */
	Update IssueAbstract Set Status = (Isnull(status, 0) | 192) Where JobcardId = @JobCardId
	
	/* Reversing JobCardSpares */
	Update J Set J.PendingQty = IsNUll(J.PendingQty,0) + 
		((IssuedQty - IsNull(ReturnedQty,0)) / (IssuedQty / UOMQty)),
		J.SpareStatus = 0 from JobCardSpares J 
	Inner Join Issuedetail On ReferenceID = J.SerialNo 
	where J.JobcardID = @JobCardID  
		
	/* Reversing Batch Product*/
	Update Batch_Products 
	Set Batch_Products.Quantity = Batch_Products.Quantity + (Issuedet.IssuedQty - IsNull(Issuedet.ReturnedQty,0)) 
	From Batch_Products 
	Inner Join 
		(Select Sum(IsNull(IDet.IssuedQty,0)) IssuedQty, 
			Sum(IsNull(IDet.ReturnedQty,0)) ReturnedQty, IDet.Batch_Code 
		from Issuedetail IDet 
		Inner Join IssueAbstract IAbs on IDet.IssueId = IAbs.IssueID  
		Where IAbs.JobcardID = @JobCardID Group by Batch_Code) IssueDet
	On Issuedet.Batch_Code = Batch_Products.Batch_Code 
	
	
	

 	/* Issue Cancelled */

	/* Cancellation of TaskAllocation */
	Update J Set TaskStatus = 3 from JobcardTaskAllocation J Where JobcardID = @JobcardID

	/* Cancellation of JobEstimation */		
	Update EstimationAbstract Set Status = (Isnull(Status, 0) | 192)
	Where EstimationID = @EstimationID
	
	Update JobCardAbstract Set status = (Isnull(status, 0) | 192) 
	Where JobCardId = @jobCardId 

	-- Reversing Item Information to JobCard Status
-- 	Update i Set i.Product_Status = 0 
-- 	From ServiceInvoiceDetail d  
-- 	Inner Join Item_Information i on d.Product_Code = i.Product_Code and 
-- 			d.Product_Specification1 = i.Product_Specification1
-- 	Where d.ServiceInvoiceId = @InvoiceId and d.Type = 0

	Update i Set i.Product_Status = 0, i.LastJobCardID = lJ.lastJobCardID, 
	i.lastModifiedDate = Getdate(), i.LastServiceDate = (Select JobCardDate from JobCardAbstract
								Where JobCardId = lJ.lastJobCardID)
	From Item_Information i 
	left Join 
	(Select d.Product_Specification1, 
	IsNull((Select Max(jd.JobCardID) from JobCardDetail jd
		Inner Join JobCardAbstract j On j.JobCardID = jd.JobCardID 
		Where (Isnull(Status,0) & 192) = 0 and 
		jd.Product_Specification1 = d.Product_Specification1),0) lastJobCardID 
	from JobCardDetail d where d.JobCardID = @jobCardId and d.Type = 0) lJ
	on lJ.Product_Specification1 = i.Product_Specification1
	set @retVal = @@RowCount
	If @retVal = 0 goto OvernOut
end
Else
begin
	-- Reversing Item Information to JobCard Status
	Update i Set i.Product_Status = 2 
	From ServiceInvoiceDetail d  
	Inner Join Item_Information i on d.Product_Specification1 = i.Product_Specification1
	Where d.ServiceInvoiceId = @InvoiceId and d.Type = 0 
	set @retVal = @@RowCount
	If @retVal = 0 goto OvernOut	
end

If @BackDated = 1 
Begin
	DECLARE curIssued CURSOR KEYSET FOR
	Select Batch_Code, SpareCode,(IssuedQty - IsNull(ReturnedQty,0)) NetQty, 
	PurchasePrice
	From IssueDetail 
	Inner Join IssueAbstract On IssueAbstract.IssueID = IssueDetail.IssueID 
	where IssueAbstract.JobCardID = @JobcardID and 
		IsNull(IssueDetail.Batch_Code,0) > 0 
	Open curIssued
	FETCH FROM curIssued into @batchCode, @SpareCode, @QUANTITY, @COST

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Select @FreeRow = IsNull(Free,0) from Batch_Products 
		Where Batch_Code = @BatchCode
		exec sp_ser_update_opening_stock 
		@SpareCode, @InvoiceDate, @QUANTITY, @FreeRow, @COST

	FETCH NEXT FROM curIssued into @batchCode, @SpareCode, @QUANTITY, @COST
	END
	Close curIssued
	deallocate curIssued		
End

Update ServiceInvoiceAbstract Set Status = (Isnull(status, 0) | 192)
where ServiceInvoiceID = @InvoiceID
set @retVal = @@RowCount


OvernOut:
Select @retVal


