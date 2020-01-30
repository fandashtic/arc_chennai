Create Procedure mERP_sp_view_PointScheme ( @nSchemeId as int)
as
Begin
Select SchemeId "SerialNo",CS_RecSchID "SchemeCode", ActivityCode,Description,SchemeFrom,SchemeTo from tbl_merp_schemeabstract
where SchemeId=@nSchemeId
End
