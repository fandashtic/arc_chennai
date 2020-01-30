Create Procedure mERP_SP_CheckUnDefinedMarginCategory
As
Begin
	select Count(*) from itemCategories I where 	
	I.CategoryID Not in (select CategoryID from MarginDetail where MarginID in (select Max(marginID) from MarginAbstract) and ParentID<>0)	
    and Active=1   
	and I.Level=3
End
