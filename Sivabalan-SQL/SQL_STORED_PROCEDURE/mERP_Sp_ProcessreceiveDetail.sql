Create Procedure mERP_Sp_ProcessreceiveDetail ( @ID int, @ScreenCode nVarchar(200) )
As
If (@ScreenCode = 'ITM01' Or @ScreenCode = 'ITM02' Or @ScreenCode = 'ITM03')
	Select RCD.FieldName, RCD.Flag, "FieldValid" = ( Case when IsNull(CD.XMLAttribute,'') <> '' then 'yes' else 'No' end),
	"FlagValid" = (Case When (FieldName = N'AvailableQTY') Then (Case When ( RCD.Flag = 0 Or RCD.Flag = 1 Or RCD.Flag = 2 Or RCD.Flag = 3) then 'yes' else 'No'  End)
				   Else (Case When ( RCD.Flag = 0 Or RCD.Flag = 1 Or RCD.Flag = 2) then 'yes' else 'No' End )end)
	From tbl_mERP_RecConfigDetail RCD Left Outer join  tbl_mERP_ConfigDetail CD
	On RCD.FieldName = CD.XMLAttribute 
	Where Status = 0 and ID = @ID
	and CD.ScreenCode = @ScreenCode
Else if (@ScreenCode = 'DFRFLAG')
    Select RCD.FieldName, RCD.Flag, "FieldValid" = ( Case when IsNull(CD.XMLAttribute,'') <> '' then 'yes' else 'No' end),
	"FlagValid" = (Case When ( RCD.Flag = 0 Or RCD.Flag = 1 Or RCD.Flag = 2 Or RCD.Flag = 3) then 'yes' else 'No' end)
	From tbl_mERP_RecConfigDetail RCD Left Outer join  tbl_mERP_ConfigDetail CD
	On RCD.FieldName = CD.XMLAttribute 
	Where Status = 0 and ID = @ID
	and CD.ScreenCode = @ScreenCode
Else
	Select RCD.FieldName, RCD.Flag, "FieldValid" = ( Case when IsNull(CD.XMLAttribute,'') <> '' then 'yes' else 'No' end),
	"FlagValid" = (Case When ( RCD.Flag = 0 Or RCD.Flag = 1 Or RCD.Flag = 2) then 'yes' else 'No' end)
	From tbl_mERP_RecConfigDetail RCD Left Outer join  tbl_mERP_ConfigDetail CD
	On RCD.FieldName = CD.XMLAttribute 
	Where Status = 0 and ID = @ID
	and CD.ScreenCode = @ScreenCode

