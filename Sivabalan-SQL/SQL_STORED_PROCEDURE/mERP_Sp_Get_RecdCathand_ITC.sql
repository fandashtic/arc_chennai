Create procedure mERP_Sp_Get_RecdCathand_ITC
AS
Select C.ID,R.CustomerID,isnull(R.CategoryName,'') as CategoryName From tbl_mERP_RecdCatHandDetail R,tbl_mERP_RecdCatHandAbstract C        
Where R.ID = C.ID And        
isnull(C.Status,0) = 0  and isnull(R.status,0)=0
