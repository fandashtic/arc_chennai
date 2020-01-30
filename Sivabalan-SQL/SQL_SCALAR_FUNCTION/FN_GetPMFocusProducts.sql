create Function FN_GetPMFocusProducts (@ParamID Int)
Returns nvarchar(4000)
AS
BEGIN
	DECLARE @combinedString NVARCHAR(4000)
	SELECT @combinedString = COALESCE(@combinedString + '| ','') + ProdCat_Code
	FROM tbl_merp_PMParamFocus
	WHERE ParamID=@ParamID
	Return @combinedString
END
