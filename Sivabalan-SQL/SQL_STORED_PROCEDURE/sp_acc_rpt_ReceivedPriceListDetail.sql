CREATE PROCEDURE sp_acc_rpt_ReceivedPriceListDetail(@ParamInfo nVarchar(256), @FromDate DateTime, @ToDate DateTime)
AS  
Declare @ProductHierarchy nVarchar(255)      
Declare @Category nVarchar(255)      
Declare @DocumentID Int
Declare @StartPos Int      
Declare @NextPos Int      

Set @StartPos = CharIndex(N';', @ParamInfo)      
Set @ProductHierarchy = SubString(@ParamInfo, 1, @StartPos - 1)      
Set @NextPos = CharIndex(N';', @ParamInfo, @StartPos + 1)      
Set @Category = SubString(@ParamInfo, @StartPos + 1, @NextPos - @StartPos - 1)      
Set @DocumentID = Cast(SubString(@ParamInfo, @NextPos + 1, Len(@ParamInfo) - @NextPos) As Int)      

CREATE Table #TempCategory(CategoryID int, Status int)                
Exec GetLeafCategories @ProductHierarchy, @Category          

CREATE Table #Temp(ItemCode nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS , ItemName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS , PTS Decimal(18,6),
PTR Decimal(18,6), ECP Decimal(18,6), PurchasePrice Decimal(18,6), SalePrice Decimal(18,6),
MRP Decimal(18,6), SpecialPrice Decimal(18,6), TaxSuffered nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS , TaxApplicable nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )

Insert Into #Temp
Select I.Product_Code, I.ProductName, A.PTS, A.PTR, A.ECP, 
A.PurchasePrice, A.SalePrice, A.MRP, A.SpecialPrice, 
"Tax Suffered" =  (Select Tax_Description from Tax Where Tax_Code = I.TaxSuffered),
"Tax Applicable" = ( Select Tax_Description from Tax Where Tax_Code = I.Sale_Tax)
from ReceivePriceListItemDetail A, ReceivePriceListAbstract, Items I
Where A.ForumCode = I.Alias And A.ReceiveDocID = @DocumentID
And ReceivePriceListAbstract.ReceiveDocID = A.ReceiveDocID
And ReceivePriceListAbstract.PriceListDate Between @FromDate And @Todate
And I.CategoryID In (Select CategoryID from #TempCategory)

Select "Item Code" = ItemCode, "Item Code" = ItemCode, "Item Name" = ItemName, PTS, PTR, ECP, 
"Purchase Price (%c)" = PurchasePrice, "SalePrice (%c)" = SalePrice, MRP, "Special Price (%c)" = SpecialPrice,
"Tax Suffered" = IsNULL(TaxSuffered, N''), "Tax Applicable" = IsNULL(TaxApplicable,N'')
from #Temp

Drop Table #TempCategory
Drop Table #Temp



