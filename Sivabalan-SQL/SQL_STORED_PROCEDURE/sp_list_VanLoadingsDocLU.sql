CREATE procedure [dbo].[sp_list_VanLoadingsDocLU] (@FromDocNo int,
					   @ToDocNo int)
as
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Select VanStatementAbstract.SalesmanID, Salesman.Salesman_Name, IsNull(VanStatementAbstract.BeatID,0),
IsNull(Beat.Description, @OTHERS), VanStatementAbstract.VanID, Van.Van_Number, 
VanStatementAbstract.DocumentID, VanStatementAbstract.DocumentDate,
VanStatementAbstract.DocumentValue, Status, DocSerial
From VanStatementAbstract, Van, Salesman, Beat
Where VanStatementAbstract.VanID = Van.Van And
VanStatementAbstract.BeatID *= Beat.BeatID And
VanStatementAbstract.SalesmanID = Salesman.SalesmanID And
VanStatementAbstract.DocumentID Between @FromDocNo And @ToDocNo
Order By Salesman.Salesman_Name
