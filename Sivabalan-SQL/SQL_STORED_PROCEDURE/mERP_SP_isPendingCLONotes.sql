create procedure mERP_SP_isPendingCLONotes @ActivityCode nvarchar(max)
AS
BEGIN
	Create table #CLOActivitycode(ID Int Identity(1,1), ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Insert Into #CLOActivitycode  
	Select * from dbo.sp_SplitIn2Rows(@ActivityCode, ',') 
	If exists(Select 'X' from clocrnote where ActivityCode in (select ActivityCode from #CLOActivitycode) And active= 1 and isnull(IsGenerated,0)=0)
		Select 1 --alert will be shown to the user
	ELSE
		Select 0
END
