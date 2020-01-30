Create Function dbo.fn_GetItmUom_ITC (@LevelOfReport nvarchar(255))
Returns @tblUom Table (Uom nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
    If @LevelOfReport = 'summary' 
    Begin	
        Insert Into @tblUom 
        select 'N/A' [Values]
    end
    Else If @LevelOfReport = 'Detail'
    Begin
        Insert Into @tblUom 
        select [Values] from QueryParams where queryparamId In (44) and [Values] <> 'N/A'
    end
Return
End
