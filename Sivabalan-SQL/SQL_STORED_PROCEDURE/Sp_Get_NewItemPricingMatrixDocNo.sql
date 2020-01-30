
Create Procedure Sp_Get_NewItemPricingMatrixDocNo  
As  
Declare @DocumentID int  
Begin Tran  
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 65  
Select @DocumentID = DocumentID - 1 From DocumentNumbers where DocType = 65
Commit Tran  
Select @DocumentID

