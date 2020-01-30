CREATE Procedure spr_SMan_Productivity_Measures_Test
(    
	@SmanName as nVarchar(4000),    
	@SmanType as nVarchar(4000),    
	@Hierarchy as nVarchar(20),  
	@CatGrp as nVarchar(4000),  
	@Category as nVarchar(4000),    
	@FromDate as DateTime,    
	@ToDate as DateTime 
)
As
Begin
Declare @tmpCategoryType as Nvarchar(50)
Declare @Delimeter as NvarChar(1)
Declare @CategoryGroupTmp as Table (GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert into @CategoryGroupTmp values('Sample')
select * from @CategoryGroupTmp





	Delete From @CategoryGroupTmp

	If @tmpCategoryType = 'Regular'
	Begin
		select * from @CategoryGroupTmp
	End

End

--exec spr_SMan_Productivity_Measures_Test