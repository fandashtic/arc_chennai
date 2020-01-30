Create procedure Sp_Get_DispatchDetail_MUOM_ITC(  
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
 "uomprice" = dispatchdetail.uomprice,  
 "OtherCG_Item" = IsNull(dispatchdetail.OtherCG_Item,0),  
 "SchemeID" = IsNull(dispatchdetail.SchemeID,0),  
 "Serial"=IsNull(dispatchdetail.serial,0),  
 "FreeSerial"=IsNull(dispatchdetail.freeserial,0),
 "SchemeType" = (Select IsNull(Schemes.SchemeType, 0) From  Schemes Where Schemes.SchemeID = dispatchDetail.SchemeID ),
 "MultipleSchemeid" =IsNull(dispatchdetail.MultipleSchemeid,''),  
 "MultipleSchemedetails" =IsNull(dispatchdetail.MultipleSchemedetails,''),  
 "MultipleSplCatSchemeID"=IsNull(dispatchdetail.MultipleSplCatSchemeID,''),  
 "MultipleSplCategorySchDetail" =IsNull(dispatchdetail.MultipleSplCategorySchDetail,''),
 "SPLFreeSerial" = IsNull(dispatchdetail.SPLCATSerial,''),
 "SpecialCategory" = IsNull(dispatchdetail.SpecialCategoryScheme,''),
 "GroupID" = (Select GroupID From v_mERP_ItemWithCG Where Product_Code = DispatchDetail.Product_Code),
  "TAXONSALES" =  Max(Isnull(TOQ_Sales,0))
 From dispatchDetail
 left outer join batch_products on  dispatchDetail.batch_Code = batch_products.batch_Code    
inner join  #tempDispatchDetails on DispatchDetail.DispatchID = #tempDispatchDetails.itemvalue  
 inner join items   on  items.Product_Code = DispatchDetail.Product_Code    

 GROUP BY DispatchDetail.Product_Code, DispatchDetail.Batch_Code,   
 batch_products.batch_number,DispatchDetail.SalePrice, DispatchDetail.FlagWord,  
 batch_products.PTS,batch_products.PTR,batch_products.Company_Price,  
 batch_products.ECP,dispatchdetail.uom, dispatchdetail.uomprice,  
 batch_products.ApplicableOn ,batch_products.PartOfPercentage,  
 dispatchdetail.OtherCG_Item,dispatchdetail.SchemeID,dispatchdetail.serial ,  
 dispatchdetail.freeserial ,dispatchdetail.MultipleSchemeid,
 dispatchdetail.MultipleSchemedetails,dispatchdetail.MultipleSplCatSchemeID,
 dispatchdetail.MultipleSplCategorySchDetail,dispatchdetail.SPLCATSerial,dispatchdetail.SpecialCategoryScheme
 order by dispatchdetail.serial 
  
drop table #tempDispatchDetails  
