Create procedure mERP_Sp_Get_RecdChannel_ITC
AS
Select C.ID,R.ChannelCode,isnull(R.ChannelName,'') as ChannelName,R.Active From tbl_mERP_RecdChannlDetail R,tbl_mERP_RecdChannlAbstract C        
Where R.ID = C.ID And        
isnull(C.Status,0) = 0  and isnull(R.status,0)=0
