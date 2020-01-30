CREATE Procedure sp_Get_ItemsAvailable_Rec (@SchID int)  
as  
Begin  
select distinct itemschemes_rec.product_code from itemschemes_rec,items   
where Itemschemes_rec.product_code = items.Alias And itemschemes_rec.schemeid = @SchID  
  
union all  
  
Select distinct freeitem from schemeitems_Rec,items   
where schemeitems_rec.Freeitem = items.Alias And schemeitems_rec.schemeid = @SchID   
End  

