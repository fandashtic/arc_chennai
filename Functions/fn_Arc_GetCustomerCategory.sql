--select dbo.fn_Arc_GetCustomerCategory('ARC001')
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_GetCustomerCategory')
BEGIN
    DROP FUNCTION fn_Arc_GetCustomerCategory
END
GO
CREATE  FUNCTION fn_Arc_GetCustomerCategory(@CustomerId Nvarchar(255))     
RETURNS NVarchar(255)      
As      
Begin      
 Declare @CategoryGroupName as Nvarchar(255)  
 Set @CategoryGroupName = (select Top 1 CategoryGroupName from Customer_CategoryGroups WITH (NOLOCK)  Where CategoryGroupId = (select CategoryGroupId FROM Customer_Mappings WITH (NOLOCK) Where CustomerID = @CustomerId))  
 RETURN ISNULL(@CategoryGroupName , '--')     
End      
GO
