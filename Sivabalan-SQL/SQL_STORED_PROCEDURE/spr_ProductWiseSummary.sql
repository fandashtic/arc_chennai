CREATE PROCEDURE [dbo].[spr_ProductWiseSummary] (@DATE DATETIME)                
	As 
		Begin
			Set DateFormat DMY

			CREATE TABLE #Temp(
				Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
				Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
				GrossAmount decimal(18, 6) NULL,
				Discount decimal(18, 6) NULL,
				SCP decimal(18, 6) NULL,
				SalesTaxValue decimal(18, 6) NOT NULL,
				Total decimal(18, 6) NULL,
				PaymentMode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
			)

			CREATE TABLE #Tempsales(
				Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
				Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
				GrossAmount decimal(18, 6) NULL,

				Discount decimal(18, 6) NULL,
				SalesTaxValue decimal(18, 6) NOT NULL,
				Total decimal(18, 6) NULL,
				PaymentMode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
			)

--			CREATE TABLE #TempFinel
--			(	Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
--				GrossAmount decimal(18, 6) NULL,
--				Discount decimal(18, 6) NULL,
--				SalesTaxValue decimal(18, 6) NOT NULL,
--				Total decimal(18, 6) NULL,
--				PaymentMode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
--			)

CREATE TABLE #TempFinel
			(	Category nvarchar(255),
				GrossAmount decimal(18, 6) NULL,
				Discount decimal(18, 6) NULL,
				SalesTaxValue decimal(18, 6) NOT NULL,
				Total decimal(18, 6) NULL,
				PaymentMode nvarchar(255)
			)

			Create Table #TempOut (
			Category Nvarchar(255),
			Cashvalue Decimal(18,6) Default 0,
			CashDiscount Decimal(18,6) Default 0,
			CashGrossvalue Decimal(18,6) Default 0,
			CashVat Decimal(18,6) Default 0,
			NetCashTotal Decimal(18,6) Default 0,
			Creditvalue Decimal(18,6) Default 0,
			CreditDiscount Decimal(18,6) Default 0,
			CreditGrossvalue Decimal(18,6) Default 0,
			CreditVat Decimal(18,6) Default 0,
			NetCreditTotal Decimal(18,6) Default 0,
			Netvalue Decimal(18,6) Default 0,
		
	NetDiscount Decimal(18,6) Default 0,
			NetGrossvalue Decimal(18,6) Default 0,
			NetVat Decimal(18,6) Default 0,
			NetAmount Decimal(18,6) Default 0)


			Insert Into #Temp   
			SELECT distinct InvoiceDetail.Product_Code,
			"Category" = Brand.BrandName,  
			(InvoiceDetail.SalePrice * Items.ReportingUnit)*(SUM( InvoiceDetail.Quantity / Items.ReportingUnit)),  

			Sum(IsNull(InvoiceDetail.SCHEMEDISCAMOUNT, 0) + IsNull(InvoiceDetail.SPLCATDISCAMOUNT, 0)),  

			Sum(IsNull(InvoiceDetail.DiscountValue, 
0) - (IsNull(InvoiceDetail.SCHEMEDISCAMOUNT, 0) +   IsNull(InvoiceDetail.SPLCATDISCAMOUNT, 0))),  

			Isnull(Sum(InvoiceDetail.STPayable + InvoiceDetail.CSTPayable), 0) ,   

			Round(SUM(InvoiceDetail.Amount),2),

			InvoiceAbstract.PaymentMode   

			FROM InvoiceDetail,Items ,Brand   , InvoiceAbstract
			WHERE InvoiceDetail.Product_Code = Items.Product_Code And  
			InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And
--			InvoiceAbstract.InvoiceDate BETWEEN @DATE AND @DATE AND  
			DAY(InvoiceAbstract.InvoiceDate) = dAY(@DATE) AND Month(InvoiceAbstract.InvoiceDate) = Month(@date) and Year(InvoiceAbstract.InvoiceDate) = Year(@date) and
--			dbo.stripTimeFromdate(InvoiceAbstract.InvoiceDate)In (@DATE) AND  
			InvoiceAbstract.PaymentMode IN  (Select 
Paymentterm.mode from Paymentterm where Paymentterm.value like '%') 
			And (InvoiceAbstract.Status & 128) = 0 AND  
			InvoiceAbstract.InvoiceType in (1,3) AND  
			Items.BrandID = Brand.BrandID      
			GROUP BY Brand.BrandName,InvoiceDetail.Product_Code, Items.ProductName,InvoiceDetail.SalePrice,Items.ReportingUnit,InvoiceDetail.SalePrice  ,InvoiceAbstract.PaymentMode
			order by Brand.BrandName  


			Insert into #Tempsales
			select Distinct CateGory,Product_Code,Sum(GrossAmount),Sum(Discount + SCP),
 Sum(SalesTaxValue),Sum(Total),PaymentMode from #temp Group by Category,Product_Code,PaymentMode

			Insert into #TempFinel  
			select CateGory,Sum(GrossAmount),Sum(Discount), Sum(SalesTaxValue),Sum(Total),PaymentMode 
from #Tempsales Group by Category,PaymentMode


			Insert into #TempOut (CateGory) select Distinct CateGory From #TempFinel

			Update T set T.CashValue = T1.GrossAmount, T.CashDiscount = T1.Discount, T.CashGrossValue = (T1.GrossAmount - T1.Discount), T.CashVat = T1.SalesTaxValue, T.NetCashTotal = T1.Total
			From #TempOut T, (select Distinct CateGory,GrossAmount,Discount,SalesTaxValue,Total From #TempFinel Where PaymentMode = 1) T1
			Where T.CateGory = T1.CateGory

			Update T set T.CreditValue = T1.GrossAmount, T.CreditDiscount = T1.Discount, T.CreditGrossValue = (T1.GrossAmount - T1.Discount), T.CreditVat = T1.SalesTaxValue, T.NetCreditTotal = T1.Total
			From #TempOut T, (select Distinct CateGory,GrossAmount,Discount,SalesTaxValue,Total From #TempFinel Where PaymentMode = 0) T1
			Where T.CateGory = T1.CateGory

			Update #TempOut set NetValue = CashValue + CreditValue ,
			NetDiscount = CashDiscount + CreditDiscount, 
			NetGrossValue = CashGrossValue + CreditGrossValue, 
			NetVat = CashVat + CreditVat, 
			NetAMOUNT = NetCashTotal +
 NetCreditTotal

			select 1, * from #TempOut Order by 1 asc

			Drop table #temp
			Drop table #Tempsales
			Drop table #TempFinel
			Drop table #TempOut
		End
