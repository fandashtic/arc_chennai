CREATE procedure [dbo].[Sp_Get_DispatchDetail_MUOM](
	@DispatchNo nVarchar(255))
as 

Select * into #tempDispatchDetails from dbo.sp_splitin2rows(@DispatchNo,',')

Select DispatchDetail.Product_Code,
	"Quantity" = isnull(SUM(DispatchDetail.Quantity),0), 
	"SalePrice" = DispatchDetail.SalePrice, 
	"batch_number" = batch_Products.batch_number , 
	"Flagword" = DispatchDetail.Flagword, 
	"Batch_Code" = DispatchDetail.Batch_Code, 0 ,
	"PTS" = batch_products.PTS,
	"PTR" = batch_products.PTR,
	"Company_Price" = batch_products.Company_Price,
	"ECP" = batch_products.ECP,
	"ApplicableOn" = batch_products.ApplicableOn ,
	"PartOff" = batch_products.PartOfPercentage ,
	"uom" = dispatchdetail.uom, 
	"uomprice" = dispatchdetail.uomprice
	From dispatchDetail
	Left Outer Join #tempDispatchDetails on dispatchDetail.batch_Code = batch_products.batch_Code
	Inner Join batch_products on DispatchDetail.DispatchID = #tempDispatchDetails.itemvalue	
	--WHERE DispatchDetail.DispatchID = #tempDispatchDetails.itemvalue and 
	--dispatchDetail.batch_Code *= batch_products.batch_Code 
	GROUP BY DispatchDetail.Product_Code, DispatchDetail.Batch_Code, 
	batch_products.batch_number,DispatchDetail.SalePrice, DispatchDetail.FlagWord,
	batch_products.PTS,batch_products.PTR,batch_products.Company_Price,
	batch_products.ECP,dispatchdetail.uom, dispatchdetail.uomprice,
	batch_products.ApplicableOn ,batch_products.PartOfPercentage 

drop table #tempDispatchDetails


