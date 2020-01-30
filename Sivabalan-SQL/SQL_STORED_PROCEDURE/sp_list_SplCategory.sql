
CREATE PROCEDURE sp_list_SplCategory(@CATEGORYID INT)

AS

SELECT Special_Cat_Code, CategoryType, Description, Active FROM Special_Category
WHERE Special_Cat_Code = @CATEGORYID 




