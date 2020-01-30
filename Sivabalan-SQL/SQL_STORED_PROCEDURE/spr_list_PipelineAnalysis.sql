create Procedure spr_list_PipelineAnalysis (@PRODUCT_HIERARCHY nvarchar(255),       
 @CATEGORY nvarchar(2550), @DATE DateTime)      
As      
Declare @GivenDate Datetime      
Declare @CurrentDate Datetime      
Declare @Month Int      
Declare @Month1 Int      
Declare @Year Int      
Declare @Year1 Int      
Declare @PreDate Datetime      
Set @PreDate = DateAdd(MM, -1, @DATE)      
Set @Month = Datepart(MM, @PreDate)      
Set @Year = Datepart(YY, @PreDate)      
Set @PreDate = DateAdd(MM, -3, @DATE)      
Set @Month1 = Datepart(MM, @PreDate)      
Set @Year1 = Datepart(YY, @PreDate)      
      
Set @GivenDate = dbo.StripDatefromTime(@DATE)      
Set @CurrentDate = dbo.StripDatefromTime(Getdate())      
      
Create Table #tempcategory(CategoryID int, Status int)      
Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY      
      
select distinct(categoryid) into #temcat from #tempcategory  
  
Select Category_Name, "Category" = Category_Name ,       
 "Last Month Sale" = (Select Sum((Case InvoiceAbstract.InvoiceType When 4 Then       
   -1 Else 1 End) * Amount) From InvoiceDetail,      
  Items, InvoiceAbstract Where InvoiceAbstract.InvoiceID =       
  InvoiceDetail.InvoiceID And       
  InvoiceDetail.Product_Code = Items.Product_Code And       
  Items.CategoryID = #temCat.CategoryID       
  And InvoiceAbstract.Status & 192 = 0 And InvoiceAbstract.InvoiceDate Between       
  '01/'+Cast(@Month As nvarchar)+'/'+Cast(@Year As nvarchar)       
  And Dateadd(DD, -1, '01/'+Cast(Datepart(MM, @DATE) As nvarchar)+'/'+Cast(Datepart(YY, @DATE)      
   As nvarchar))),       
  "Avg Sale of last 3 months" =       
  (Select IsNull(Sum((Case InvoiceAbstract.InvoiceType When 4 Then -1 Else        
  1 End) * Amount) / 3, 0) From InvoiceDetail,  items, InvoiceAbstract Where       
  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And       
  InvoiceDetail.Product_Code = Items.Product_Code And Items.CategoryID =       
  #temCat.CategoryID And InvoiceAbstract.Status & 192 = 0 And       
  InvoiceAbstract.InvoiceDate Between       
  '01/'+Cast(@Month1 As nvarchar)+'/'+Cast(@Year1 As nvarchar)       
  And Dateadd(DD, -1, '01/'+Cast(Datepart(MM, @DATE) As nvarchar)+'/'+Cast(Datepart(YY, @DATE)      
  As nvarchar))),       
 "Closing Stock Quantity" = IsNull(dbo.GetClosingQuantity (@DATE, Getdate(), ItemCategories.Category_Name), 0),      
 "Closing Stock Value" = IsNull(dbo.GetClosingValue (@DATE, Getdate(), ItemCategories.Category_Name), 0),      
 "Pipeline In Days" = IsNull(dbo.GetPipelineStock(@DATE, Getdate(), ItemCategories.Category_Name), 0) From       
 #temCat,  ItemCategories Where #temCat.CategoryID = ItemCategories.CategoryID         
      
drop table #tempCategory      
drop table #temCat  


