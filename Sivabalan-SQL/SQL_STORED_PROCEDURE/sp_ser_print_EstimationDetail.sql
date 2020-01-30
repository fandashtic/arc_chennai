CREATE Procedure sp_ser_print_EstimationDetail (@EstID as int)
as
Select 	
	"Item Code" = e.product_code, 
	"Item Name" = Items.productname,
	"Item Spec1" = e.product_specification1,
	"Item Spec2" = i.product_specification2,
	"Item Spec3" = i.product_specification3,
	"Item Spec4" = i.product_specification4,
	"Item Spec5" = i.product_specification5,
	"Colour" = Isnull(GeneralMaster.[Description], ''),
	"DateofSale" = dbo.sp_ser_StripDateFromTime(i.DateofSale),
	"Sold By" = Isnull(i.soldby, ''),
	"Delivery Date" = dbo.sp_ser_StripDateFromTime(e.Deliverydate),
	"Delivery Time" = dbo.sp_ser_StripTimeFromDate(e.DeliveryTime)
from EstimationDetail e
Inner Join Items On Items.product_code  = e.Product_code
Left outer Join ItemInformation_Transactions i On  
i.DocumentID = e.SerialNo and i.DocumentType = 1
Left outer join GeneralMaster On i.Color = GeneralMaster.code
where e.EstimationID = @EstID and 
e.SerialNo in (Select Min(g.Serialno) From EstimationDetail g Where EstimationID = @EstID
		Group by Product_Specification1)
Order by e.SerialNo





