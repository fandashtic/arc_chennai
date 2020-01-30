

CREATE Procedure spr_ser_WarrantySettlement(@Fromdate datetime,@Todate datetime)  
As  
Begin  
  
Declare @ParamSep nVarchar(10)  
Set @ParamSep = Char(2)  
  
Select Distinct
'EID' = cast(JCD.JobCardID as nvarchar(20)) + @paramsep + JCD.Product_Code,   
((select Prefix from VoucherPrefix where TranID = 'JOBCARD') + Cast(JobCardAbstract.DocumentID as varchar)) as 'JC ID', 
JobCardAbstract.JobCardDate as 'JC Date',   
JCD.Product_Code as 'Item Code', 
Items.ProductName as 'Item Name',   

(select TypeName from ServiceType where TypeCode = JobCardAbstract.ServiceType) as 'Service Type',

(select TypeName from ServiceClaimType where TypeCode = JobCardAbstract.ClaimType) as 'Claim Type',   
  
(Select 
	sum
	(
		isnull(ActualCharge, 0) * (Case JobCardDetail.Quantity when 0 then 1 else JobCardDetail.Quantity end) +
		isnull(SalesTax, 0) +
		(isnull(ActualCharge, 0) * (Case JobCardDetail.Quantity when 0 then 1 else JobCardDetail.Quantity end) * isnull(ServiceTax_Percentage, 0))/100
	)
 	from JobCardDetail where   
	JobCardID = JCD.JobCardID and Product_Code = JCD.Product_Code and Type <> 0 and Chargeable = 0
)   
as 'Warranty Amount',   
  
(Select sum(isnull(ActualCharge, 0) * JobCardDetail.Quantity) from JobCardDetail where   
JobCardID = JCD.JobCardID and Product_Code = JCD.Product_Code and Type in (1,2,3) and Len(SpareCode) <> 0 and Chargeable = 0)    
as 'Spare Charges',   
  
(Select sum(isnull(ActualCharge, 0)) from JobCardDetail where   
JobCardID = JCD.JobCardID and Product_Code = JCD.Product_Code and Type in (1,2) and Len(SpareCode) = 0 and Chargeable = 0) 
as 'Job\Task Charges',

(Select sum(Isnull(ActualCharge, 0) * (Case Quantity when 0 then 1 else Quantity end) * Isnull(ServiceTax_Percentage, 0)/100)
from JobCardDetail where JobCardID = JCD.JobCardID and Product_Code = JCD.Product_Code and Type in (1,2) and Len(SpareCode) = 0 and Chargeable = 0) 
as 'Service Tax',

(Select sum(isnull(SalesTax, 0)) from JobCardDetail where   
JobCardID = JCD.JobCardID and Product_Code = JCD.Product_Code and Type in (1,2,3) and Len(SpareCode) <> 0 and Chargeable = 0) 
as 'Sales Tax'   

From   
JobCardAbstract, JobCardDetail JCD, Items  
  
Where  
JCD.JobCardID = JobCardAbstract.JobCardID And   
JCD.Product_Code = Items.Product_Code And  
JobCardAbstract.Status & 128 <> 128 And
JobCardAbstract.Status & 64 <> 64 And
(JobCardAbstract.ServiceType = 2 or JobCardAbstract.ServiceType = 3) And
(Select Count(*) from JobCardDetail where JobCardID = JCD.JobcardID and Chargeable = 0) > 0 And  -- This is to filter jobcards which has no warrantied Items...
JobCardAbstract.JobCardDate Between @FromDate and @ToDate         

End  

