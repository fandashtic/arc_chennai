CREATE procedure sp_ser_getjobcardspareinfo(@JobCardID int,@ProductCode
nvarchar(15),
@JobID nvarchar(50),@TaskID nvarchar(50),@Mode Int,@ItemSpec1 nvarchar(50), 
@SpareCode nvarchar(30) = '')

as
--JOB 1 --Task 2--Spare 3
If @Mode = 1 
Begin
	Select SpareCode,'SpareName' = ProductName,
	'UOMDescription' = UOM.[Description], j.UOM, j.Quantity, UOMQty, 
	IsNull(Warranty, 0) 'Warranty', IsNUll(WarrantyNo,'') 'WarrantyNo', DateofSale
'DateofSale'  
	from JobCardDetail j
	Inner Join Items i On i.Product_Code = SpareCode
	Inner Join UOM On j.UOM = UOM.UOM
	Where j.JobCardId = @JobCardID and j.Product_Code = @ProductCode and
j.Product_Specification1 = @ItemSpec1
	and IsNull(j.JobID,'') = @JobID and IsNull(j.TaskID, '') = @TaskID and
IsNull(j.SpareCode, '') <> ''
End
Else If @Mode = 2
Begin
	Select SpareCode,'SpareName' = ProductName,
	'UOMDescription' = UOM.[Description],
	j.UOM, j.Quantity,UOMQty, IsNull(Warranty, 0) 'Warranty', IsNUll(WarrantyNo,'')
	'WarrantyNo', DateofSale 'DateofSale'  
	from JobCardDetail j
	Inner Join Items i On i.Product_Code = SpareCode
	Inner Join UOM On j.UOM = UOM.UOM
	Where j.JobCardId = @JobCardID and j.Product_Code = @ProductCode and
	j.Product_Specification1 = @ItemSpec1
	and IsNull(j.TaskID, '') = @TaskID and IsNull(j.JobID, '') = '' and
	Isnull(j.SpareCode, '') <> ''
End
Else If @Mode = 3
Begin
	Select SpareCode,'SpareName' = ProductName,
	'UOMDescription' = UOM.[Description], j.UOM, j.Quantity,UOMQty, 
	IsNull(Warranty, 0) 'Warranty', IsNUll(WarrantyNo,'') 'WarrantyNo', 
	DateofSale 'DateofSale' 
	from JobCardDetail j
	Inner Join Items i On i.Product_Code = SpareCode
	Inner Join UOM On j.UOM = UOM.UOM
	Where j.JobCardId = @JobCardID and j.Product_Code = @ProductCode and 
	j.Product_Specification1 = @ItemSpec1 
	and Isnull(j.TaskID, '') = '' and isnull(j.JobID, '') = '' and
	Isnull(j.SpareCode, '') = @SpareCode
End



