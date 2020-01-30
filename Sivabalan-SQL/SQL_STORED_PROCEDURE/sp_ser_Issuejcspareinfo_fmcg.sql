CREATE procedure sp_ser_Issuejcspareinfo_fmcg(@customerID nvarchar(50),   
@JobcardID int, @ProductCode nvarchar(50) , @Spec1 nvarchar(50))  
as  
Declare @Locality Int 
Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID   
  
Select 'SpareCode' = i.Product_Code,'SpareName' = IsNull(dbo.sp_ser_getitemname(j.SpareCode),''),  
'UOMDescription' = u.[Description],'UOMCode' = j.UOM,   
'SalePrice'= IsNull(i.Sale_Price,0),  
'TaxSufferedPercentage' = IsNUll(dbo.sp_ser_taxpercenatge(1,IsNull(i.TaxSuffered,0),0),0),  
'SalesTaxPercentage'=IsNull(dbo.sp_ser_taxpercenatge(@Locality,i.Sale_Tax,0),0),  
'UOMPrice' = IsNull(dbo.sp_ser_getuomprice_fmcg(j.SpareCode,i.UOM),0),  
'Warranty' = (Case j.Warranty when 1 then 'Yes' when 2 then 'No' else '' end),    
j.WarrantyNo, j.DateofSale, j.SerialNo, j.PendingQty, j.Qty, j.PendingQty,   
i.Track_Batches 'Batch', i.TrackPKD 'PKD', c.Track_Inventory 'INVENTORY',   
c.Price_Option 'CSP',   
'UOMConverstion' = (Case j.UOM when i.UOM then 1 when i.UOM1 then UOM1_Conversion   
when i.UOM2 then UOM2_Conversion end),
'PersonnelName' = Isnull(M.personnelname,''), isnull(i.Purchase_Price, 0) 'purchaseprice', 
Isnull(Vat, 0) 'VATExist', IsNull(CollectTaxSuffered, 0) 'CollectTaxSuffered', 
Isnull(j.JobFree, 0) 'JobFree'
from JobCardSpares j
Inner Join Items i on i.Product_Code = j.SpareCode   
Inner Join ItemCategories c on i.categoryID = c.categoryID  
Inner Join UOM u on j.UOM = u.UOM   
left outer join jobcardtaskallocation jt on jt.jobcardid = j.jobcardid
	and jt.product_Code = @ProductCode
	and jt.product_specification1 = @Spec1
	and jt.taskid = j.taskid and Isnull(jt.JobId, '') = Isnull(j.JobID, '') and 
	TaskStatus <= 1
left outer join personnelmaster M on jt.personnelid = M.personnelid                
Where j.Product_Code = @ProductCode and j.Product_Specification1 = @Spec1 and   
j.JobCardId = @JobCardID and IsNull(j.SpareCode,'') <> '' and PendingQty > 0 and   
IsNull(SpareStatus, 0) <> 2                  



