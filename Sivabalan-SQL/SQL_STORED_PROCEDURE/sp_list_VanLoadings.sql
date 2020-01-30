CREATE procedure [dbo].[sp_list_VanLoadings] (  @Salesman nvarchar(255),
					@FromDate datetime,
					@ToDate datetime)
as

Declare @OTHERS As Varchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Select VanStatementAbstract.SalesmanID, Salesman.Salesman_Name, IsNull(VanStatementAbstract.BeatID,0),
IsNull(Beat.Description,@OTHERS), VanStatementAbstract.VanID, Van.Van_Number, 
VanStatementAbstract.DocumentID, VanStatementAbstract.DocumentDate,
VanStatementAbstract.DocumentValue, Status, DocSerial
From VanStatementAbstract
Inner Join Van on VanStatementAbstract.VanID = Van.Van
Left Outer Join Beat on VanStatementAbstract.BeatID = Beat.BeatID
Inner Join Salesman on VanStatementAbstract.SalesmanID = Salesman.SalesmanID

Where 
--VanStatementAbstract.VanID = Van.Van And
--VanStatementAbstract.BeatID *= Beat.BeatID And
--VanStatementAbstract.SalesmanID = Salesman.SalesmanID And
VanStatementAbstract.DocumentDate Between @FromDate And @ToDate And
Salesman.Salesman_Name like @Salesman
order by Salesman.Salesman_Name
