Create VIEW [dbo].[V_SD_OutletFlag_Prod] AS
select Salesmanid as DSID,CustomerID as OutletID, ProdDefnID,SDProductCode,SDProductLevel,Target,TargetUOM,MTDSales,ProductFlag from [GGRRProdFinal]
