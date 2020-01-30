CREATE procedure Sp_Acc_SaveCustDetails (@PriceListID Int,@BranchID nVarchar(50))
as
Insert into PriceListBranch (PriceListID,BranchID)
Values (@PriceListID,@BranchID)


