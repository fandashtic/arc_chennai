CREATE PROCEDURE [dbo].[spr_salesman_commission](@SALESMAN_NAME nvarchar(2550),
					 @COMMISSION Decimal(18,6),
					 @FROMDATE DATETIME,  
					 @TODATE DATETIME)  
AS  

Declare @Others nVarchar(20)
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)
set @Others = dbo.LookupDictionaryItem('Others',default)
create table #tmpSale(Salesman_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @SALESMAN_NAME='%'
   insert into #tmpSale select Salesman_Name from Salesman
else
   insert into #tmpSale select * from dbo.sp_SplitIn2Rows(@SALESMAN_NAME ,@Delimeter)

-- DECLARE @SalesmanID int
-- Select @SalesmanID = IsNull(SalesmanID,0) From Salesman Where Salesman_Name = @SALESMAN_NAME
IF @SALESMAN_NAME = '%'
BEGIN
SELECT  cast(isnull(InvoiceAbstract.SalesmanID, 0) as nvarchar) + ';' + Cast(@COMMISSION As nVarchar), 
 "Salesman" = case isnull(InvoiceAbstract.SalesmanID, 0 ) when 0 then @Others else Salesman.Salesman_Name end,   
 "Goods Value (%c)" = Sum(Case InvoiceType When 4 Then 0 Else SalePrice * Quantity End),
 "Discount (%c)" = Cast(Sum((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) * InvoiceDetail.DiscountPercentage / 100) 
		   + ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) - ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) 
		   * InvoiceDetail.DiscountPercentage / 100))) * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100)) as Decimal(18,6)), 
 "Sales Return Saleable (%c)" = Sum(case When InvoiceType = 4 And (Status & 32) = 0 Then Amount Else 0 End),
 "Net Value (%c)" = Sum(Case When InvoiceType = 4 And (Status & 32) = 0 Then 0 - Amount When InvoiceType <> 4 Then Amount Else 0 End) - 
		    Sum(Case InvoiceType When 4 Then 0 Else 
			Amount - (SalePrice * Quantity) - (IsNull(STPayable,0) + IsNull(CSTPayable,0)) + 
			((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) * InvoiceDetail.DiscountPercentage / 100) 
			+ ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) - ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) 
			* InvoiceDetail.DiscountPercentage / 100))) * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100))
			End) - 
			Sum(Case InvoiceType When 4 Then 0 Else (IsNull(STPayable,0) + IsNull(CSTPayable,0)) End),
 "Commission (%c)" = Cast((Sum(Case When InvoiceType = 4 And (Status & 32) = 0 Then 0 - Amount When InvoiceType <> 4 Then Amount Else 0 End) - 
		     Sum(Case InvoiceType When 4 Then 0 Else 
			Amount - (SalePrice * Quantity) - (IsNull(STPayable,0) + IsNull(CSTPayable,0)) + 
			((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) * InvoiceDetail.DiscountPercentage / 100) 
			+ ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) - ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) 
			* InvoiceDetail.DiscountPercentage / 100))) * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100))
			End) - 
			Sum(Case InvoiceType When 4 Then 0 Else (IsNull(STPayable,0) + IsNull(CSTPayable,0)) End)) * @COMMISSION / 100 As Decimal(18,6))
FROM InvoiceAbstract
Left Outer Join Salesman on InvoiceAbstract.SalesmanID = Salesman.SalesmanID
Inner Join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
WHERE InvoiceType in (1, 3, 4) AND
 (InvoiceAbstract.Status & 128) = 0 AND  
 --InvoiceAbstract.SalesmanID *= Salesman.SalesmanID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 --InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
 Salesman.Salesman_Name In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale) 
GROUP BY InvoiceAbstract.SalesmanID,  Salesman.Salesman_Name  
END
ELSE
BEGIN
SELECT  cast(isnull(InvoiceAbstract.SalesmanID, 0) as nvarchar) + ';' + Cast(@COMMISSION As nVarchar), 
 "Salesman" = case isnull(InvoiceAbstract.SalesmanID, 0 ) when 0 then @Others else Salesman.Salesman_Name end,   
 "Goods Value (%c)" = Sum(Case InvoiceType When 4 Then 0 Else SalePrice * Quantity End),
 "Discount (%c)" = Cast(Sum((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) * 
		   InvoiceDetail.DiscountPercentage / 100) + ((SalePrice * (Case InvoiceType When 4 then 0 
		   Else Quantity End) - ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) * 
		   InvoiceDetail.DiscountPercentage / 100))) * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100)) as Decimal(18,6)), 
 "Sales Return Saleable (%c)" = Sum(case When InvoiceType = 4 And (Status & 32) = 0 Then Amount Else 0 End),
 "Net Value (%c)" = Sum(Case When InvoiceType = 4 And (Status & 32) = 0 Then 0 - Amount When InvoiceType <> 4 Then Amount Else 0 End) - 
		    Sum(Case InvoiceType When 4 Then 0 Else 
			Amount - (SalePrice * Quantity) - (IsNull(STPayable,0) + IsNull(CSTPayable,0)) + 
			((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) * InvoiceDetail.DiscountPercentage / 100) 
			+ ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) - ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) 
			* InvoiceDetail.DiscountPercentage / 100))) * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100))
			End) - 
			Sum(Case InvoiceType When 4 Then 0 Else (IsNull(STPayable,0) + IsNull(CSTPayable,0)) End),
 "Commission (%c)" = Cast((Sum(Case When InvoiceType = 4 And (Status & 32) = 0 Then 0 - Amount When InvoiceType <> 4 Then Amount Else 0 End) - 
		     Sum(Case InvoiceType When 4 Then 0 Else 
			Amount - (SalePrice * Quantity) - (IsNull(STPayable,0) + IsNull(CSTPayable,0)) + 
			((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) * InvoiceDetail.DiscountPercentage / 100) 
			+ ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) - ((SalePrice * (Case InvoiceType When 4 then 0 Else Quantity End) 
			* InvoiceDetail.DiscountPercentage / 100))) * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100))
			End) - 
			Sum(Case InvoiceType When 4 Then 0 Else (IsNull(STPayable,0) + IsNull(CSTPayable,0)) End)) * @COMMISSION / 100 As Decimal(18,6))
FROM InvoiceAbstract, Salesman, InvoiceDetail
WHERE   InvoiceType in (1, 3, 4) AND  
 (InvoiceAbstract.Status & 128) = 0 AND  
 InvoiceAbstract.SalesmanID = Salesman.SalesmanID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
 Salesman.Salesman_Name In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale) 
GROUP BY InvoiceAbstract.SalesmanID,  Salesman.Salesman_Name  
END
drop table #tmpSale
