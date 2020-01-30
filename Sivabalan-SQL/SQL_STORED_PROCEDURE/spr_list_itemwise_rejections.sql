CREATE PROCEDURE spr_list_itemwise_rejections(@PRODUCT nvarchar(15),
					      @FROMDATE datetime,
				       	      @TODATE datetime)
AS
SELECT  GRNAbstract.GRNID, 
"GRNID" = VoucherPrefix.Prefix + CAST(GRNAbstract.DocumentID AS nvarchar), 
GRNAbstract.GRNDate, "GRN Qty" = SUM(GRNDetail.QuantityReceived), "Rejected Qty" = SUM(GRNDetail.QuantityRejected)
FROM GRNAbstract, GRNDetail, VoucherPrefix
WHERE   GRNAbstract.GRNID = GRNDetail.GRNID AND 
	GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE
	AND GRNDetail.Product_code = @PRODUCT
	AND VoucherPrefix.TranID = 'GOODS RECEIVED NOTE'
	AND (GRNAbstract.GRNStatus & 64) = 0
	AND (GRNAbstract.GRNStatus & 32) = 0
GROUP BY GRNAbstract.GRNID, GRNAbstract.DocumentID, GRNAbstract.GRNDate, 
VoucherPrefix.Prefix, GRNDetail.Product_Code
HAVING SUM(GRNDetail.QuantityRejected) > 0
