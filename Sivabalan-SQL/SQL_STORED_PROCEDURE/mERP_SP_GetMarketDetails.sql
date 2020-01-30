
Create Procedure mERP_SP_GetMarketDetails (@MarketName Nvarchar(240))
As
BEGIN
	Select top 1 isnull(District,'') as District,isnull(Sub_District,'') as Sub_District,isnull(Pop_Group,'')  as Pop_Group from MarketInfo Where
    (Cast(isnull(Marketid,0) as Nvarchar(10)) + '-' + isnull(MarketName,'')) = @MarketName
	and isnull(Active,0) = 1
END

