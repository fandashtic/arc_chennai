create procedure mERP_SP_CLONotesConstraints @ActivityCode nvarchar(max)
AS
BEGIN
	set dateformat dmy
	Create table #CLOActivitycode(ID Int Identity(1,1), ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	/* As per ITC, below checking is not required */
	Insert Into #CLOActivitycode  
	Select * from dbo.sp_SplitIn2Rows(@ActivityCode, ',') 
--	Select ActivityCode,'Some of the Credit Notes are pending to generate' from clocrnote where ActivityCode in (select ActivityCode from #CLOActivitycode) And active= 1 and isnull(IsGenerated,0)=0
--	union
	Select distinct ActivityCode from clocrnote where ActivityCode in 
	(select ActivityCode from #CLOActivitycode) And active= 1 and isnull(IsGenerated,0)=1 And CreditID in 
	(select CreditID from CreditNote where balance >0)
END
