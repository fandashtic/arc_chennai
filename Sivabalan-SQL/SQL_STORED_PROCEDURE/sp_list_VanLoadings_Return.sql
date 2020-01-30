CREATE procedure [dbo].[sp_list_VanLoadings_Return]    (@Salesman nvarchar(255),
						@FromDate datetime,
						@ToDate datetime)
as
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Select VanStatementAbstract.SalesmanID, Salesman.Salesman_Name, IsNull(VanStatementAbstract.BeatID,0),
IsNull(Beat.Description, @OTHERS), VanStatementAbstract.VanID, Van.Van_Number, 
VanStatementAbstract.DocumentID, VanStatementAbstract.DocumentDate,
--VanStatementAbstract.DocumentValue, 
Sum(VanStatementDetail.SalePrice * VanStatementDetail.Pending) as DocumentValue,
Status, VanStatementAbstract.DocSerial
From VanStatementAbstract 
Inner Join VanStatementDetail on VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial
Inner Join Van on VanStatementAbstract.VanID = Van.Van 
Left Outer Join Beat on VanStatementAbstract.BeatID = Beat.BeatID
Inner Join Salesman on VanStatementAbstract.SalesmanID = Salesman.SalesmanID 

--Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial And
--VanStatementAbstract.VanID = Van.Van And
--VanStatementAbstract.BeatID *= Beat.BeatID And
--VanStatementAbstract.SalesmanID = Salesman.SalesmanID And
Where VanStatementAbstract.DocumentDate Between @FromDate And @ToDate And
Salesman.Salesman_Name like @Salesman And
VanStatementAbstract.Status & 128 = 0
Group By VanStatementAbstract.SalesmanID, Salesman.Salesman_Name, VanStatementAbstract.BeatID,
VanStatementAbstract.VanID, Van.Van_Number, Status, VanStatementAbstract.DocSerial,
VanStatementAbstract.DocumentID, VanStatementAbstract.DocumentDate, Beat.Description
Order by Salesman.Salesman_Name
