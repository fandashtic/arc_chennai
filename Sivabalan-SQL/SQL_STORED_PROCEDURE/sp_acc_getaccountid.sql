CREATE procedure sp_acc_getaccountid(@Code nVarchar(128),@Mode Int)  
As  
If @Mode = 1  
Begin  
 Select IsNull(AccountID,0) from Customer  
 Where CustomerID = @Code   
End  
Else If @Mode = 2  
Begin  
 Select IsNull(AccountID,0) from Vendors  
 Where VendorID = @Code   
End  
Else If @Mode = 3  
Begin  
 Select IsNull(AccountID,0) from Bank  
 Where Account_Number = @Code   
End  
Else If @Mode = 4  
Begin  
 Select IsNull(AccountID,0) from WareHouse  
 Where WareHouseID = @Code   
End  
Else If @Mode = 7  
Begin  
 Select IsNull(AccountID,0) from PersonnelMaster  
 Where PersonnelID = @Code   
End 
