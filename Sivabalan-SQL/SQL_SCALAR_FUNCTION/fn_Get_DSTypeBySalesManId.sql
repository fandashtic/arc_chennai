
--Select Dbo.fn_Get_DSTypeBySalesManId(15)
CREATE FUNCTION [dbo].[fn_Get_DSTypeBySalesManId](@SalesManId INT)
RETURNS nVarchar(4000) AS 
BEGIN
	DECLARE @DSType nVarchar(4000)
	SET @DSType = (Select DM.DSTypeValue 
	from Salesman S WITH (NOLOCK)
	JOIN DSType_Details DD  WITH (NOLOCK) ON DD.SalesManID = s.SalesmanID
	JOIN DSType_Master DM  WITH (NOLOCK) ON DM.DSTypeId = DD.DSTypeId
	AND S.SalesmanID = @SalesManId
	AND DD.DSTypeCtlPos = 1)

	RETURN @DSType
END
