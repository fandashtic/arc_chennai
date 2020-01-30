CREATE PROCEDURE [dbo].[spr_DS_GGRR] (@Rptmonth nvarchar(50),@DSType nvarchar(4000))  
  
 As  
  
Begin  
SELECT Distinct D_IsExcluded, month, status, currentstatus, customerid,  customerName, DsName, Dstype, D_PRODUCTCODE, D_TARGET, TARGET, ACTUAL from GGRRFinalData WHERE MONTH = '@Rptmonth nvarchar' and D_IsExcluded is null   
end
