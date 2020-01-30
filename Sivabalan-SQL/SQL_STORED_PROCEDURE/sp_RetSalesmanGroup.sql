
CREATE Procedure sp_RetSalesmanGroup (@SalesmanID Int)
As  

Select Distinct pcga.GroupID, pcga.GroupName From ProductCategoryGroupAbstract pcga, 
DSHandle dsh Where pcga.GroupID = dsh.GroupID And dsh.SalesmanID = @SalesmanID

