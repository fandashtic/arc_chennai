CREATE procedure sp_Chk_ODNumber_Duplicate(@Vendor_ID nvarchar(15),@ODNumber nVarChar(50),@Old_BillID Int = 0)
As
Begin

Select Count(*) From BillAbstract 
Where IsNull(Status,0) & 128 = 0 And VendorID = @Vendor_ID And ODNumber = @ODNumber And BillID <> @Old_BillID

End
