CREATE procedure [dbo].[spr_ser_TransactionTimingAbstract](@JobCardID nVarchar(100), @FromDate DateTime, @ToDate DateTime)  
AS  
Begin  

-- for splitting multiple Parameters...
DECLARE @Delimeter as Char(1)    
SET @Delimeter=Char(15) 

Create Table #TmpJobCardID(JobCardID NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)

If @JobCardID = '%' 
	Insert Into #TmpJobCardID Select JobCardID From JobCardAbstract
Else
	Insert Into #TmpJobCardID Select * From DBO.sp_SplitIn2Rows(@JobCardID,@Delimeter)


  
Select   
'EID' = JobCardAbstract.JobCardID,   
((select Prefix from VoucherPrefix where TranID='JOBCARD') + cast(JobCardAbstract.DocumentID as varchar)) as 'Job Card ID', 
JobCardAbstract.CreationDate as 'System Date of Creation',   
JobCardAbstract.JobCardDate as 'Forum Date of Creation', JobCardDetail.Product_Code as 'Item Code',   
Items.ProductName  as 'Item Name', isnull(ServiceInvoiceAbstract.NetValue, 0)  as 'Invoice Value'  
  
From  
JobCardAbstract, JobCardDetail, Items, ServiceInvoiceAbstract  
  
Where  
JobCardAbstract.JobCardID = JobCardDetail.JobCardID AND  
JobCardDetail.Product_Code = Items.Product_Code AND  
JobCardAbstract.JobCardID *= ServiceInvoiceAbstract.JobCardID AND  
JobCardDetail.Type = 0 AND  
JobCardAbstract.JobCardID IN (Select JobCardID from #TmpJobCardID) AND  
(JobCardAbstract.Status & 128) <> 128 AND
(JobCardAbstract.Status & 64) <> 64 AND
JobCardAbstract.JobCardDate Between @FromDate and @ToDate  
  
Order by JobCardDetail.JobCardID  
  
End  


SET QUOTED_IDENTIFIER OFF
