
CREATE proc sp_delete_zeroqty_from_detail (@dispatchid int)
as 
delete dispatchdetail where dispatchid = @dispatchid and quantity <= 0

