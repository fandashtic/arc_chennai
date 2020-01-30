Create Procedure SP_LPDataCheck
AS
BEGIN
	/* Since period is not a main constraint now, we have changed the below logic*/
	if exists(Select top 1 * from LPLog where isnull(active,0)=1)
	BEGIN
		Select 1
	END
	ELSE
	BEGIN
		Select 0
	END
END
