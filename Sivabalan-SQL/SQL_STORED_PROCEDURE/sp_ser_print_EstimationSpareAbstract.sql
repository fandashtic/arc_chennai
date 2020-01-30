CREATE PROCEDURE sp_ser_print_EstimationSpareAbstract(@EstID INT)      
AS      
Select
	"Total Rate" = IsNull(Sum(EDetail.Price), 0),
	"Total SaleTax Amount" = Sum(Isnull(LSTPayable, 0) + Isnull(CSTPayable, 0)),
	"Total TaxSuffered" = Isnull(Sum(EDetail.TaxSuffered), 0),
	"Total Amount" = Isnull(Sum(Amount), 0),
	"Total Quantity" = Isnull(Sum(Quantity), 0),
	"Total Net" = Isnull(Sum(EDetail.NetValue), 0)
from EstimationDetail EDetail 
Where EDetail.EstimationID = @EstID
	and IsNull(EDetail.SpareCode, '') <> ''
Group by EDetail.EstimationID







