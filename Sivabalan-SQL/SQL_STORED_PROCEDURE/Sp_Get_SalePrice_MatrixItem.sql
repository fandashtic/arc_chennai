Create Procedure Sp_Get_SalePrice_MatrixItem(@ItemCode nvarchar(50),@custCategory int)
As
Select  "Sale Price " = CASE @CustCategory        
 WHEN 1 THEN        
 PTS        
 WHEN 2 THEN        
 PTR        
 ELSE        
Company_price    
 END
From Items Where Product_Code=@ItemCode

