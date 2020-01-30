Create Procedure mERP_sp_Save_SOImportFlag(@Node nvarchar(25),@FlagValue int)
As
Begin
	If not exists(select 'x' from SOimportFlag where Node=@Node)
		Insert into SOimportFlag(Node,Flag) Select @Node,@FlagValue
	Else
		Update SOimportFlag set Flag=@FlagValue where Node=@Node
End
