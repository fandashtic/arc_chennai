Create Procedure mERP_SP_getCashPopupValue 
AS
BEGIN
	If exists(Select * from tbl_mERP_ConfigAbstract Where ScreenName ='CASHPOPUP')
	BEGIN
		Select top 1 isnull(Flag,0) from tbl_mERP_ConfigAbstract Where ScreenName ='CASHPOPUP'
	END
	ELSE
	BEGIN
		Select 0
	END
END
