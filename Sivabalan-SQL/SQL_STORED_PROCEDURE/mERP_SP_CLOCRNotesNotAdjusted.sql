create procedure mERP_SP_CLOCRNotesNotAdjusted @ActivityCode nvarchar(max)
AS
BEGIN
	set dateformat dmy
	Create table #CLOActivitycode(ID Int Identity(1,1), ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	
	Insert Into #CLOActivitycode  
	Select * from dbo.sp_SplitIn2Rows(@ActivityCode, ',') 

	Select CLO.ActivityCode,C.Company_Name as CustomerName ,CLO.CLOType, CLO.CLOMonth, CLO.CLODate , CLO.RefNumber, CR.Balance --Amount 
	,CLO.Category ,C.CustomerID ,CLO.CreditID 
	From CLOCrNote  CLO 
	Join CreditNote CR On CR.CreditID = CLO.CreditID And CR.Balance > 0
	Join Customer C on CLO.CustomerID = C.CustomerID  and ActivityCode in 
	(select ActivityCode from #CLOActivitycode) And CLO.active= 1 and isnull(IsGenerated,0)=1 
	--And CreditID in 	(select CreditID from CreditNote where balance >0)
	order by C.Company_Name
END
