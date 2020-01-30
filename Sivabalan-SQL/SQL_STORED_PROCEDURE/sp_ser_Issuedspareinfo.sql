CREATE Procedure sp_ser_Issuedspareinfo(@IssueID int, 
@ProductCode nvarchar(50) , @Spec1 nvarchar(50))
as
Select 'SpareCode' = SpareCode,'SpareName' = i.ProductName,
'UOMDescription' = u.[Description],'UOMCode' = IssueDetail.UOM,
'SalePrice'= SalePrice,
'Warranty' = (Case Warranty when 1 then 'Yes' when 2 then 'No' else '' end),
WarrantyNo, DateofSale, SerialNo, UOMQty, Batch_Number, IssuedQty,
IsNUll(ReturnedQty,0) 'ReturnedQty',
'UOMConverstion' = (Case IssueDetail.UOM when i.UOM then 1 when i.UOM1 then UOM1_Conversion 
when i.UOM2 then UOM2_Conversion end),
'PersonnelName' = Isnull(M.PersonnelName,0), 'PurchasePrice' = isnull(PurchasePrice, 0)
from issueDetail  
Inner Join Items i on i.Product_Code = SpareCode 
Inner Join UOM u on IssueDetail.UOM = u.UOM
Inner Join PersonnelMaster M on issuedetail.PersonnelID = M.PersonnelID 
Where issueDetail.Product_Code = @ProductCode and Product_Specification1 = @Spec1 and 
IssueID = @IssueID Order by SerialNo


