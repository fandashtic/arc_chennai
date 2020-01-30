Create Procedure sp_get_CustomerUpdateAttribs_ITC
As  
Select Sno,Upper(Attributes) from ItemsRecUpdateStatus   
where NodeGramps = 'TradeCustomer'  
Order by Sno  
SET QUOTED_IDENTIFIER OFF
