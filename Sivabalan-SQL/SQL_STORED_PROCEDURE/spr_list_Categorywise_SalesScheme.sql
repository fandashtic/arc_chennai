CREATE Procedure spr_list_Categorywise_SalesScheme  
(   
@ProductHierarchy nvarchar(256),   
@Category nvarchar(256),   
@FromDate DateTime,   
@ToDate DateTime  
 )  
AS  
  
Declare @Given_Date DateTime  
Declare @Today DateTime  
  
Select @Given_Date = dbo.StripDatefromTime(@FromDate)   
Select @Today = dbo.StripDatefromTime (getdate())   
  
Declare @UpdateSQL nvarchar(4000)  
Declare @ComputeSQL nvarchar(4000)  
Declare @AlterSQL nvarchar(4000)  
Declare @Trans nvarchar(255)  
Declare @Brand nvarchar(255)  
Declare @Amount Decimal(18,6)  
Declare @Cost Decimal(18,6)  
Declare @Claimed Decimal(18,6)  
  
  
Create Table #FinalBrand (DescName nvarchar(255))   
Insert Into #FinalBrand ([DescName]) Values (N'Total Purchase')   
Insert Into #FinalBrand ([DescName]) Values (N'Total Sales')  
Insert Into #FinalBrand ([DescName]) Values (N'Closing Stock')  
Insert Into #FinalBrand ([DescName]) Values (N'Sales Under Scheme')  
Insert Into #FinalBrand ([DescName]) Values (N'Cost of Scheme')  
Insert Into #FinalBrand ([DescName]) Values (N'Total Claimed Amount')  
Insert Into #FinalBrand ([DescName]) Values (N'% Scheme Claimed')  
  
  
Create Table #tempCategory (CategoryID int, Status int)                
Exec GetLeafCategories @ProductHierarchy, @Category              
  
--"Total Purchase" =   
DECLARE Brand_Cursor CURSOR FOR   
select N'Total Purchase', BrandName, Sum(Isnull(BillDetail.Amount, 0) + Isnull(BillDetail.TaxAmount, 0) + Isnull(BillAbstract.AdjustmentAmount, 0))   
from Brand, BillDetail, BillAbstract, Items, ItemCategories  
Where Brand.BrandID = Items.BrandID  
AND BillDetail.Product_Code = Items.Product_Code  
AND BillAbstract.BillID = BillDetail.BillID  
AND (Isnull(BillAbstract.Status, 0) & 128) = 0   
AND Billabstract.BillDate between @FromDate and @ToDate    
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)       
AND ItemCategories.CategoryID = Items.CategoryID  
Group by BrandName  
Union  
  
--"Total Sales" =    
(Select N'Total Sales', BrandName, ISNULL(sum(Isnull(Amount, 0)), 0)  
from invoicedetail,InvoiceAbstract, Brand, Items, ItemCategories  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE  
AND (Isnull(InvoiceAbstract.Status, 0) & 128) = 0   
AND InvoiceAbstract.InvoiceType in (1,2,3)  
AND Brand.BrandID = Items.BrandID  
AND ItemCategories.CategoryID = Items.CategoryID   
AND InvoiceDetail.Product_Code = Items.Product_Code  
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)  
Group by BrandName)  
Union  
--"Closing Stock" =   
  
Select N'Closing Stock', Brand.BrandName, Sum(Cast((Case ItemCategories.Price_Option  
When 0 Then  
Cast((Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Cast((isnull(Quantity, 0) * Items.Purchase_Price) as Decimal(18,6)) Else 0 End)as Decimal(18,6))    
Else  
Cast((Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Cast((Isnull(Quantity, 0) * Batch_Products.PurchasePrice) as Decimal(18,6)) Else 0 End) as Decimal(18,6))  
End) as Decimal(18,6)))  
From Batch_Products, Items, ItemCategories, Brand  
Where Items.CategoryID = ItemCategories.CategoryID  
AND Batch_Products.Product_Code = Items.Product_Code  
AND Items.BrandID = Brand.BrandID  
and Batch_Products.CreationDate <= @ToDate  
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)   
and @Given_Date = @Today  
Group by Brand.BrandName  
Union  
  
Select N'Closing Stock', Brand.BrandName, Sum(Opening_Value)  
From OpeningDetails, Items, Brand  
Where OpeningDetails.Product_Code = Items.Product_Code  
AND Items.BrandID = Brand.BrandID  
AND OpeningDetails.Opening_Date = DateAdd(day,1,@ToDate)   
and @Given_Date <> @Today  
Group by Brand.BrandName  
  
Union  
  
Select N'Sales Under Scheme', Brand.BrandName, isnull(Sum(Isnull(InvoiceDetail.Amount, 0)), 0)   
From (Select Distinct Brand.BrandName, InvoiceDetail.InvoiceID  
From InvoiceAbstract, InvoiceDetail, Items, ItemCategories, Brand  
Where Items.CategoryID = ItemCategories.CategoryID  
AND InvoiceDetail.Product_Code = Items.Product_Code  
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
AND (Isnull(InvoiceAbstract.Status, 0) & 128) = 0   
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)    
AND InvoiceDate Between @FromDate And @ToDate  
AND Items.BrandID = Brand.BrandID  
AND (isnull(InvoiceDetail.SchemeID, 0) <> 0 OR isnull(InvoiceDetail.SplCatSchemeID, 0) <> 0)  
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)  
) B, InvoiceDetail, Brand  
Where InvoiceDetail.InvoiceID = B.InvoiceID  
AND B.BrandName = Brand.BrandName  
Group by Brand.BrandName  
  
Union  
Select N'Cost of Scheme', Brand.BrandName, isnull(Sum(Isnull(SchemeSale.Cost, 0)), 0)   
From (Select Distinct Brand.BrandName, InvoiceDetail.InvoiceID  
From InvoiceAbstract, InvoiceDetail, Items, ItemCategories, Brand  
Where Items.CategoryID = ItemCategories.CategoryID  
AND InvoiceDetail.Product_Code = Items.Product_Code  
AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
AND (Isnull(InvoiceAbstract.Status, 0) & 128) = 0   
AND SalePrice = 0   
AND InvoiceDate Between @FromDate And @ToDate  
AND Items.BrandID = Brand.BrandID  
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)  
) B, SchemeSale, Brand, Schemes  
Where SchemeSale.InvoiceID = B.InvoiceID  
AND Schemes.SchemeID = SchemeSale.Type  
AND Schemes.SchemeType in (17, 18)  
AND B.BrandName = Brand.BrandName  
Group by Brand.BrandName  
Union   
Select N'Total Claimed Amount', Brand.BrandName, isnull(Sum(isnull(ClaimsNote.ClaimValue, 0)), 0)   
From ClaimsNote, ClaimsDetail, Brand, Items, ItemCategories, Schemes   
Where ClaimDate Between @FromDate And @ToDate  
AND ClaimsNote.ClaimID = ClaimsDetail.ClaimID  
AND ClaimsDetail.Product_Code = Items.Product_Code  
AND ClaimsDetail.SchemeType = Schemes.SchemeID  
AND ItemCategories.CategoryID in (Select CategoryID from #tempCategory)  
AND Items.CategoryID = ItemCategories.CategoryID  
AND Items.BrandID = Brand.BrandID   
AND ClaimsNote.ClaimType = 4  
AND Schemes.SchemeType in (17,18)  
Group by Brand.BrandName  
  
Declare Brand Cursor For  
Select BrandName from Brand  
  
Open Brand  
FETCH FROM Brand Into @Brand  
WHILE @@FETCH_STATUS = 0                
BEGIN    
  
 SET @AlterSQL = N'ALTER TABLE #FinalBrand Add [' + dbo.EncodeQuotes(@Brand) +  N'] Decimal(18,6) null'                 
 EXEC sp_executesql @AlterSQL  
  
FETCH NEXT FROM Brand Into @Brand     
END  
  
Close Brand  
  
OPEN Brand_Cursor  
FETCH FROM Brand_Cursor Into @Trans, @Brand, @Amount      
WHILE @@FETCH_STATUS = 0                
BEGIN    
  
 SET @UpdateSQL = N'Update #FinalBrand Set [' + dbo.EncodeQuotes(@Brand) + N'] = ' + cast (@Amount as nvarchar) + N' Where DescName collate SQL_Latin1_General_Cp1_CI_AS = N''' + @Trans  + ''''          
 exec sp_executesql @UpdateSQL    
  
FETCH NEXT FROM Brand_Cursor Into @Trans, @Brand, @Amount      
END  
OPEN Brand  
FETCH FROM Brand Into @Brand  
WHILE @@FETCH_STATUS = 0                
BEGIN    

  Set @ComputeSQL = N'Update #FinalBrand Set [' + dbo.EncodeQuotes(@Brand) + N'] =   
  ((Select Isnull([' + dbo.EncodeQuotes(@Brand)  + N'], 0) from #FinalBrand Where DescName = ''Total Claimed Amount'') /   
  (Select Case  isnull([' + dbo.EncodeQuotes(@Brand)  + N'], 0) When 0 Then 1 Else [' + dbo.EncodeQuotes(@Brand)  + N'] End  from #FinalBrand Where Descname =  ''Cost of Scheme''))      
  Where DescName = ''% Scheme Claimed'''  
--  Select @ComputeSQL  
  Exec sp_executesql @ComputeSQL  
  
FETCH NEXT FROM Brand Into @Brand  
END  
  
Select DescName, * from #FinalBrand   
  
Drop Table #tempCategory  
Drop Table #FinalBrand  
Close Brand_Cursor              
DeAllocate Brand_Cursor  
Close Brand              
DeAllocate Brand  
  
  
  


