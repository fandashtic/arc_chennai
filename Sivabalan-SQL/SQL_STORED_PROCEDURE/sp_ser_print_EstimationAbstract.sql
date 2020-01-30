CREATE Procedure sp_ser_print_EstimationAbstract(@EstID as int)
As     
         
Declare @Prefix nvarchar(15)                                              
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'                              

Select d.EID, Sum(d.TaskAmount) 'TaskAmount', Sum(d.SpareAmount) 'SpareAmount', 
	Sum(d.TotalAmount) 'TotalAmount' into #EstDetail
From (Select EstimationID 'EID', 
	'TaskAmount' = Case when (Isnull(Taskid, '') <> '' and Isnull(sparecode, '') = '') 
		then Isnull(Netvalue, 0) else 0 end,
	'SpareAmount' = Case when Isnull(sparecode, '') <> '' then 
			Isnull(Netvalue, 0) else 0 end,
	'TotalAmount' = Isnull(Netvalue, 0) 
	From EstimationDetail Where EstimationDetail.EstimationID = @EstID) d
group by d.EID 

SELECT 
"EstimationID" =  @Prefix + cast(a.DocumentID as nvarchar(15)),
"Estimation Date" = a.EstimationDate,
"CustomerID" = a.CustomerID,
"Customer Name" = company_Name,
"Doc Ref" = Isnull(a.DocRef,''),
"DocType" = Isnull(a.DocSerialType, ''),
"Remarks" = Isnull(a.Remarks,''),
"Task Amount" =  d.TaskAmount,
"Spare Amount" = d.SpareAmount,
"Total Amount" = d.TotalAmount,
"Status" = Case WHEN (IsNull(Status, 0) & 128) <> 0 THEN 'Closed' ELSE 'Open' END  

from Estimationabstract a
Inner Join  #EstDetail d On d.EID = a.EstimationID 
Inner Join Customer On a.customerID = customer.customerID
where a.EstimationID = @EstID


