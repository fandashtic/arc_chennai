Create Procedure Sp_Get_UnMappedCategories_ITC  
As
declare @DivCount as int  
declare @SubCatCount as int
declare @Alert as int
Begin
Select  
 @DivCount=Count(IC.CategoryID)  
From  
 ItemCategories IC  
Where  
 IC.Category_Name Not In  
 (  
  Select Division from tblcgdivmapping 
 )  
 And IC.[Level] = 2  
 And IC.Active = 1
  
--if (@DivCount=0)
Begin
	select @SubCatCount=Count(*) from itemCategories I where 	
	I.CategoryID Not in (select CategoryID from MarginDetail where MarginID in (select Max(marginID) from MarginAbstract) and ParentID<>0)	
    and Active=1   
	and I.Level=3     
End
Select @Alert =isnull(Flag,0) from tbl_mERP_ConfigAbstract where ScreenCode='MAR02'
Select isnull(@DivCount,0) 'DivCount',isnull(@SubCatCount,0)  'SubCatCount', isnull(@Alert,0) 'Alert'
End
