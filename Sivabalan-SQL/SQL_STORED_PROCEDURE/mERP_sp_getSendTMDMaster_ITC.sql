CREATE Procedure mERP_sp_getSendTMDMaster_ITC(@CustID nVarChar(50))
As
Select "LBLNAME" = TM.TMDName , "VALUE" = TM.TMDValue , "TYPE" = TM.TMDCtlPos from Cust_TMD_Master TM, Cust_TMD_Details TD
Where TD.CustomerID = @CustID And TD.TMDID = TM.TMDID
