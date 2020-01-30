CREATE procedure [dbo].[Sp_Get_ProductDetail_Chevron](@QuotationType as INT, @CustCategory INT, @CustType INT)      
AS            
IF @QuotationType = 1            
BEGIN         
 SELECT Product_Code, ProductName, ECP, "Percentage" = CASE @CustType     
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
Company_price    
 END, IsNull(Tax_Code,0)  ,  
"MRP"=MRP      
 FROM Items, Tax WHERE Sale_Tax *= Tax_Code And Items.Active = 1          
END            
ELSE IF @QuotationType = 2            
BEGIN         
SELECT CategoryID, Category_Name FROM ItemCategories WHERE Active = 1            
END            
ELSE IF @QuotationType = 3            
BEGIN          
SELECT ManufacturerID, Manufacturer_Name FROM Manufacturer WHERE Active = 1            
END
