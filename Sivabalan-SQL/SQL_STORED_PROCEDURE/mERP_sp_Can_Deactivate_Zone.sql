Create Procedure mERP_sp_Can_Deactivate_Zone(@ZoneID Int)
As
Begin
	If Exists(Select * From Customer Where Active = 1 And ZoneID = @ZoneID)
		Select 0
	Else
		Select 1
End
