CREATE Procedure spr_list_Stock_AgeingAnalysis (@Manufacturer nvarchar(2550),  
      @Divisionname nvarchar(2550),  
      @ProductCode nvarchar(2550))  
As  
  
Declare @One As Datetime              
Declare @Thirty As Datetime        
Declare @ThirtyOne As Datetime        
Declare @Sixty As Datetime        
Declare @SixtyOne As Datetime        
Declare @Ninety As Datetime        
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
  
Create table #tmpMfr(Manufacturer nvarchar(255))    
Create table #tmpDiv(Division nvarchar(255))    
Create table #tmpPro(ProductName nvarchar(255))    
  
if @Manufacturer ='%'     
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer    
Else    
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer, @Delimeter)    
    
if @Divisionname ='%'    
   Insert into #tmpDiv select BrandName from Brand    
Else    
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Divisionname, @Delimeter)    
  
if @ProductCode  ='%'    
   Insert into #tmpPro select ProductName from Items  
Else    
   Insert into #tmpPro select * from dbo.sp_SplitIn2Rows(@ProductCode, @Delimeter)    
  
  
Create table #Temp        
(Productcode nvarchar(150),  
[Item Code] nvarchar(150),  
[Item Name] nvarchar(250),  
Category nvarchar(150),   
[Root Level Category] nvarchar(150),   
[Qty (1 - 30 days)] Decimal(18,6) null,        
[Qty (31 - 60 days)] Decimal(18,6) null,        
[Qty (61 - 90 days)] Decimal(18,6) null,        
[Qty ( > 90 days)] Decimal(18,6) null,  
[Value(1 - 30 days)] Decimal(18,6) null,        
[Value(31 - 60 days)] Decimal(18,6) null,        
[Value(61 - 90 days)] Decimal(18,6) null,        
[Value( > 90 days)] Decimal(18,6) null)        
                                 
Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + '/' +          
Cast(Datepart(mm, GetDate()) As nvarchar) + '/' +          
Cast(Datepart(yyyy, GetDate()) As nvarchar)               
Set @Thirty = DateAdd(d, -29, @One)        
Set @ThirtyOne = DateAdd(d, -1, @Thirty)        
Set @Sixty = DateAdd(d, -29, @ThirtyOne)        
Set @SixtyOne = DateAdd(d, -1, @Sixty)        
Set @Ninety = DateAdd(d, -29, @SixtyOne)   
       
Set @One = dbo.MakeDayEnd(@One)        
Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)        
Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)        
  
Declare @Opendate datetime  
Declare @ItemCode nvarchar(100)  
Declare @CatID int  
  
Declare getItemCode CURSOR  FOR  
Select distinct Batch_Products.Product_code from Batch_Products, Items, Brand, Manufacturer   
 where Batch_Products.Product_Code = Items.Product_Code AND   
 Items.BrandID = Brand.BrandID AND   
 Items.ManufacturerID = Manufacturer.ManufacturerID AND  
 Manufacturer.Manufacturer_Name In (Select Manufacturer From #tmpMfr) AND  
 Brand.BrandName In (Select Division From #tmpDiv) AND   
 Batch_Products.Product_Code In ( Select ProductName From #tmpPro)  
  
Open getItemCode  
Fetch From getItemCode Into @ItemCode  
While @@Fetch_Status = 0  
Begin  
  
select @CatID = CategoryID from Items where Product_Code = @ItemCode   
select @Opendate = Opening_Date from OpeningDetails where Product_Code = @ItemCode  
  
Insert into #Temp  
Select Batch_Products.Product_code,   
Batch_Products.Product_code,  
ProductName,  
Category_Name,  
dbo.fn_FirstLevelCategory (@CatID),   
"Quantity1" = (Select Sum(Quantity) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) between @Thirty and @One And Batch_Products.Product_Code = @ItemCode),  
"Quantity2" = (Select Sum(Quantity) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) between @Sixty and @ThirtyOne And Batch_Products.Product_Code = @ItemCode),  
"Quantity3" = (Select Sum(Quantity) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) between @Ninety and @SixtyOne And Batch_Products.Product_Code = @ItemCode),  
"Quantity4" = (Select Sum(Quantity) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) < @Ninety And Batch_Products.Product_Code = @ItemCode),  
"Value1" = (Select Sum(Quantity * PurchasePrice) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) between @Thirty and @One And Batch_Products.Product_Code = @ItemCode),  
"Value2" = (Select Sum(Quantity * PurchasePrice) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) between @Sixty and @ThirtyOne And Batch_Products.Product_Code = @ItemCode),  
"Value3" = (Select Sum(Quantity * PurchasePrice) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) between @Ninety and @SixtyOne And Batch_Products.Product_Code = @ItemCode),  
"Value4" = (Select Sum(Quantity * PurchasePrice) from Batch_Products where IsNull(Batch_Products.CreationDate,@Opendate) < @Ninety And Batch_Products.Product_Code = @ItemCode)  
from Batch_Products  ,ItemCategories,Items  
Where Batch_Products.Product_Code = Items.Product_Code   
And Items.CategoryID = ItemCategories.CategoryID  
and Batch_Products.Product_Code =@ItemCode  
group by Batch_Products.Product_code,Category_Name,ProductName  
  
Fetch Next From getItemCode Into @ItemCode  
  
End  
Close getItemCode  
Deallocate getItemCode  
Select * from #Temp  
drop table #Temp  
  
Drop table #tmpMfr  
Drop table #tmpDiv  
Drop table #tmpPro  


