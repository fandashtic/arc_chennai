Create VIEW  [dbo].[V_DS_Metrics]
([SalesmanID], [Group_ID], [Level], [Product_Code], [Product_Name], [SalesTarget], 
 [Achievement], [BillsCut], [LinesCut], [ValidFromDate], [ValidToDate]) 
AS

Select [SalesmanID], [Group_ID], [Level], [Product_Code], [Product_Name], 
 [SalesTarget], [Achievement], [BillsCut], [LinesCut], [ValidFromDate], [ValidToDate]
From dbo.Fn_Get_DSMetrics() 

