CREATE Procedure spr_list_Customerwise_Pricing_Detail (@QuotationID int,   
 @ProductHierarchy nVarchar(255),  
    @Category nVarchar(2550))    
As    
  
Create Table #tempCategory(CategoryID int, Status int)       
Exec dbo.GetLeafCategories @ProductHierarchy, @Category    
Select Distinct CategoryID InTo #temp From #tempCategory  
  
Select Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,  
"Rate" = QI.RateQuoted, "Tax %" = (Select IsNull(Tax.Percentage,0) from Tax Where 
Tax.Tax_Code = QI.QuotedTax), "Discount %" = QI.Discount  
from QuotationAbstract QA, QuotationItems QI, Items 
Where QA.QuotationID = @QuotationID And QI.Product_Code = Items.Product_Code  
And  QA.QuotationID = QI.QuotationID And QA.Active = 1 
And Items.CategoryId in (Select CategoryID from #temp)  
  
Drop Table #tempCategory  
Drop Table #temp  
  



