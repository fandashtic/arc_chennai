Create Procedure SP_GetRecdMMID  
AS  
Begin
Select distinct Isnull(RECMMID ,0) from RecdMarketInfoDetail where isNull(Status,0) = 0  and RECMMID in (select Distinct Documentid from RecdMarketInfoAbstract Where isnull(Status,0) = 0)
End
