Create procedure mERP_sp_Get_CustomerMarketInfo(@CustomerCode as nvarchar(30))
As
Begin
  Select MI.MMID, MI.District, MI.Sub_District, Cast(MI.MarketID as nVarchar(10))+ N'-'+MI.MarketName as MarketGOI, MI.Pop_Group
  from MarketInfo MI, CustomerMarketInfo C
  Where C.Active = 1 and C.MMID = MI.MMID
  and Ltrim(Rtrim(C.CustomerCode)) = @CustomerCode
End
