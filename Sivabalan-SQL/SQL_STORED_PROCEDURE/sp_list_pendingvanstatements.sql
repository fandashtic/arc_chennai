CREATE procedure [dbo].[sp_list_pendingvanstatements](@FromDate datetime=0, @ToDate datetime=0,@Flag int=0)
as
Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
if @Flag=1 
begin
	select DocSerial, DocumentID, DocumentDate, VanStatementAbstract.SalesmanID, 
	Salesman.Salesman_Name, IsNull(VanStatementAbstract.BeatID,0), IsNull(Beat.Description, @OTHERS), 
	DocumentValue, VanStatementAbstract.VanID, Van.Van_Number 
	From VanStatementAbstract
	Inner Join Van on VanStatementAbstract.VanID = Van.Van
	Inner Join Salesman on VanStatementAbstract.SalesmanID = Salesman.SalesmanID
	Left Outer Join Beat on VanStatementAbstract.BeatID = Beat.BeatID

	Where 
	--VanStatementAbstract.VanID = Van.Van
	--And VanStatementAbstract.SalesmanID = Salesman.SalesmanID
	--And VanStatementAbstract.BeatID *= Beat.BeatID
	--And 
	(VanStatementAbstract.Status & 128) = 0 
	and VanStatementAbstract.DocumentDate between @FromDate and @ToDate
End
else
begin
	select DocSerial, DocumentID, DocumentDate, VanStatementAbstract.SalesmanID, 
	Salesman.Salesman_Name, IsNull(VanStatementAbstract.BeatID,0), IsNull(Beat.Description, @OTHERS), 
	DocumentValue, VanStatementAbstract.VanID, Van.Van_Number 
	From VanStatementAbstract
	--, Van, Salesman, Beat
	Inner Join Van on VanStatementAbstract.VanID = Van.Van
	Inner Join Salesman on VanStatementAbstract.SalesmanID = Salesman.SalesmanID
	Left Outer Join Beat on VanStatementAbstract.BeatID = Beat.BeatID
	Where 
	--VanStatementAbstract.VanID = Van.Van
	--And VanStatementAbstract.SalesmanID = Salesman.SalesmanID
	--And VanStatementAbstract.BeatID *= Beat.BeatID
	--And 
	(VanStatementAbstract.Status & 128) = 0 
End

