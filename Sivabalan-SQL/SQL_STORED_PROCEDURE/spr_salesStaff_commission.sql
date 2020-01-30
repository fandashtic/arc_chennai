CREATE PROCEDURE [dbo].[spr_salesStaff_commission](@SALESMAN_NAME nvarchar(2550),  
      @FROMDATE DATETIME,    
      @TODATE DATETIME)    
AS    
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Declare @MLOthers NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)

create table #tmpSale(Salesman_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @SALESMAN_NAME='%'  
   insert into #tmpSale select salesman_name from salesman  
else  
   insert into #tmpSale select * from dbo.sp_SplitIn2Rows(@SALESMAN_NAME ,@Delimeter)  
  
-- DECLARE @SalesmanID int  
-- Select @SalesmanID = SalesStaff.Staff_ID From SalesStaff Where Staff_Name = @SALESMAN_NAME  
IF @SALESMAN_NAME = '%'  
BEGIN  
SELECT isnull(InvoiceAbstract.SalesmanID, 0),  
 "Sales Staff" = case isnull(InvoiceAbstract.SalesmanID, 0 ) when 0 then @MLOthers else Salesman.Salesman_Name end,     
 "Goods Value (%c)" = Sum(Case When InvoiceType In (2) Then IsNull((InvoiceAbstract.GoodsValue), 0)
                               When InvoiceType In (5, 6) Then -1 * IsNull((InvoiceAbstract.GoodsValue), 0) End),  
 "Discount (%c)" = Sum(Case When InvoiceType In (2) Then IsNull(DiscountValue, 0) + IsNull(ProductDiscount, 0)
							When InvoiceType In (5, 6) Then -1 * IsNull(DiscountValue, 0) + IsNull(ProductDiscount, 0) End),  
 "Net Value (%c)" = Sum(Case When InvoiceType In (2) Then NetValue
							 When InvoiceType In (5, 6) Then -1 * NetValue End),  
 "Commission(GV) (%c)" = Sum(Case When InvoiceType In (2) Then Cast((GoodsValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6))
								  When InvoiceType In (5, 6) Then -1 * Cast((GoodsValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6)) End),  
 "Commission(NV) (%c)" = Sum( Case When InvoiceType In (2) Then Cast((NetValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6))  
							       When InvoiceType In (5, 6) Then -1 * Cast((NetValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6)) End)
FROM InvoiceAbstract
Left Outer Join Salesman on InvoiceAbstract.SalesmanID = Salesman.SalesManID
WHERE InvoiceType In (2, 5, 6) AND  
 (InvoiceAbstract.Status & 128) = 0 AND    
 --InvoiceAbstract.SalesmanID *= Salesman.SalesManID AND    
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And  
 SalesMan.SalesMan_Name In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)   
GROUP BY InvoiceAbstract.SalesmanID, SalesMan.SalesMan_Name  
END  
ELSE  
BEGIN  
SELECT  isnull(InvoiceAbstract.SalesmanID, 0),   
 "Salesman" = case isnull(InvoiceAbstract.SalesmanID, 0 ) when 0 then @MLOthers else SalesMan.SalesMan_Name end,     
 "Goods Value (%c)" = Sum(Case When InvoiceType In (2) Then IsNull((InvoiceAbstract.GoodsValue), 0)
                               When InvoiceType In (5, 6) Then -1 * IsNull((InvoiceAbstract.GoodsValue), 0) End),  
--Sum(GoodsValue),  
 "Discount (%c)" = Sum(Case When InvoiceType In (2) Then IsNull(DiscountValue, 0) + IsNull(ProductDiscount, 0)
							When InvoiceType In (5, 6) Then -1 * IsNull(DiscountValue, 0) + IsNull(ProductDiscount, 0) End), 
--Sum(IsNull(DiscountValue, 0) + IsNull(ProductDiscount, 0)),  
 "Net Value (%c)" = Sum(Case When InvoiceType In (2) Then NetValue
							 When InvoiceType In (5, 6) Then -1 * NetValue End),  
--Sum(NetValue),  
 "Commission(GV) (%c)" = Sum(Case When InvoiceType In (2) Then Cast((GoodsValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6))
								  When InvoiceType In (5, 6) Then -1 * Cast((GoodsValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6)) End),  
--Cast(Sum(GoodsValue * (IsNull(SalesMan.Commission, 0) / 100)) as Decimal(18,6)),  
 "Commission(NV) (%c)" = Sum( Case When InvoiceType In (2) Then Cast((NetValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6))  
							       When InvoiceType In (5, 6) Then -1 * Cast((NetValue * (IsNull(Salesman.Commission, 0) / 100)) as Decimal(18,6)) End)
--Cast(Sum(NetValue * (IsNull(SalesMan.Commission, 0) / 100)) as Decimal(18,6))  
FROM InvoiceAbstract, SalesMan  
WHERE   InvoiceType In (2, 5, 6)AND    
 (InvoiceAbstract.Status & 128) = 0 AND    
 InvoiceAbstract.SalesmanID = SalesMan.SalesManID AND    
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And  
 SalesMan.Salesman_Name In (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)   
GROUP BY InvoiceAbstract.SalesmanID,  SalesMan.SalesMan_Name  
END
drop table #tmpSale
