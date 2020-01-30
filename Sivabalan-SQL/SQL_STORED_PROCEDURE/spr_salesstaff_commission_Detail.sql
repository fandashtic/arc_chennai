CREATE procedure [dbo].[spr_salesstaff_commission_Detail](@SALESMANID Int,      
       @FROMDATE DATETIME,        
       @TODATE DATETIME)        
AS        
      
SELECT  dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),       
 "Date" = dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),      
 "Goods Value (%c)" = Sum(Case When InvoiceType In (2) Then IsNull((InvoiceAbstract.GoodsValue), 0)  
                               When InvoiceType In (5, 6) Then -1 * IsNull((InvoiceAbstract.GoodsValue), 0) End),    
--Sum(InvoiceDetail.SalePrice * InvoiceDetail.Quantity),          
 "Discount (%c)" = Sum(Case When InvoiceType In (2) Then IsNull(DiscountValue, 0) + IsNull(ProductDiscount, 0)  
       When InvoiceType In (5, 6) Then -1 * IsNull(DiscountValue, 0) + IsNull(ProductDiscount, 0) End),    
-- Sum(IsNull(InvoiceDetail.DiscountValue, 0) + 
-- 		(((InvoiceDetail.SalePrice * InvoiceDetail.Quantity) - 
-- 			IsNull(InvoiceDetail.DiscountValue, 0)) * InvoiceAbstract.DiscountPercentage) /100),        
 "Net Value (%c)" = Sum(Case When InvoiceType In (2) Then NetValue  
        When InvoiceType In (5, 6) Then -1 * NetValue End),    
--Sum(InvoiceDetail.Amount),      
 "Commission(GV) (%c)" = Sum(Case When InvoiceType In (2) Then Cast((GoodsValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6))  
          When InvoiceType In (5, 6) Then -1 * Cast((GoodsValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6)) End),    
--Cast(Sum((InvoiceDetail.SalePrice * InvoiceDetail.Quantity) * (IsNull(SalesMan.Commission, 0) / 100)) as Decimal(18,6)),      
 "Commission(NV) (%c)" = Sum( Case When InvoiceType In (2) Then Cast((NetValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6))    
              When InvoiceType In (5, 6) Then -1 * Cast((NetValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6)) End)  
--Cast(Sum(InvoiceDetail.Amount * (IsNull(SalesMan.Commission, 0) / 100)) as Decimal(18,6))      
FROM InvoiceAbstract, SalesMan    
WHERE InvoiceType In (2, 5, 6) AND    
 (InvoiceAbstract.Status & 128) = 0 AND        
 InvoiceAbstract.SalesmanID *= SalesMan.SalesManID AND
 InvoiceAbstract.SalesmanID = @SALESMANID AND        
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE      
GROUP BY dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)
