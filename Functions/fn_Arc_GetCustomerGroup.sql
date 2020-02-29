--select dbo.fn_Arc_GetCustomerGroup('ARC001')
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_GetCustomerGroup')
BEGIN
    DROP FUNCTION [fn_Arc_GetCustomerGroup]
END
GO
CREATE  FUNCTION fn_Arc_GetCustomerGroup(@CustomerId Nvarchar(255)) 
RETURNS NVarchar(255)    
As    
Begin    
	Declare @GroupName as Nvarchar(255)
	Set @GroupName = (select Top 1 GroupName from Customer_Groups WITH (NOLOCK) Where GroupId = (select GroupId FROM Customer_Mappings WITH (NOLOCK) Where CustomerID = @CustomerId))
	RETURN ISNULL(@GroupName , '--')   
End    
GO