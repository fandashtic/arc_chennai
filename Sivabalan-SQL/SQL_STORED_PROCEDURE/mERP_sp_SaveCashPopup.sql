Create Procedure mERP_sp_SaveCashPopup @Value int
AS
BEGIN
	If exists(Select * from tbl_mERP_ConfigAbstract Where ScreenName ='CASHPOPUP')
	BEGIN
		Update tbl_mERP_ConfigAbstract set Flag =@Value Where ScreenName ='CASHPOPUP'
	END
END
