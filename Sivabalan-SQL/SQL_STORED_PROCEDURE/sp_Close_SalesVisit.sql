CREATE PROCEDURE sp_Close_SalesVisit(@SONumber int)        
AS        
      
Declare @SVNumber Int      
      
SELECT @SVNumber = SalesVisitNumber From SOAbstract Where SONumber = @SONumber        
      
IF (SELECT SUM(Pending) from SODetail WHERE SONumber = @SONumber) = 0        
BEGIN        
 UPDATE SOAbstract SET Status = Status | 128 WHERE SONumber = @SONumber      
END        

IF EXISTS(SELECT SalesVisitNumber FROM SOAbstract, SODetail WHERE SOAbstract.SONumber = SODetail.SONumber And SOAbstract.SONumber = @SONumber
    GROUP BY SalesVisitNumber HAVING SUM(QUANTITY) <> SUM(PENDING))
BEGIN
  UPDATE SVAbstract SET Status = Status | 128 WHERE SVNumber = @SVNumber        
END  


