CREATE procedure sp_ser_loadcolors(@Mode integer,
@KeyField varchar(30)='%',@Direction int = 0, @BookMark varchar(128) = '')
as
Declare @COLOR Int
Set @COLOR = 1

If @Mode = @COLOR
Begin
	If @Direction = 1
	Begin
		Select Code,[Description]
		From GeneralMaster
		Where IsNull(Type,0) = 1 
		and [Description] like @KeyField and [Description] > @BookMark
		order by [Description]		
	End
	Else
	Begin
		Select Code,[Description]
		From GeneralMaster
		Where IsNull(Type,0) = 1 
		and [Description] like @KeyField 
		order by [Description]		
	End
End




