CREATE VIEW V_SD_Outletflag AS
	select DSID,OutletID,CatGrp,OCG,SDFlag,ProdDefnID,CurrentSDFlag from dbo.mERP_FN_V_SD_Outletflag()
	Where isnull(CurrentSDFlag,'')<>''
