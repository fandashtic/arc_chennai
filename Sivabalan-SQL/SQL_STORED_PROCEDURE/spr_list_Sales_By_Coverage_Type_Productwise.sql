CREATE procedure [dbo].[spr_list_Sales_By_Coverage_Type_Productwise]      
(       
@Product_Hierarchy nvarchar(256),       
@Category nvarchar(2550),       
@FromDate DateTime,       
@ToDate DateTime      
 )      
AS      
DECLARE @AlterSQL nvarchar(4000)                    
DECLARE @UpdateSQL nvarchar(4000)       
Declare @ProdCode as nvarchar(255)      
Declare @City as nvarchar(255)      
Declare @City1 as nvarchar(255)      
Declare @TempCity as nvarchar(255)      
Declare @SaleCount as Integer 
     
Declare @OTHERS As NVarchar(50)      
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)

Create Table #tempCategory(CategoryID int,   --Table Used for Product hierachy Filter      
      Status int)      
      
Exec dbo.GetLeafCategories @Product_Hierarchy, @Category  -- Stores CategoryID to Temp Table #tempCategory      
      
-- Sold Products stored in a temp table      
Create Table #TownSales (TempProd nvarchar(255), ProductCode nvarchar(255))       
Insert into #TownSales (TempProd, ProductCode)       
select Distinct DispatchDetail.Product_Code, DispatchDetail.Product_Code      
From DispatchDetail, DispatchAbstract, Items     
Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID      
and DispatchDetail.Product_Code = Items.Product_Code    
and DispatchDate between @FromDate and @ToDate      
and Isnull(Status & 64,0) = 0      
and Items.CategoryID In (Select CategoryID From #tempCategory)       
Group By DispatchDetail.Product_Code      
      
-- Productwise Outlets are stored in a cursor      
Declare TownSales Cursor For      
select Distinct Items.Product_Code, Isnull(City.CityName, @OTHERS), Count(Distinct DispatchAbstract.DispatchID), isnull(City.CityName, N'zzzzz')      
From DispatchDetail, DispatchAbstract, City, Customer, Items      
Where Customer.CityID *= City.CityID      
and DispatchDetail.Product_Code = Items.Product_Code      
and DispatchAbstract.CustomerID = Customer.CustomerID      
and DispatchAbstract.DispatchID = DispatchDetail.DispatchID      
and DispatchDate between @FromDate and @ToDate      
and Isnull(Status & 64,0) = 0      
and Items.CategoryID In (Select CategoryID From #tempCategory)       
Group By Items.Product_Code, City.CityName      
order by 4      
      
Set @TempCity = N''      
OPEN TownSales      
FETCH FROM TownSales Into @ProdCode, @City, @SaleCount, @City1      
WHILE @@FETCH_STATUS = 0                    
BEGIN           
 If (Isnull(@TempCity,N'') <> Isnull(@City, N'')) OR (isnull(@TempCity, N'') = N'')      
 Begin      
-- Town name are added as a columns to temp table      
  SET @AlterSQL = N'ALTER TABLE #TownSales Add [' + @City +  '] Integer null'           
  EXEC sp_executesql @AlterSQL        
  Set @TempCity = isnull(@City, N'')      
 End       
-- Outlet updated to temp table      
 SET @UpdateSQL = N'Update #TownSales Set [' + @City + '] = N''' + cast (@SaleCount as nvarchar) + ''' Where ProductCode collate SQL_Latin1_General_Cp1_CI_AS = N'''+ @ProdCode + ''''      
 exec sp_executesql @UpdateSQL       
FETCH NEXT FROM TownSales Into @ProdCode, @City, @SaleCount, @City1      
END      
      
select * from #TownSales      
Close TownSales      
Deallocate TownSales      
Drop Table #TownSales      
Drop Table #tempCategory
