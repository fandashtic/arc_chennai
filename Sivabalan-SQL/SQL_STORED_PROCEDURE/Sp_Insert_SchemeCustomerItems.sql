Create Procedure Sp_Insert_SchemeCustomerItems
(@SchemeID int,@CustomerID nvarchar(255),@Product_code nvarchar(20),@Quantity Decimal(18,6))
As

Insert into  SchemeCustomerItems
(SchemeId,CustomerID,Product_code,Quantity,Pending,Claimed)
Values
(@SchemeId,@CustomerID,@Product_Code,@Quantity,@Quantity,0)

