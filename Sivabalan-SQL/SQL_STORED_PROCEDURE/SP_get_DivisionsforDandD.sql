Create Procedure SP_get_DivisionsforDandD
AS
BEGIN
	select distinct CategoryID,Category_Name from ItemCategories where isnull(level,0)=2 order by Category_Name 
END
