CREATE Procedure sp_Get_ItemsAvailable (@SchID int)  
as  
Begin 
select distinct Alias from itemschemes,items   
where Itemschemes.product_code = items.product_code And itemschemes.schemeid = @SchID 
  
union all  
  
Select distinct Alias from schemeitems,items   
where schemeitems.Freeitem = items.product_code And schemeitems.schemeid = @SchID 
End

