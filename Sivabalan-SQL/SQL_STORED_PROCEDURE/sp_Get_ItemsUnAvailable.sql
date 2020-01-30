CREATE Procedure sp_Get_ItemsUnAvailable (@SchID int)
as
Begin
select distinct itemschemes_rec.product_code from itemschemes_rec
where Itemschemes_rec.product_code not in (select items.Alias from items )
And itemschemes_rec.schemeid = @SchID

union all

Select distinct freeitem from schemeitems_Rec
where schemeitems_rec.Freeitem not in (select items.Alias from items ) 
And isnull(FreeItem,N'')<>N'' And schemeitems_rec.schemeid = @SchID 
End

