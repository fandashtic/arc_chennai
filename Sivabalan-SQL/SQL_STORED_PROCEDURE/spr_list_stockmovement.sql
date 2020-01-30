
CREATE PROCEDURE spr_list_stockmovement(@FROM_DATE datetime,
					@TO_DATE datetime)
AS
Select items.product_Code,Items.ProductName,
"Opening Balance"=(Select ISNULL(Opening_Quantity,0) from OpeningDetails where Opening_Date=@FROM_DATE and items.product_Code=OpeningDetails.product_Code),
"Purchase" =(Select  SUM(ISNULL(QuantityReceived - QuantityRejected,0)) from grnDetail,grnAbstract where  GRNAbstract.GRNID = GRNDetail.GRNID and GRNAbstract.GRNDate BETWEEN @FROM_DATE AND @TO_DATE and GRNDetail.Product_code=items.product_Code),
"Sales" =(Select  SUM(ISNULL(Quantity,0)) from InvoiceDetail,InvoiceAbstract where  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and InvoiceAbstract.InvoiceDate BETWEEN @FROM_DATE AND @TO_DATE and InvoiceDetail.Product_code=items.product_Code),
"Adjustment" =(Select  SUM(ISNULL(Quantity,0)) from StockAdjustment,StockAdjustmentAbstract where  StockAdjustmentAbstract.AdjustmentID = StockAdjustment.SerialNo and StockAdjustmentAbstract.AdjustmentDate BETWEEN @FROM_DATE AND @TO_DATE and StockAdjustment.Product_code=items.product_Code),
"Closing balance"=(Select SUM(ISNULL(Quantity, 0)) from batch_Products where batch_Products.product_Code=Items.Product_Code)
from items 

