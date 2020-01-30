CREATE procedure [dbo].[spr_agent_cash_collections](@FROMDATE datetime, @TODATE datetime)
AS
Declare @OTHERS as NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)
select 	Collections.SalesmanID, "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS), 
	"Collection (%c)" = Sum(Value)
From	Collections, Salesman
Where	Collections.SalesmanID *= Salesman.SalesmanID And 
	DocumentDate between @FROMDATE And @TODATE And PaymentMode = 0 And 
	(IsNull(Collections.Status,0) & 64) = 0 And
	(IsNull(Collections.Status,0) & 128) = 0 
Group By Collections.SalesmanID, Salesman.Salesman_Name
