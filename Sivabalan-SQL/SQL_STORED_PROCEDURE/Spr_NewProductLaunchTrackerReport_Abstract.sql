create PROCEDURE Spr_NewProductLaunchTrackerReport_Abstract(@ProdHierarchy NVarchar(100), @SelectedCategory NVarchar(100), @ItemCode NVarchar(100), @Salesman NVarchar(100), @Beat NVarchar(100), @FromDate Datetime, @ToDate Datetime)       
AS    
    
Declare @Delimeter Char(1)    
      
Set @Delimeter = Char(15)      
    
Create Table #tempCategory (CategoryID int, Status int)     
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)             
      
Exec GetLeafCategories @ProdHierarchy, @SelectedCategory             
      
Create Table #TmpSalesman(Salesman_Name NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)          
        
if @Salesman = '%'            
   Insert into #TmpSalesman select Salesman_Name from Salesman            
else            
   Insert into #TmpSalesman select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter)            
    
Create Table #TmpItemcode(Product_Code NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)          
      
if @itemcode = '%'      
   Insert into #TmpItemcode select Product_code from items      
else      
   Insert into #TmpItemcode select * from dbo.sp_SplitIn2Rows(@Itemcode, @Delimeter)    
   
Exec sp_CatLevelwise_ItemSorting     
    
Select Product_Code Into #Temp1 From Items where CategoryID in (Select CategoryID From #tempcategory) and      
product_code in (select * from #TmpItemcode)       
    
Select     
Salesman_Name + Char(15) + Beat.Description + Char(15) + InvoiceDetail.Product_Code,    
"DS Name" = Salesman_Name,    
"Beat Name" = Beat.Description,    
"Item Code" = InvoiceDetail.Product_Code,    
"Item Name" = Productname,     
"Total No Of Customers Covered Till Date" = Count(Distinct invoiceabstract.customerid)    
From InvoiceDetail,InvoiceAbstract,Beat,Beat_Salesman,Salesman,Items,#tempCategory1        
Where InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And    
Beat.BeatID = Beat_Salesman.BeatID And    
InvoiceAbstract.BeatID=Beat.BeatID And
Beat_Salesman.SalesmanID = Salesman.SalesmanId And    
InvoiceAbstract.CustomerID = Beat_Salesman.CustomerID And    
Items.Product_Code = InvoiceDetail.Product_Code And    
Beat.Description Like @Beat And    
#tempCategory1.CategoryID = Items.CategoryID And  
Salesman_Name In (Select * From #TmpSalesman) And    
InvoiceDate Between @FromDate And @ToDate And (InvoiceAbstract.Status & 192) = 0        
And InvoiceDetail.Product_Code In (Select Product_code From #Temp1)      
Group By Salesman_Name,Beat.Description,InvoiceDetail.Product_Code,Productname,   
#tempCategory1.IDS  
Order By #tempCategory1.IDS,InvoiceDetail.Product_Code,Salesman_Name    
    
Drop Table #Temp1    
Drop Table #TmpItemcode    
Drop Table #TmpSalesman    
Drop Table #tempCategory    
Drop table #tempCategory1  
  

