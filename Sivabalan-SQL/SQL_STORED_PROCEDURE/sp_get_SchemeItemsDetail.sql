
Create procedure sp_get_SchemeItemsDetail
                (@SchemeID as INT)
As
Select * from SchemeItems where schemeID=@schemeID

