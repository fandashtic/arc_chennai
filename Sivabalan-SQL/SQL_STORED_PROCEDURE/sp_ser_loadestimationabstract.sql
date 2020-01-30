CREATE procedure sp_ser_loadestimationabstract(@FromDate Datetime,@ToDate Datetime,  
@Mode Int,@CUSTOMER NVARCHAR(15) = '')  
as  
Declare @Prefix nvarchar(15)  
Select @Prefix = Prefix from VoucherPrefix  
where TranID = 'JOBESTIMATION'  
  
If @Mode = 1  
Begin  
	Select EstAbs.EstimationID,'DocumentID' = @Prefix + Cast(EstAbs.DocumentID as nvarchar(15)),
	IsNull(Sum(EstDet.NetValue),0) as 'Amount',EstAbs.EstimationDate,Company_Name,
	'Status'=IsNull(EstAbs.Status,0), IsNull(EstAbs.DocRef, '') DocRef 
	From EstimationDetail EstDet Inner Join EstimationAbstract EstAbs 
	On EstAbs.EstimationId = EstDet.EstimationId	
	And dbo.stripdatefromtime(EstAbs.EstimationDate) between @FromDate And @ToDate  
	And (IsNull(EstAbs.Status, 0) & 192) = 0 
	And (IsNull(EstAbs.Status, 0) & 128) = 0  -- And (IsNull(Status, 0) & 129) = 0  Not included Senthil
	Inner Join Customer On EstAbs.CustomerID = Customer.CustomerID
	And EstAbs.CustomerID LIKE @CUSTOMER  
	Group by EstAbs.EstimationID,EstAbs.EstimationDate,
	EstAbs.Status,Company_Name,EstAbs.DocRef,EstAbs.DocumentId 
	Order by Company_Name
End  
Else If @Mode = 2  
Begin  
	Select EstAbs.EstimationID,'DocumentID' = @Prefix + Cast(EstAbs.DocumentID as nvarchar(15)),
	IsNull(Sum(EstDet.NetValue),0) as 'Amount',EstAbs.EstimationDate,Company_Name,
	'Status'=IsNull(EstAbs.Status,0), IsNull(EstAbs.DocRef, '') DocRef 
	From EstimationDetail EstDet Inner Join EstimationAbstract EstAbs
	On EstAbs.EstimationId = EstDet.EstimationId	
	And dbo.stripdatefromtime(EstAbs.EstimationDate) between @FromDate And @ToDate  
	Inner Join Customer On EstAbs.CustomerID = Customer.CustomerID  
	And EstAbs.CustomerID LIKE @CUSTOMER
	Group by EstAbs.EstimationID,EstAbs.EstimationDate,
	EstAbs.Status,Company_Name,EstAbs.DocRef,EstAbs.DocumentId 
	Order by Company_Name
End 
