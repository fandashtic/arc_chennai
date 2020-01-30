CREATE procedure sp_ser_Returnablespareinfo(@IssueID int, 
@ProductCode nvarchar(50), @Spec1 nvarchar(50))
as

Select 'SpareCode' = s.SpareCode,'SpareName' = i.ProductName,
'UOMDescription' = u.[Description],'UOMCode' = s.UOM, 
'SalePrice'= s.SalePrice, 'TaxSufferedPercentage' = IsNull(s.TaxSuffered_Percentage,0),  
'SalesTaxPercentage'=s.SaleTax_Percentage, 'UOMPrice' = s.UOMPrice,
'Warranty' = (Case s.Warranty when 1 then 'Yes' when 2 then 'No' else '' end),  
s.WarrantyNo, s.DateofSale, s.SerialNo, s.IssuedQty, 
'ReturnedQty' = IsNUll(s.ReturnedQty,0), s.UOMQty,
s.Batch_Code, s.Batch_Number,  
'Batch' = i.Track_Batches, 'PKD' = i.TrackPKD, 'INVENTORY' = c.Track_Inventory, 
'CSP' = c.Price_Option, 
'UOMConverstion' = (Case s.UOM when i.UOM then 1 when i.UOM1 then UOM1_Conversion 
when i.UOM2 then UOM2_Conversion end), 
'Free' = IsNull(b.Free, 0),
'PersonnelName' = Isnull(M.PersonnelName,'') 
from IssueDetail s 
Inner Join Items i on i.Product_Code = s.SpareCode 
Inner Join ItemCategories c on i.categoryID = c.categoryID
Inner Join UOM u on u.UOM = s.UOM 
Left outer join PersonnelMaster M on s.PersonnelID = M.PersonnelID 
Left Outer Join Batch_Products b On b.Batch_Code = s.Batch_Code
Where s.Product_Code = @ProductCode and s.Product_Specification1 = @Spec1 and 
s.IssueID = @IssueID 
Order By s.SerialNo






