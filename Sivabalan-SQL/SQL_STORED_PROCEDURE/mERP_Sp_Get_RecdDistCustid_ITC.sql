Create procedure mERP_Sp_Get_RecdDistCustid_ITC
AS
Select DISTINCT R.CustomerID From tbl_mERP_RecdCatHandDetail R,tbl_mERP_RecdCatHandAbstract C
Where R.ID = C.ID And
isnull(C.Status,0) = 0  and isnull(R.status,0)=0 

