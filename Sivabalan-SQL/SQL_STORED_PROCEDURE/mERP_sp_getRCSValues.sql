CREATE Procedure mERP_sp_getRCSValues(@CustID nVarChar(50))
As
Select TD.TMDCtlPos, TD.TMDID, TM.TMDValue From Cust_TMD_Details TD, Cust_TMD_Master TM
Where TD.CustomerID = @CustID And TD.TMDID = TM.TMDID
