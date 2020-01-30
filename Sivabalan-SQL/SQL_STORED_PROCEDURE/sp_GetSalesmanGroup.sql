
CREATE Procedure sp_GetSalesmanGroup  
As  

Select Distinct pcga.GroupID, pcga.GroupName From ProductCategoryGroupAbstract pcga, 
ProductCategoryGroupDetail pcgd Where pcga.GroupID = pcgd.GroupId And Active = 1

