CREATE procedure [dbo].[sp_view_GRNDetail](@GRNID INT)

AS
SELECT GRNDetail.Product_Code, Items.ProductName, Sum(QuantityReceived),
Sum(QuantityRejected), ReasonRejected, N'',
0, Sum(QuantityReceived - QuantityRejected),
RejectionReason.Message, Sum(ISNULL(FreeQty, 0)),
GRNDetail.Serial
FROM GRNDetail, Items, RejectionReason
WHERE GRNDetail.GRNID = @GRNID 
AND GRNDetail.Product_Code = Items.Product_Code
AND GRNDetail.ReasonRejected *= RejectionReason.MessageID
GROUP BY GRNDetail.Product_Code, Items.ProductName, ReasonRejected, 
RejectionReason.Message, GRNDetail.Serial
Order By GRNDetail.Serial
