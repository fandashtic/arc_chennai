Create procedure mERP_spr_TLPointsDetail(@TLTypeID int)
As
Begin

Select TL.SalesManID, "TL ID" = TL.SalesManID , "TL Name" = TL.SalesManName, "TL Type" = TLType.TypeDesc, "Fixed" =N'', "Mobility"= N''  
From Salesman2 TL, tbl_mERP_SupervisorType TLType
Where TLType.TypeID = @TLTypeID 
and TLType.TypeID = TL.TypeID
and TL.Active=1 
Order by TL.SalesManName

End
