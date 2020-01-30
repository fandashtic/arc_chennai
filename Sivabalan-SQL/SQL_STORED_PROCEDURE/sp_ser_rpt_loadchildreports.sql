CREATE Procedure sp_ser_rpt_loadchildreports(@nParentID Int)
as 
Create table #Child (ChildID int not null) 
Declare @ID int 
Set @ID = @nParentID 
While  @ID <> 0 
Begin
	Set @ID = dbo.sp_ser_getReportDataChildID(@ID)
	If IsNull(@ID, 0) <> 0 Insert into #Child (ChildID) Values (@ID)
End
Select * from ReportData where [ID] in (Select ChildID from #Child) Order by ID
Drop Table #Child 

