CREATE PROCEDURE spr_list_itemsshortexpired_details( @ITEMCODE nvarchar(15))
AS
DECLARE @expmon INT
SELECT @expmon = ISNULL(shortexpirymonths,0) 
FROM setup
SELECT "BatchNumber"=Batch_Number, "Expiry"=Expiry,"PKD"= pkd,"Quantity" = SUM(quantity),"PTS"=pts,"PTR"=ptr,"ECP"=ecp,"Special Price"=company_price
FROM Batch_products  
WHERE Product_Code =  @ITEMCODE 
and Quantity > 0  
and expiry IS NOT NULL 
and expiry between GETDATE() and DATEADD(mm,@expmon,GETDATE())
GROUP BY batch_number,expiry,pkd,pts,ptr,ecp,company_price
