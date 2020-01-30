CREATE PROCEDURE [dbo].[spr_salesmanwise_orders](@FROMDATE datetime,  
      @TODATE datetime)  
AS  
Declare @MLOthers NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)

SELECT 	isnull(SOAbstract.SalesmanID,0), 
	"Salesman" = case (isnull(SOAbstract.SalesmanID,0)) when 0 then @MLOthers else Salesman_Name end ,
	"Net Value (%c)" = SUM(Value), "Total Orders" = Count(*)   
FROM SOAbstract
Left Outer Join Salesman on  SOAbstract.SalesmanID = Salesman.SalesmanID
WHERE  
--SOAbstract.SalesmanID *= Salesman.SalesmanID AND  
 (SOAbstract.Status & 192) = 0 AND  
 SOAbstract.SODate BETWEEN @FROMDATE AND @TODATE  
GROUP BY isnull(SOAbstract.SalesmanID,0), Salesman_Name  
