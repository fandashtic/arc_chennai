CREATE procedure [dbo].[sp_get_VanStatementAbstract] (@DocSerial int)
as
Select DocSerial, DocumentID, DocumentDate, VanStatementAbstract.SalesmanID,
Salesman.Salesman_Name, IsNull(VanStatementAbstract.BeatID,0), IsNull(Beat.Description,dbo.LookupDictionaryItem('Others', Default)),
VanStatementAbstract.DocumentValue, VanStatementAbstract.VanID, Van.Van_Number,
VanStatementAbstract.Status, VanStatementAbstract.LoadingDate
From VanStatementAbstract
Inner Join Van on VanStatementAbstract.VanID = Van.Van
Left Outer Join Beat on VanStatementAbstract.BeatID = Beat.BeatID
Inner Join Salesman on VanStatementAbstract.SalesmanID = Salesman.SalesmanID

Where 
--VanStatementAbstract.VanID = Van.Van And
--VanStatementAbstract.BeatID *= Beat.BeatID And
--VanStatementAbstract.SalesmanID = Salesman.SalesmanID And
VanStatementAbstract.DocSerial = @DocSerial

