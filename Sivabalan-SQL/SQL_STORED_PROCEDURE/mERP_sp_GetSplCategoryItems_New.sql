CREATE Procedure mERP_sp_GetSplCategoryItems_New(@SchemeID Int)  
As  
Begin  
 Create Table #tmpAllSKU(SKUCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)     
  
 Insert into #tmpAllSKU   
  
 select Product_Code from SchemeProducts SSD,tbl_mERP_SchemeProductScopeMap  SPS Where  
 SPS.SchemeID = @SchemeID And SPS.SchemeID =  SSD.SchemeID And SPS.ProductScopeID = SSD.ProductScopeID 
 And SSD.Active = 1	 
 Order by Product_Code  
   
 Select SKUCode From #tmpAllSKU    
   
 Drop Table #tmpAllSKU  
End 
