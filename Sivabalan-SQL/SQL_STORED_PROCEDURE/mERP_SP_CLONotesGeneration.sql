create procedure mERP_SP_CLONotesGeneration @ActivityCode nvarchar(max)
AS
BEGIN
	set dateformat dmy
	Create table #CLOActivitycode(ID Int Identity(1,1), ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	/* As per ITC, below checking is not required */
	Insert Into #CLOActivitycode  
	Select * from dbo.sp_SplitIn2Rows(@ActivityCode, ',') 
	Create Table #tmpResult(ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	insert into #tmpResult(ActivityCode)
	Select CLOType+'-'+CLOMonth from clocrnote 
	where active= 1 and isnull(IsGenerated,0)=0 and CLOType+CLOMonth in
	(select CLOType+CLOMonth from clocrnote where ActivityCode in (select ActivityCode from #CLOActivitycode))

	select distinct activitycode from #tmpResult
END
