
CREATE Procedure sp_insert_item_hierarchy (@HierarchyId int, @HierarchyName nvarchar(255))      
as      
insert into  ItemHierarchy values ( @HierarchyId , @HierarchyName )   


