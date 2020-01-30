Create Procedure Sp_GetPMCategoryList(@ParamID Int)  
As  
Begin  
 /* This SP is used both in PM Metrics screen and PM report.*/
 Create Table #TempPMCategoryList (  
  Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
  Product_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  PMProductName Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  LevelofProduct Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)  
   
 Insert Into #TempPMCategoryList (Product_Code,PMProductName,LevelofProduct)  
 Select ProdCat_Code,  
 PMProDuctName,  
 case 
 When ProdCat_Level = 1 Then 'Company'   
 When ProdCat_Level = 2 Then 'Division'   
 When ProdCat_Level = 3 Then 'Sub Category'   
 When ProdCat_Level = 4 Then 'MarketSKU'   
 When ProdCat_Level = 5 Then 'SKU' End  
 From tbl_mERP_PMParamFocus Where ParamID = @ParamID 
 
   
 /* For SKU*/  
 Update T set T.Product_Name = T1.ProductName From #TempPMCategoryList T, (select Distinct Product_Code, ProductName From Items) T1  
 Where T.Product_Code = T1.Product_Code  
 And T.LevelofProduct ='SKU'  
  
 /* For NON SKU*/  
 Update T set T.Product_Name = IC.Description From #TempPMCategoryList T,ItemCategories IC  
 Where IC.Category_Name=T.Product_Code  
 And T.LevelofProduct <>'SKU'  
  
  
 Select 1,* from #TempPMCategoryList  
  
 Drop Table #TempPMCategoryList  
End  
