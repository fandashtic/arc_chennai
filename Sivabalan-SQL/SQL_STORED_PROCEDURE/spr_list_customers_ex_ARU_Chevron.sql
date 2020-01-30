CREATE PROCEDURE spr_list_customers_ex_ARU_Chevron(@FROMDATE datetime, @TODATE datetime)
AS

Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Select  0, "Beat" = @OTHERS, "Number of Customers" = 
	(Select Count(CustomerID) From Customer Where CustomerID Not In 
	(Select CustomerID From Beat_Salesman) And
	CreationDate Between @FROMDATE And @TODATE And CustomerCategory Not In(4,5))
UNION ALL
Select  BeatID, Beat.Description, (Select Count(CustomerID) From Customer Where CustomerID In 
	(Select CustomerID From Beat_Salesman Where Beat_Salesman.BeatID = Beat.BeatID) And
	CreationDate Between @FROMDATE And @TODATE)
From 	Beat
