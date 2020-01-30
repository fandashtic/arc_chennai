CREATE Procedure sp_get_SchemeDetail_MUOM (@SchemeID INT)  
As  
Select StartValue,EndValue,FreeValue,FreeItem, FromItem, ToItem, PrimaryUOM, FreeUOM  From SchemeItems where schemeID=@SchemeID   
order by startvalue asc  

