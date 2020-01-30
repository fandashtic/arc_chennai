CREATE Procedure Sp_Acc_SendCustDetails
(@DocumentID Int,@BranchID nVarchar(50))
as
Insert into SendPriceListBranch (DocumentID,BranchID)  
Values (@DocumentID,@BranchID)  


