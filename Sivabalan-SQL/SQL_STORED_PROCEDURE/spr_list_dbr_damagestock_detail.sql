create procedure spr_list_dbr_damagestock_detail(@ITEMCODE nvarchar(15))  
as  

Declare @GODOWN As NVarchar(50)
Declare @SALESRETURN As NVarchar(50)

Set @GODOWN = dbo.LookupDictionaryItem(N'Godown', Default)
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)

Select Batch_Products.Product_Code, "Item Code" = Batch_Products.Product_Code,   
"Item Name" = Items.ProductName, "Batch" = Batch_Products.Batch_Number,  
"PKD" = Batch_Products.PKD, "Expiry" = Batch_Products.Expiry,   
"Quantity" = Sum(Batch_Products.Quantity),  
"Purchase Price" = Batch_Products.PurchasePrice, "PTS" = Batch_Products.PTS,   
"PTR" = Batch_Products.PTR, "ECP" = Batch_Products.ECP,
"Reason" = sdr.message, 
case damage 
	when 1 then @GODOWN
	when 2 then @SALESRETURN
	else null end,
"Purchase Date" =  case 
	when GRN_ID is not null then  
		(select grndate from grnabstract where grnabstract.grnid = Batch_Products.grn_id)
	when stocktransferid is not null then 
		(select documentDate from stocktransferinabstract where docserial = stocktransferid)
	else null end,
"Return Date" = case damage
	when 2 then
		(select min(invoicedate) from invoiceabstract 
		where 
		invoiceid = (select invoiceid from invoicedetail 
			    where invoicedetail.batch_code = Batch_Products.batch_code))
	else
		null
	end
From Batch_Products, Items, stockadjustmentreason sdr  
Where Batch_Products.Product_Code = Items.Product_Code And  
Batch_Products.Damage in (1, 2)  And Batch_Products.Product_Code = @ITEMCODE And  
Quantity > 0  and sdr.messageid = damagesreason
Group By Batch_Products.Product_Code, Items.ProductName, Batch_Products.Batch_Number,  
Batch_Products.PKD, Batch_Products.Expiry, Batch_Products.PurchasePrice,  
Batch_Products.PTS, Batch_Products.PTR, Batch_Products.ECP, sdr.message, damage, grn_id, stocktransferid, batch_code

