CREATE procedure [dbo].[spr_list_stockmovement_report_product] (@FROMDATE datetime,
							@TODATE datetime,
							@ITEMCODE nvarchar(15),
							@CORRECTED_DATE datetime,
							@NEXT_DATE datetime)
as
SELECT  Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = ProductName, 
	"Opening Quantity" = ISNULL(Opening_Quantity, 0), "Opening Value" = ISNULL(Opening_Value, 0),
	"Purchase" = 0,
	"Adjustments" = 0,
	"On Hand Qty" = CASE 
			when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Quantity FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND OpeningDetails.Product_Code = @ITEMCODE AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
			ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products WHERE Product_Code = Items.Product_Code AND Product_Code = @ITEMCODE), 0) + 
			(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND 
			(VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code))
			end,
	"On Hand Value" = CASE 
			when (@TODATE < @NEXT_DATE) THEN ISNULL((Select Opening_Value FROM OpeningDetails WHERE OpeningDetails.Product_Code = Items.Product_Code AND OpeningDetails.Product_Code = @ITEMCODE AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)
			ELSE ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0) FROM Batch_Products WHERE Product_Code = Items.Product_Code AND Product_Code = @ITEMCODE) + 
			(SELECT ISNULL(SUM(Pending * PurchasePrice), 0) FROM VanStatementDetail, VanStatementAbstract WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND 
			(VanStatementAbstract.Status & 128) = 0 And VanStatementDetail.Product_Code = Items.Product_Code))
			end,
	"Sales" = ISNULL((Select SUM(case InvoiceType when 4 then 0 - (isnull(Amount,0)) ELSE (isnull(Amount,0)) END) From InvoiceAbstract, InvoiceDetail 
		  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And (Status & 128) = 0 And InvoiceDate 
			  between @FROMDATE and @TODATE And InvoiceDetail.Product_Code = @ITEMCODE), 0)
FROM Items, OpeningDetails
WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND
	OpeningDetails.Opening_Date = @FROMDATE and Items.Product_Code = @ITEMCODE
