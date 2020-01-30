CREATE procedure sp_ser_loadestimationabstractdoc(@DocumentIDFrom int, @DocumentIDTo int,
@Mode Int)
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
	On EstAbs.DocumentID between @DocumentIDFrom And @DocumentIDTo 
	And EstAbs.EstimationId = EstDet.EstimationId	
	And (IsNull(EstAbs.Status, 0) & 192) = 0 
	And (IsNull(EstAbs.Status, 0) & 128) = 0 --And (IsNull(Status, 0) & 129) = 0  
	Inner Join Customer On EstAbs.CustomerID = Customer.CustomerID		
	Group by EstAbs.EstimationID,EstAbs.EstimationDate,
	EstAbs.Status,Company_Name,EstAbs.DocRef,EstAbs.DocumentId 
	Order by Company_Name
End
Else If @Mode = 2
Begin
	Select EstAbs.EstimationID,'DocumentID' = @Prefix + Cast(EstAbs.DocumentID as nvarchar(15)),
	IsNull(Sum(EstDet.NetValue),0) as 'Amount',EstAbs.EstimationDate,Company_Name,
	'Status'=IsNull(EstAbs.Status,0), IsNull(EstAbs.DocRef,'') DocRef 
	From EstimationDetail EstDet Inner Join EstimationAbstract EstAbs
	On EstAbs.EstimationId = EstDet.EstimationId
	And EstAbs.DocumentID between @DocumentIDFrom And @DocumentIDTo 
	Inner Join Customer On EstAbs.CustomerID = Customer.CustomerID
	Group by EstAbs.EstimationID,EstAbs.EstimationDate,
	Company_Name,EstAbs.DocRef,EstAbs.Status,EstAbs.DocumentId
	Order by Company_Name
End
