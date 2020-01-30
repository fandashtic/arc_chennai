CREATE Procedure sp_ser_rpt_EstimationAbstract(@Fromdate datetime,@Todate datetime)                                    
As                                    
Declare @Prefix nvarchar(15)                                              
                                
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'                              
                              
Select [ID],[EstimationID],[Estimation Date],[Customer Name],[Doc Ref],[Remarks],                                 
Sum([Task Amount])As [Task Amount],Sum([Spare Amount])As [Spare Amount],                          
Sum([Total Amount])As [Total Amount],[Status] FROM                                  
(SELECT 'ID' = Estimationabstract.EstimationID,                              
 'EstimationID' =  @Prefix + cast(Estimationabstract.DocumentID as nvarchar(15)),                                    
'Estimation Date' = EstimationDate,                                    
'Customer Name' = company_Name,                        
'Doc Ref' = Isnull(DocRef,''),                        
'Remarks' = Isnull(Remarks,''),                                     
'Task Amount'=               
Cast(case when isnull(Taskid,'') <> '' and (isnull(sparecode,'') = '' or sparecode = NULL) then Cast(sum(Netvalue) as Decimal(18,6)) else 0 end as decimal(18,6)),                   
'Spare Amount' = case when isnull(sparecode,'')  <> ''  then Cast(sum(Netvalue) as Decimal(18,6)) else 0 end,                                
'Total Amount' = case when isnull(sparecode,'') = '' and isnull(Taskid,'') <> ''then IsNUll(Sum(Netvalue),0) else 0 end +                          
case when isnull(sparecode,'')  <> ''  then IsNUll(Sum(Netvalue),0) else 0 end,                          
  
'Status' =                   
 Case             
 WHEN (IsNull(Status, 0) & 128) <> 0 THEN 'Closed'                  
 ELSE 'Open'                  
 END  
from Estimationabstract,EstimationDetail,Customer                                    
where Estimationabstract.customerID = customer.customerID                                    
and Estimationabstract.EstimationID = EstimationDetail.EstimationID                                  
and (Estimationdate) between @FromDate and @ToDate  
and (IsNull(Status,0) & 64) = 0              
group by Estimationabstract.EstimationID,Estimationabstract.documentID,estimationdate,                        
company_name,DocRef,Remarks,                        
TaskID,sparecode, Estimationabstract.Status) as grp                                
Group by [ID],[estimationID],[Estimation date],[Customer Name],[Doc Ref],[Remarks],[Status]            




