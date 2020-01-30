
Create Procedure Sp_Check_CommonDC
As
Begin
Select Top 1 IsNull(Flag, 0) From tblConfigDC Where IsNull(Flag, 0) = 1
End

