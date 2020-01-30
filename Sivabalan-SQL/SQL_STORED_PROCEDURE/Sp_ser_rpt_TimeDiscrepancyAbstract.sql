CREATE procedure Sp_ser_rpt_TimeDiscrepancyAbstract(@Fromdate datetime,@Todate datetime)
as

Declare @Qry nVarchar(3000),@ParamSep nVarchar(2)
Declare @Item_Spec1 nVarchar(50)
Declare @JCPrefix nVarchar(10),@SIPrefix nVarchar(10)

Set @ParamSep = Char(2)
Select	@Item_Spec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'
select @JCPrefix = Prefix from VoucherPrefix where Tranid='JOBCARD'
select @SIPrefix = Prefix from VoucherPrefix where Tranid='SERVICEINVOICE'

Set @Qry = 'select "ID"=Cast(JCD.JobCardID as nVarChar(20))+'''+ @ParamSep +'''+JCD.Product_Specification1 ,"Item Code"= TempRS.Product_Code,ITEM.ProductName,
['+ @Item_Spec1 + ']=TempRS.Product_Specification1,"Job Card ID"='''+@JCPrefix+'''+Cast(JCA.DocumentID as nVarchar(20)),
"Job Card Date"=JCA.JobCardDate,"Time In"=dbo.sp_ser_StripTimeFromDate(JCD.TimeIn),
"Delivery Date"=JCD.DeliveryDate,"Delivery Time"=dbo.sp_ser_StripTimeFromDate(JCD.DeliveryTime),
"Task End Date"=TempRS.EndTime,"Task End Time"=dbo.sp_ser_StripTimeFromDate(TempRS.EndTime),
"Service Invoice ID"='''+@SIPrefix+'''+Cast(SIA.DocumentID as nVarchar(20)),"Service Invoice Date"=SIA.ServiceInvoiceDate
from ' +
--Temporary Resultset to fetch JobCardid and maximum of End Time 
'(select JCD_I.JobCardID,JCD_I.Product_Code,JCD_I.Product_Specification1,"EndTime" = Max(TA_I.EndTime)
from JobCardDetail JCD_I 
Inner Join JobCardTaskAllocation TA_I on JCD_I.JobCardID = TA_I.JobCardID and
JCD_I.Product_Code=TA_I.Product_code and JCD_I.Product_Specification1 = TA_I.Product_Specification1
and isNull(JCD_I.Type,0)=0 where '+
--If task is assigned and not assigned, check with server date and time 
'((isNull(TA_I.TaskStatus,0)= 0 or isNull(TA_I.TaskStatus,0)= 1)
and Convert(DateTime,dbo.sp_acc_StripDatefromTime(JCD_I.DeliveryDate),105) <= Convert(DateTime,dbo.sp_acc_StripDatefromTime(getdate()),105)
and JCD_I.DeliveryTime<Convert(DateTime,dbo.sp_acc_stripdatefromtime(getDate()) + ' + ''' ''' + '+dbo.sp_ser_striptimefromdate(getDate()),105)) '+
--If task is closed and not assigned, check with end date and time of task
'or (isNull(TA_I.TaskStatus,0)= 2 and Convert(DateTime,dbo.sp_acc_StripDatefromTime(JCD_I.DeliveryDate),105)<=Convert(DateTime,dbo.sp_acc_StripDatefromTime(TA_I.EndDate),105)
and JCD_I.DeliveryTime < TA_I.EndTime)
Group by JCD_I.JobCardID,JCD_I.Product_Code,JCD_I.Product_Specification1) as TempRS
inner join JobCardDetail JCD on JCD.JobCardID = TempRs.JobCardID and JCD.Product_Code=TempRs.Product_Code
and JCD.Product_Specification1=TempRs.Product_Specification1 and isNull(Type,0)=0
inner join JobCardAbstract JCA on JCD.JobCardID = JCA.JobCardID and isNull(Status,0) & 192=0
inner join Items ITEM on JCD.Product_Code=ITEM.Product_Code
Left Outer join ServiceInvoiceAbstract SIA on JCA.ServiceInvoiceID=SIA.ServiceInvoiceID 
where JCA.JobCardDate between Cast('''+Cast(@FromDate as Varchar) + ''' as DateTime) and
Cast('''+Cast(@ToDate as Varchar) + ''' as DateTime) order by JCA.JobCardDate'

Exec SP_ExecuteSQL @Qry

