Create Procedure mERP_sp_UpdateCategory_GGDRData
As
Begin
Update G Set G.MarketSKU=T.MarketSKU,G.SubCategory=T.SubCategory,G.Division=T.Division From GGDRData G,TmpGGDRSKUDetails T
Where T.Product_code=G.SystemSKU

End
