CREATE Procedure mERP_sp_getSendTMDCustMap_ITC(@CustID nVarChar(50))
As
Select "CUSTOMERID" = TD.CustomerID , "LBLNAME" = TM.TMDName , "VALUE" = TM.TMDValue from Cust_TMD_Master TM, Cust_TMD_Details TD
Where TD.CustomerID = @CustID And TD.TMDID = TM.TMDID
