CREATE procedure sp_ser_canceljobcardsparesrow (@serialNo int)
as
Declare @RetVal as int 
Declare @JCSPARESISSUEDQTY as int 
--Set noCount on
--@JCSPARESISSUEDQTY = Sum(IssuedQty)
If Exists(Select Count(*) from IssueDetail d 
Where ReferenceID = @SerialNo and 
Exists (Select * from IssueAbstract a where a.IssueID = d.IssueID and 
	((IsNull(a.Status,0) & 192) = 0)) 
Group by ReferenceID)
begin
	Select @JCSPARESISSUEDQTY = Sum(IssuedQty) from IssueDetail 
	Where ReferenceID = @SerialNo group by ReferenceID

	Insert into JobCardSpares (JobCardID, Product_Code, 
	Product_Specification1, SpareCode, UOM, Qty, PendingQty, 
	SpareStatus, Warranty, WarrantyNo, DateofSale, JobID, TaskID, JobFree)  
	Select JobCardID, Product_Code, Product_Specification1, SpareCode, 
	UOM, Qty, PendingQty, 2, Warranty, WarrantyNO, DateofSale, JobID, TaskID, JobFree 
	from JobcardSpares Where SerialNo = @SerialNo
	Set @RetVal = @@Identity	-- Closed
	
	Update JobCardSpares Set Qty = IsNull(@JCSPARESISSUEDQTY,0), 
	PendingQty = 0, SpareStatus = 1 where  SerialNo = @SerialNo
	--set @RetVal = @@RowCount
end 
else
begin
	Update JobcardSpares Set SpareStatus = 2 where SerialNo = @SerialNo 
	set @RetVal = @@RowCount
end 
--Set noCount off
Select @RetVal 

/* 
If Partial quantity is issued then old jobcardspares row is updated with thw quantity issued 
New row is inserted with pending status and status 2
*/





