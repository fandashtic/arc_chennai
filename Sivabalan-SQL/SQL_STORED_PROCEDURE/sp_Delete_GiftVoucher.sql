Create procedure sp_Delete_GiftVoucher(@VoucherID Int)
As
Delete From GiftVoucher Where VoucherID=@VoucherID
Delete From GiftVoucherDetail Where VoucherID=@VoucherID

