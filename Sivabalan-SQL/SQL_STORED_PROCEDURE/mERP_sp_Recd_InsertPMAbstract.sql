Create Procedure mERP_sp_Recd_InsertPMAbstract
(
@PMID Int,
@PMCode nVarchar(50) ,
@Description nVarchar(100),
@Groups nVarchar(50),
@Period nVarchar(8),
@Active Int
)
As
Begin
	Insert Into tbl_mERP_Recd_PMMaster(CPM_PMID,CPM_PMCode,CPM_Description,CPM_Groups,CPM_Period,CPM_Active,Status)
	Values(@PMID,@PMCode ,@Description,@Groups,@Period,@Active,0)
	Select @@Identity
End
