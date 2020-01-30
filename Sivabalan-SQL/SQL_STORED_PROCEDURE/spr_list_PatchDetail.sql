
Create Procedure spr_list_PatchDetail
As 
Select PatchID, PatchID, PatchName, PatchDate, convert(varchar(11),PatchDate,108)  as PatchTime From PatchDetails Order By PatchDate

