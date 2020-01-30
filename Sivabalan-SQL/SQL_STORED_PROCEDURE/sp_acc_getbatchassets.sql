CREATE Procedure sp_acc_getbatchassets(@AccountID as int)
As
Select 'No',BatchCode,BatchNumber,OPWDV from Batch_Assets where AccountID=@AccountID and Saleable=1

