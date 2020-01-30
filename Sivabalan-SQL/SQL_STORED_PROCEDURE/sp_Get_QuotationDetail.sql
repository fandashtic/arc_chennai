Create PROCEDURE sp_Get_QuotationDetail(@QuotationID INT, @QuotationType INT, @CustCategory INT, @CustType INT)        
AS        
Declare @MLECP NVarchar(50)
Declare @MLPurchase NVarchar(50)
Declare @MLYes NVarchar(50)
Declare @MLNo NVarchar(50)
Set @MLECP = dbo.LookupDictionaryItem(N'ECP', Default)
Set @MLPurchase = dbo.LookupDictionaryItem(N'Purchase', Default)
Set @MLYes = dbo.LookupDictionaryItem(N'Yes', Default)
Set @MLNo = dbo.LookupDictionaryItem(N'No', Default)

IF @QuotationType = 1        
BEGIN        
 SELECT "Item Code" = QuotationItems.Product_Code, 
 "Item Name" = ProductName, QuotationItems.ECP,       
 "Tax Percentage" = CASE @CustType         
 WHEN 1 THEN        
 IsNull(Percentage,0)         
 ELSE        
 IsNull(CST_Percentage,0)         
 END, QuotationItems.PurchasePrice, "Sale Price" = QuotationItems.SalePrice,       
 "MarginOn" = CASE MarginOn WHEN 1 THEN @MLECP ELSE @MLPurchase END,        
 MarginPercentage, RateQuoted, "QuotedTax" = CASE @CustType         
 WHEN 1 THEN        
 IsNull(Tax.Percentage,0)        
 ELSE        
 IsNull(Tax.CST_Percentage,0)        
 END, IsNull(Discount,0), "AllowScheme" = Case AllowScheme         
 WHEN 1 THEN        
 @MLYes        
 ELSE        
 @MLNo END,QuotedTax, N'1'        
 FROM QuotationItems
 left outer join Tax on QuotationItems.QuotedTax = Tax.Tax_Code        
 inner join Items on Items.Product_code = QuotationItems.Product_Code
  WHERE 
  QuotationItems.QuotationID = @QuotationID         
 UNION      
 SELECT Product_Code, ProductName, ECP, "Tax Percentage" = CASE @CustType         
 WHEN 1 THEN        
 IsNull(Percentage,0)         
 ELSE        
 IsNull(CST_Percentage,0)         
 END, Purchase_Price,        
 "Sale Price" = CASE @CustCategory            
 WHEN 1 THEN            
 PTS            
 WHEN 2 THEN            
 PTR            
 ELSE            
 Sale_Price            
 END,N'',0,0,0,0,N'',Tax_Code,N'0' -- It is a flag which has been used to know whether the data is retrieved from items master or quotation master - 0 - item master      
 FROM Items left outer join Tax on Sale_Tax = Tax_Code
  WHERE  Items.Active = 1       
 And Items.Product_Code NOT IN (SELECT Product_Code FROM QuotationItems WHERE QuotationID = @QuotationID)      
END        
ELSE IF @QuotationType = 2        
BEGIN        
 SELECT MfrCategoryID, "Category Name" = Category_Name, QuotationType, "MarginOn" = CASE MarginOn WHEN 1 THEN @MLECP ELSE @MLPurchase END,        
 MarginPercentage, "Tax" = CASE @CustType WHEN 1 THEN IsNull(Tax.Percentage,0) ELSE IsNull(Tax.CST_Percentage,0) END,        
 Discount, "AllowScheme" = CASE AllowScheme WHEN 1 THEN @MLYes ELSE @MLNo END, QuotationMfrCategory.Tax, N'1'         
 FROM QuotationMfrCategory left outer join Tax on QuotationMfrCategory.Tax = Tax.Tax_Code
 inner join  ItemCategories on     ItemCategories.CategoryID = QuotationMfrCategory.MfrCategoryID       
 WHERE          
   QuotationType = 2 And QuotationMfrCategory.QuotationID = @QuotationID        
 UNION      
 SELECT CategoryID, Category_Name, 0, N'', 0,0,0,N'',0,0 FROM ItemCategories WHERE Active = 1       
 And CategoryID NOT IN (SELECT MfrCategoryID FROM QuotationMfrCategory WHERE QuotationMfrCategory.QuotationID = @QuotationID And QuotationType = 2)      
END        
ELSE IF @QuotationType = 3        
BEGIN        
 SELECT MfrCategoryID, "Manufacturer Name" = Manufacturer_Name, QuotationType, "MarginOn" = CASE MarginOn WHEN 1 THEN @MLECP ELSE @MLPurchase END,        
 MarginPercentage, "Tax" = CASE @CustType WHEN 1 THEN IsNull(Tax.Percentage,0) ELSE IsNull(Tax.CST_Percentage,0) END,        
 Discount, "AllowScheme" = CASE AllowScheme WHEN 1 THEN @MLYes ELSE @MLNo END,QuotationMfrCategory.Tax,N'1'         
 FROM QuotationMfrCategory
 left outer join Tax on QuotationMfrCategory.Tax = Tax.Tax_Code
 inner join Manufacturer on QuotationMfrCategory.MfrCategoryID = Manufacturer.ManufacturerID 
 WHERE  
QuotationType = 1 And QuotationMfrCategory.QuotationID = @QuotationID        
 UNION      
 SELECT ManufacturerID, Manufacturer_Name,0, N'', 0,0,0,N'',0,0  FROM Manufacturer WHERE Active = 1      
 And ManufacturerID NOT IN (SELECT MfrCategoryID FROM QuotationMfrCategory WHERE QuotationMfrCategory.QuotationID = @QuotationID And QuotationType = 1)      
END        
ELSE        
BEGIN        
 SELECT MarginFrom, MarginTo, Discount FROM QuotationUniversal WHERE QuotationID = @QuotationID        
END              
  


