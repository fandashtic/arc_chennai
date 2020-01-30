CREATE procedure spr_list_VanLoadings ( @FromDate datetime,
					@ToDate datetime)
as
Select 	DocSerial,
	"DocumentID" = VanStatementAbstract.DocumentID, 
	"Date" = cast(day(VanStatementAbstract.DocumentDate) as nvarchar) + '/' + cast(Month(VanStatementAbstract.DocumentDate) as nvarchar) + '/' + cast(year(VanStatementAbstract.DocumentDate) as nvarchar) ,
	"Beat" = Beat.Description, 
	"Salesman" = Salesman.Salesman_Name, 
	"Van ID" = VanStatementAbstract.VanID, 
	"Van Number" = Van.Van_Number,
	"Document Value" = VanStatementAbstract.DocumentValue	
From 	VanStatementAbstract, Van, Salesman, Beat
Where 	VanStatementAbstract.VanID = Van.Van And
	VanStatementAbstract.BeatID = Beat.BeatID And
	VanStatementAbstract.SalesmanID = Salesman.SalesmanID And
	VanStatementAbstract.DocumentDate Between @FromDate And @ToDate 
	AND (status & 128) = 0
order by cast(day(VanStatementAbstract.DocumentDate) as nvarchar) + '/' + cast(Month(VanStatementAbstract.DocumentDate) as nvarchar) + '/' + cast(year(VanStatementAbstract.DocumentDate) as nvarchar)
