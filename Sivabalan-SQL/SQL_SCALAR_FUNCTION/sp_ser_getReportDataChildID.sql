Create Function sp_ser_getReportDataChildID(@nParentID int) 
Returns int 
as 
begin
	Declare @ChildID Int
	Select @ChildID = ID from ReportData Where Parent = @nParentId 
	Return isnull(@ChildID, 0) 
end

