CREATE PROCEDURE Sp_Get_PMOutletStatus
AS
Begin
	IF (Select isnull(Flag,0) From Tbl_Merp_ConfigAbstract Where ScreenCode = 'PMOutletTarget') = 1
		Select 1
	Else
		Select 0
END
