CREATE VIEW [dbo].[V_DSTypeCategoryMapping]
AS 
	Select DSID, DSType, SKUCode, PortFolio, Flag From dbo.mERP_FN_V_DSTypeCategoryMap()
