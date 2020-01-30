Create Function fn_GetItemHierarchy_ITC ()
Returns @tblHierarchyName Table (HierarchyId Int, HierarchyName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
    Insert Into @tblHierarchyName 
    select HierarchyId, HierarchyName from ItemHierarchy where HierarchyId = 2 union select 5, 'System SKU' [HierarchyName] 
    Return
End
