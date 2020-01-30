CREATE procedure [dbo].[sp_Get_UOMDescription](@CategoryID  INT,@ITEMCODE nVarchar(2550))    
AS    
Begin    
	Declare @uomCnt as int  
	Declare @uom1Cnt as int  
	Declare @uom2Cnt as int  
	Declare @uomDesc as nVarchar(255)  
	Declare @uom1Desc as nVarchar(255)  
	Declare @uom2Desc as nVarchar(255)  
	Declare @Delimeter as char(1)  
	Set @Delimeter = Char(15) 
	
	Create Table #tmpItemCode(ItemCode nVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Insert Into #tmpItemCode Select * from dbo.sp_splitIn2Rows(@ItemCode,@Delimeter)  

	select  @uomCnt =Count(DISTINCT Items.UOM) , @uom1Cnt =Count(DISTINCT Items.UOM1), @uom2Cnt =Count(DISTINCT Items.UOM2)  
	FROM Items,ItemCategories                          
	WHERE       
	Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Categoryid = @CategoryID  
	And Items.Product_Code in (Select * from #tmpItemCode)  
  
	If @uomCnt = 1
		Select @uomDesc =(Case @uomCnt When 1  then  UOM.Description else '' end)  
		FROM Items,ItemCategories,UOM                          
		WHERE       
		Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Categoryid = @CategoryID  
		And Items.Product_Code in (Select * from #tmpItemCode)  
		AND Items.UOM *= UOM.UOM                          
  
	If @uom1Cnt = 1   
		Select @uom1Desc =(Case @uom1Cnt When 1  then  UOM.Description else '' end)  
		FROM Items,ItemCategories,UOM                          
		WHERE       
		Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Categoryid = @CategoryID  
		And Items.Product_Code in (Select * from #tmpItemCode)  
		AND Items.UOM1 *= UOM.UOM                          
  
	If @uom2cnt = 1   
		Select @uom2Desc =(Case @uom2Cnt When 1  then  UOM.Description else '' end)  
		FROM Items,ItemCategories,UOM                          
		WHERE       
		Items.CategoryID = ItemCategories.CategoryID AND ItemCategories.Categoryid = @CategoryID  
		And Items.Product_Code in (Select * from #tmpItemCode)  
		AND Items.UOM2 *= UOM.UOM                          
	  
	Drop Table #tmpItemCode
	select @uomdesc,@uom1desc,@uom2desc  
End
