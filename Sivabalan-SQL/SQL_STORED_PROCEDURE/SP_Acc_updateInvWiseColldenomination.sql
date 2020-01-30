CREATE PROCEDURE SP_Acc_updateInvWiseColldenomination(@CollectionID INT,@Denominations NVARCHAR(100))  
AS  
UPDATE InvoiceWiseCollectionAbstract SET Denomination = @Denominations  
WHERE CollectionID = @CollectionID
