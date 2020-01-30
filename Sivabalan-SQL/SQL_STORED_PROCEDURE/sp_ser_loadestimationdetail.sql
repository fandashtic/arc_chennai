CREATE procedure sp_ser_loadestimationdetail(@EstimationID int)
as
Declare @Prefix nvarchar(15)
Select @Prefix = Prefix
from VoucherPrefix Where TranID = 'JOBESTIMATION'

Select d.Product_Code, 
	'ProductName' = dbo.sp_ser_getitemname(d.Product_Code),
	'Product_Specification1' = d.Product_Specification1,
	DeliveryDate, DeliveryTime, 
	Isnull(Product_Specification2, '') 'Product_Specification2', 
	Isnull(Product_Specification3, '') 'Product_Specification3', 
	Isnull(Product_Specification4, '') 'Product_Specification4', 
	Isnull(Product_Specification5, '') 'Product_Specification5', 
	DateofSale, 'Color'= IsNull(GeneralMaster.[Description],''), Isnull(SoldBy, '') 'SoldBy',
	EstimationAbstract.CustomerID, Company_Name, EstimationDate, 
	'DocumentID' = @Prefix + cast(EstimationAbstract.DocumentID as nvarchar(15)),
	d.SerialNo, IsNull(DocRef, '') 'DocRef', Isnull(Remarks, '') 'Remark', Isnull(DocSerialType,'') 'DocSerialType'
from EstimationDetail d 
Inner Join EstimationAbstract on  EstimationAbstract.EstimationID = d.EstimationID 
Inner Join  Customer On EstimationAbstract.CustomerID = Customer.CustomerID
Left outer Join ItemInformation_Transactions i on i.DocumentID  = d.SerialNo and i.DocumentType = 1 
Left outer Join GeneralMaster On i.Color = GeneralMaster.Code 
Where EstimationAbstract.EstimationID = @EstimationID and 
d.SerialNo = (Select Top 1 t.SerialNo from EstimationDetail t Where 
t.EstimationID = d.EstimationID and t.Product_Code = d.Product_Code  and 
t.Product_Specification1 = d.Product_Specification1)
Order by d.SerialNo



