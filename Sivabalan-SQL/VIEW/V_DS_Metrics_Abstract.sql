CREATE VIEW [dbo].[V_DS_Metrics_Abstract](
[SalesmanID],	
[Group_ID],
[PMProductID],
[PMProductName],	
[SalesTarget],
[Achievement],	
[BillsCut],
[LinesCut],	
[ValidFromDate],
[ValidToDate])
AS
	 select * from FN_GetPMAbstractForView()
