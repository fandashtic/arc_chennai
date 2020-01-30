CREATE PROCEDURE sp_ser_print_EstimationTaskAbstract(@EstID INT)
AS   
Select
	"Total Rate" = IsNull(Sum(EDetail.Price), 0),
	"Total Tax%" = Isnull(Avg(EDetail.ServiceTax_Percentage), 0),
	"Total Tax Value" = Isnull(Sum(EDetail.ServiceTax), 0),
	"Total Net" = Isnull(Sum(EDetail.NetValue), 0)
from EstimationDetail EDetail 
Where EDetail.EstimationID = @EstID
	and EDetail.Type in (1,2) 
	and IsNull(EDetail.SpareCode, '') = ''
	and IsNull(EDetail.TaskID, '') <> ''
Group by EDetail.EstimationID






