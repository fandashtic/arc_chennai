CREATE Procedure sp_get_SchemeDetail
                (@SchemeID INT)
as
Select StartValue,EndValue,FreeValue,FreeItem, FromItem, ToItem  from SchemeItems where schemeID=@SchemeID 
order by startvalue asc 






