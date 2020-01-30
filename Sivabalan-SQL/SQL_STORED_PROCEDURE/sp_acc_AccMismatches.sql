CREATE Procedure [sp_acc_AccMismatches]
/* Procedure to update daily opening balance */
As
Begin
	Select A.AccountID,ltrim(rtrim(A.Accountname)),AG.GroupName,
	Case isnull(A.Active,0) When  1 Then 
		'Active'
	Else
		'Inactive' 
	End As Active
From Accountsmaster A,AccountGroup AG Where AG.GroupID =A.GroupID
	Order by ltrim(rtrim(A.Accountname))
End
