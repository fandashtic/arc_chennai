CREATE Procedure sp_acc_importVendor(@VendorName nvarchar(50),@VendorID nVarchar(15))
As
DECLARE @CREDITORSGROUP INT,@Active Int
SET @CREDITORSGROUP=11
SET @Active=1

If Not Exists(Select * from AccountsMaster Where AccountName = @VendorName And GroupID = @CREDITORSGROUP And Active = @Active)
 Begin
  /* Insertion of Vendor account into the AccountMaster table. */
  Execute sp_acc_insertaccountsforexistingmasters @VendorName,@CREDITORSGROUP,@Active
  /* Updation of new AccounID into the Vendors table. */	
  Update Vendors set AccountID=@@IDENTITY where VendorID=@VendorID
 End
