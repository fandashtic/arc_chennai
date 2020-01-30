CREATE Procedure Sp_Get_QuotationOnSalePrice(          
  @QuotationId Int,           
  @ProductCode as nVarchar(40),           
  @CustomerId as nVarchar(100))          
As          
Declare @QuotationType  int            
Declare @QtCount as Int           
    
Declare @tempCategory Table(Categoryid int)     
If (Select Distinct QuotationType From QuotationMfrCategory Where QuotationID = @QuotationId) = 2     
  BEGIN
    --To check whether the Quotation is defined on Leaf Level      
    IF Exists(Select MfrCategoryID From Items Items, QuotationMfrCategory QMfrCat          
			Where Items.Product_Code = @ProductCode
				and Isnull(Items.CategoryID,0) = QMfrCat.MfrCategoryID 
				and  QMfrCat.QuotationType = 2
				and  QMfrCat.QuotationId = @QuotationId) 
      BEGIN
        Insert Into @tempcategory 
	    Select MfrCategoryID From Items Items, QuotationMfrCategory QMfrCat          
	    Where Items.Product_Code = @ProductCode
		and Isnull(Items.CategoryID,0) = QMfrCat.MfrCategoryID 
		and  QMfrCat.QuotationType = 2
		and  QMfrCat.QuotationId = @QuotationId
      END  
    ELSE
      BEGIN   
        Insert into @tempcategory       
        Select A.CategoryID From ItemCategories A       
        Inner Join ItemCategories B on A.ParentID = B.CategoryID   
        Inner Join ItemCategories C On B.ParentID = C.CategoryID  
        Where C.CategoryID >= (Select Top 1 MfrCategoryID From QuotationMfrCategory       
          Where QuotationType=2 and QuotationID = @QuotationId)    
        Union  
        Select B.CategoryID From ItemCategories A       
        Inner Join ItemCategories B on A.ParentID = B.CategoryID   
        Inner Join ItemCategories C On B.ParentID = C.CategoryID  
        Where C.CategoryID >= (Select Top 1 MfrCategoryID From QuotationMfrCategory       
          Where QuotationType=2 and QuotationID = @QuotationId)    
        Union  
        Select C.CategoryID From ItemCategories A       
        Inner Join ItemCategories B on A.ParentID = B.CategoryID   
        Inner Join ItemCategories C On B.ParentID = C.CategoryID  
        Where C.CategoryID >= (Select Top 1 MfrCategoryID From QuotationMfrCategory       
          Where QuotationType=2 and QuotationID = @QuotationId)  
      END
  END       
          
Select @QuotationType = QuotationType             
From QuotationAbstract            
Where QuotationId = @QuotationId            
          
If @QuotationType = 1 -- Items            
 Select QItems.MarginOn From QuotationItems QItems, QuotationCustomers QCust, QuotationAbstract QAbs      
 Where QAbs.QuotationId = @QuotationId and            
 QItems.Product_Code = @ProductCode and          
 QCust.CustomerID = @CustomerId and          
 QAbs.QuotationId = QItems.QuotationId and          
 QItems.QuotationId = QCust.QuotationID and           
 QAbs.Active = 1           
Else If @QuotationType = 2 -- Cat      
 Select QMfr.MarginOn From QuotationMfrCategory QMfr, QuotationCustomers QCust,           
 ItemCategories ICat, Items It, QuotationAbstract QAbs          
 Where ICat.CategoryID = It.CategoryID and           
 It.Product_Code = @ProductCode and           
-- ICat.CategoryID = QMfr.MfrCategoryID and      
 ICat.CategoryID In(Select * from @tempCategory) and     
 QAbs.QuotationId = @QuotationId and            
 QCust.CustomerID = @CustomerID and           
 QAbs.QuotationId = QMfr.QuotationID and           
 QMfr.QuotationID = QCust.QuotationID and         
 QAbs.Active = 1 and QMfr.QuotationType = 2        
Else IF @QuotationType = 3 -- Mfr          
 Select QMfr.MarginOn From QuotationMfrCategory QMfr, QuotationCustomers QCust,           
 Manufacturer Mfr, Items It, QuotationAbstract QAbs          
 Where Mfr.ManufacturerID = It.ManufacturerID and           
 It.Product_Code = @ProductCode and           
 Mfr.ManufacturerID = QMfr.MfrCategoryID and          
 QAbs.QuotationId = @QuotationId and            
 QCust.CustomerID = @CustomerID and           
 QAbs.QuotationId = QMfr.QuotationID and           
 QMfr.QuotationID = QCust.QuotationID and         
 QAbs.Active = 1 and QMfr.QuotationType = 1      
Else If @QuotationType = 4 -- Universal      
 Select 0      
      
    
  


