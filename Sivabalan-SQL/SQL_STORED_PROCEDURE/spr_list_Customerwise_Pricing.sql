CREATE Procedure spr_list_Customerwise_Pricing (@CustomerCode nvarchar(2550),       
 @ProductHierarchy nvarchar(255),      
    @Category nvarchar(2550))        
As        
      
Declare @Cnt int      
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)          
        
create table #tmpCustomer(CustomerID nvarchar(255))        
if @CustomerCode='%'        
   insert into #tmpCustomer select CustomerID from Customer        
else        
   insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@CustomerCode ,@Delimeter)        
      
Create Table #tempCategory(CategoryID int, Status int)           
Exec dbo.GetLeafCategories @ProductHierarchy, @Category        
Select Distinct CategoryID InTo #temp From #tempCategory      
    
Select Distinct QA.QuotationID, "Customer Code" = QC.CustomerID, "Customer Name" =       
 Company_Name, "Quotation Name" = QA.QuotationName      
from QuotationAbstract QA, QuotationCustomers QC, Customer, QuotationItems QI, Items       
Where QA.QuotationID = QC.QuotationID And QC.CustomerId = Customer.CustomerID       
And QuotationType = 1 And QC.CustomerID in (Select CustomerID from #tmpCustomer)     
And QA.Active = 1 And  QI.Product_Code = Items.Product_Code      
And  QA.QuotationID = QI.QuotationID And QC.QuotationID = QI.QuotationID    
And Items.CategoryId in (Select CategoryID from #temp)    
      
Drop Table #tmpCustomer      
Drop Table #tempCategory    
Drop Table #temp      
    


