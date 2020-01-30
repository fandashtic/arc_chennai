CREATE Procedure sp_get_SchemeType
                 (@SCHEMEID as int = 0)
AS
Select distinct SchemeType from Schemes where Schemes.SchemeID = @SchemeID


