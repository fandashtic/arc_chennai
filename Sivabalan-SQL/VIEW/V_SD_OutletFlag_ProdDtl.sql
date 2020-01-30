CREATE VIEW V_SD_OutletFlag_ProdDtl AS
select ProdDefnId,CategoryID as SDProductCode,Product_code as SKUCode from Output_SD_OutletFlag_ProdDtl --dbo.mERP_FN_V_SD_OutletFlag_Prod()
