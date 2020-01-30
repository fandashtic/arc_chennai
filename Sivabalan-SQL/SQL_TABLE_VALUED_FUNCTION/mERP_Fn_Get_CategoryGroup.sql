Create Function mERP_Fn_Get_CategoryGroup    
( 
)    
Returns @CategoryGroup Table    
(    
 GroupID int Identity,
 GroupName nvarchar(100)    
)    
As    
Begin
 Insert Into @CategoryGroup    
 select distinct Top 3 CategoryGroup from tblCGDivMapping order by CategoryGroup
 Insert Into @CategoryGroup
 Select 'Common DS' 
Return    
End
