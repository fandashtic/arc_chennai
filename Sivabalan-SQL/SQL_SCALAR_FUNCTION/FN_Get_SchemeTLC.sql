Create Function [dbo].FN_Get_SchemeTLC(@SchemeID int)
Returns int
As
Begin
Declare @SCHTLC int
Select @SCHTLC = isnull(TLCFlag,0)  From tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID

Return @SCHTLC
End
