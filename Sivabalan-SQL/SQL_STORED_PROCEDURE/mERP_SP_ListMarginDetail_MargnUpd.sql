Create Procedure mERP_SP_ListMarginDetail_MargnUpd(@Date DateTime = Null,@Level int)
As
Begin
  Declare @CatID int
  Declare @CategoryName nvarchar(100)
  Declare @Parent int
  
  Create Table #TempCategory (Code nvarchar(100),Division int,SubCategory int,MarketSKU int,SystemSKU nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
  Level int)

  Insert into #TempCategory(Code,Division,Level) select cast(CategoryID as nvarchar),CategoryID,2 
  from ItemCategories where Level=2

  Insert into #TempCategory(Code,Division,SubCategory,Level) 
  select cast(CategoryID as nvarchar),(select CategoryID from ItemCategories where CategoryID=I.ParentID),CategoryID,3 
  from itemcategories I where Level=3


  Insert into #TempCategory(Code,Division,SubCategory,MarketSKU,Level) 
  select cast(CategoryID as nvarchar),(select CategoryID from Itemcategories where CategoryID in 
  (select ParentID from ItemCategories where CategoryID=I.ParentID)),
  (select CategoryID from ItemCategories where CategoryID=I.ParentID),CategoryID,4 
  from itemcategories I where Level=4


   

  Insert into #TempCategory(Code,Division,SubCategory,MarketSKU,Level,SystemSKU)
  select Product_Code,Case when I.Level=4 then
  (select CategoryID from Itemcategories where CategoryID in 
  (select ParentID from ItemCategories where CategoryID=I.ParentID))
  when I.Level=3 then (select CategoryID from Itemcategories where CategoryID=I.ParentID)
  else I.CategoryID end,
  Case when I.Level=4 then
  (select CategoryID from ItemCategories where CategoryID=I.ParentID)
  when I.Level=3 Then I.CategoryID Else null end,
  case when I.Level=4 then I.CategoryID else null end,5,Product_Code   
  from Items,ItemCategories I where 
  I.CategoryID=Items.CategoryID


  select (select Category_Name from ItemCategories I where i.CategoryID=Division) 'Division',
  (select Category_Name from ItemCategories I where i.CategoryID=SubCategory) 'SubCategory', 
  (select Category_Name from ItemCategories I where i.CategoryID=MarketSKU)'MarketSKU',
  SystemSKU+' ~ '+(select ProductName from Items where Product_Code=SystemSKU)SystemSKU,   
  Level,  
  cast(isNull(dbo.merp_fn_Get_CategoryMargin(#TempCategory.Code,@Date,Level,'Percentage'),'-1') as decimal(18,6))
   'Percentage'
  ,dbo.merp_fn_Get_CategoryMargin(#TempCategory.Code,@Date,Level,'EffectiveDate')
  'EffectiveDate',
  dbo.merp_fn_Get_CategoryMargin(#TempCategory.Code,@Date,Level,'RevokeDate')
  'RevokeDate',SystemSKU as Pro 
  from #TempCategory where Level <= @Level
  order by Division,SubCategory,MarketSKU,SystemSKU,Level

   
End
