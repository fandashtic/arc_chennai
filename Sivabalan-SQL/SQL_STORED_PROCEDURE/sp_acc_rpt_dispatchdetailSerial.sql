CREATE PROCEDURE [dbo].[sp_acc_rpt_dispatchdetailSerial](@DISPATCHID int)
AS
DECLARE @SPECIALCASE2 INT
SET @SPECIALCASE2=5

Create Table #SD
(
	Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
	DispatchID Int,
	Serial Int,
	MinBatch Int,
	MaxBatch Int,
	Quantity Decimal(18,6),
)

Insert into #SD
select Product_code, dispatchid,serial, min(batch_code) minbatch, max(batch_code) maxbatch, 
sum(quantity) qty 
from dispatchdetail  where dispatchid = @DISPATCHID 
group by serial,product_code,dispatchid
Order by Serial

SELECT  "Item Code" = DispatchDetail.Product_Code,
	"Item Name" = Items.ProductName,
	"From Serial" = replace(Batch_Products.batch_number, N',', char(9)) ,
	"To Serial" = 
		(case when virtual_track_batches = 1 then 
			replace((Select Batch_Products.Batch_Number From Batch_Products
				Where Batch_code = #SD.MaxBatch and
				Batch_Products.Product_Code =  #SD.Product_Code)
			, N',', char(9)) else '' end),
	"Quantity" = #SD.Quantity,
	"Sale Price" = DispatchDetail.SalePrice,@SPECIALCASE2
FROM DispatchDetail
Inner Join Items on DispatchDetail.Product_Code = Items.Product_Code
Left Join Batch_Products on DispatchDetail.Batch_Code = Batch_Products.Batch_Code
Inner Join #SD on isnull(#SD.MinBatch,0) = isnull(DispatchDetail.Batch_Code,0) and #SD.dispatchid = DispatchDetail.dispatchid and #SD.Product_Code = DispatchDetail.Product_Code

--DispatchDetail, Items, Batch_Products,#SD
WHERE   
	DispatchDetail.DispatchID = @DISPATCHID 
	--AND 
	--DispatchDetail.Product_Code = Items.Product_Code AND
	--DispatchDetail.Batch_Code *= Batch_Products.Batch_Code
	--And isnull(#SD.MinBatch,0) = isnull(DispatchDetail.Batch_Code,0)
	--And #SD.dispatchid = DispatchDetail.dispatchid
	--And #SD.Product_Code = DispatchDetail.Product_Code
-- -- -- GROUP BY DispatchDetail.Product_Code, Items.ProductName, Batch_Products.Batch_Number, DispatchDetail.SalePrice




