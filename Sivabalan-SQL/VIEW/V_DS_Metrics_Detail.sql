CREATE VIEW [dbo].[V_DS_Metrics_Detail](
[SalesmanID],	
[Group_ID],
[PMProductID],
[Level],
[Product_Code],	
[Product_Name])
AS
	 select * from FN_GetPMDetailForView() where Isnull(Product_Code,'') <> ''
