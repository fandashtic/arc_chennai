create procedure mERP_SP_isCLONotesAdjusted @ActivityCode nvarchar(max)
AS
BEGIN
	Create table #CLOActivitycode(ID Int Identity(1,1), ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Insert Into #CLOActivitycode  
	Select * from dbo.sp_SplitIn2Rows(@ActivityCode, ',') 
	If exists(Select 'X' from clocrnote where ActivityCode in 
	(select ActivityCode from #CLOActivitycode) And active= 1 and isnull(IsGenerated,0)=1 And CreditID in 
	(select CreditID from CreditNote where balance >0)
	union
	Select 'x' from clocrnote 
	where active= 1 and isnull(IsGenerated,0)=0 and CLOType+CLOMonth in
	(select CLOType+CLOMonth from clocrnote where ActivityCode in (select ActivityCode from #CLOActivitycode)))
		Select 1 --alert will be shown to the user
	ELSE
		Select 0
	Drop Table #CLOActivitycode
END
