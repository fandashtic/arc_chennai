CREATE procedure sp_list_GiftVoucher(@VoucherID Int)  
As  
Select VendorID,Prefix,Suffix,StartNumber,EndNumber,Denomination,ValidityType,ValidityDate,  
Period,ValidityMonths,Active,CreationDate From GiftVoucher where VoucherID=@VoucherID  


