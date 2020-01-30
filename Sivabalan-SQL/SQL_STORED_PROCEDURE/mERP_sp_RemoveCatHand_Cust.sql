Create procedure mERP_sp_RemoveCatHand_Cust
(
    @Customercode Nvarchar(100)  
)
as
	Delete from CustomerProductCategory where Customerid=@Customercode
