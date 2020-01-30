CREATE PROCEDURE spr_salesman_commission_Detail(@SALESMAN nvarchar(50),
						 @FROMDATE DATETIME,  
						 @TODATE DATETIME)  
AS  
DECLARE @SALESMANID int
DECLARE @Index int
DECLARE @COMMISSION Decimal(18,6)

SET @Index = Charindex(';', @SALESMAN)
SET @SALESMANID = cast(substring(@SALESMAN, 1, @Index - 1) as int)
SET @COMMISSION = cast(substring(@SALESMAN, @Index + 1, 100) as Decimal(18,6))
SELECT  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), 
 "Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),
 "Goods Value (%c)" = Cast(Sum(Case InvoiceType When 4 Then 0 Else SalePrice * Quantity End) As Decimal(18,6)),
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
FROM InvoiceAbstract, InvoiceDetail
WHERE InvoiceType in (1, 3, 4) AND
 (InvoiceAbstract.Status & 128) = 0 AND  
 InvoiceAbstract.SalesmanID = @SALESMANID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
GROUP BY dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)
