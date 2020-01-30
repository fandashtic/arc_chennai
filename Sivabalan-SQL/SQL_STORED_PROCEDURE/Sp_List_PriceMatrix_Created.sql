
CREATE Procedure Sp_List_PriceMatrix_Created (@Criteria int,    
       @FromDate Datetime,    
       @ToDate Datetime,    
       @MFromDate Datetime,    
       @MToDate Datetime)    
As    
If (@Criteria & 3) = 3     
 Begin    
  Select Distinct Items.Alias, Items.Product_Code, Items.ProductName, ICat.Category_Name,
  dbo.StripDateFromTime(Items.CreationDate),
  dbo.StripDateFromTime(Items.ModifiedDate)
  From Items,PricingAbstract PA, ItemCategories ICat
  Where Items.Product_Code = PA.ItemCode And  
  ICat.CategoryID = Items.CategoryID And
  IsNull(Items.Alias, N'') <> N'' And     
  (Items.CreationDate Between @FromDate And @ToDate Or    
   Items.ModifiedDate Between @MFromDate And @MToDate)    
 End    
Else If (@Criteria & 3) = 1    
 Begin    
  Select Distinct Items.Alias, Items.Product_Code, Items.ProductName, ICat.Category_Name,
  dbo.StripDateFromTime(Items.CreationDate),
  dbo.StripDateFromTime(Items.ModifiedDate)
  From Items,PricingAbstract PA, ItemCategories ICat
  Where Items.Product_Code = PA.ItemCode And  
  ICat.CategoryID = Items.CategoryID And
  IsNull(Items.Alias, N'') <> N'' And     
  Items.CreationDate Between @FromDate And @ToDate    
 End    
Else If (@Criteria & 3) = 2    
 Begin    
  Select Distinct Items.Alias, Items.Product_Code, Items.ProductName, ICat.Category_Name,
  dbo.StripDateFromTime(Items.CreationDate),
  dbo.StripDateFromTime(Items.ModifiedDate)
  From Items,PricingAbstract PA, ItemCategories ICat
  Where Items.Product_Code = PA.ItemCode And  
  ICat.CategoryID = Items.CategoryID And
  IsNull(Items.Alias, N'') <> N'' And     
  Items.ModifiedDate Between @MFromDate And @MToDate    
 End


