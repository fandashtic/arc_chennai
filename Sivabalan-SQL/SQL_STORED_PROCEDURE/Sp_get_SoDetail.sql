CREATE procedure Sp_get_SoDetail(@SONo nvarchar(255) )
as
Select * into #tempSc from dbo.sp_splitin2rows(@sono,',')

Select SODetail.Product_Code, SoDetail.Batch_Number,soDetail.SalePrice ,
	sum(SODetail.Pending), Sodetail.Ecp,Sodetail.Discount, TaxApplicableOn,TaxPartOff,
	TaxSuffApplicableOn,TaxSuffPartOff ,sodetail.saletax,sodetail.taxsuffered 
	From SODetail,#tempSc WHERE SODetail.SONumber = #tempSc.itemvalue 
	GROUP BY SOdetail.serial,SODetail.Product_Code, SODetail.Batch_Number,
	SoDetail.SalePrice, Sodetail.Ecp,Sodetail.Discount, TaxApplicableOn,TaxPartOff,
	TaxSuffApplicableOn,TaxSuffPartOff,sodetail.saletax,sodetail.taxsuffered

drop table #tempSc 


