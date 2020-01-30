CREATE Function mERP_fn_CheckTradeSchemeOutlet(@SchemeID Int, @OutletCode nVarchar(255))
Returns @SchInfo Table(QPS Int, GroupID Int)
As
Begin
	Declare @QPS Int
	Insert Into @SchInfo Select Top 1 SO.QPS, SO.GroupID 
		From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO 
		Where S.SchemeID = @SchemeID
			And S.SchemeID = SO.SchemeID 
			And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
			--And SO.QPS = 0
	If ((Select Count(*) From @SchInfo) = 0)
		Insert Into @SchInfo Select 2, 0

	Return 
End

