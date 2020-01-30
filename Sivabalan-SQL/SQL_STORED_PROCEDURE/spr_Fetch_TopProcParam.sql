CREATE Procedure spr_Fetch_TopProcParam      
(@Repid int,@FrmDate Datetime,@ToDate Datetime,@FullParam integer=0, @ReportType integer=1)       
as        
If(@FullParam=0 And @ReportType=1)      
Begin      
 Set Dateformat dmy        
 Select Case Substring(Parameter_Value,1,4)        
  When '$All' then cast('%'  as sql_variant)      
  When '$MMD' then Case When Len(Cast(datepart(mm,@FrmDate) as Nvarchar)) = 1 then '0'+ Cast(datepart(mm,@FrmDate) as Nvarchar) Else Cast(datepart(mm,@FrmDate) as Nvarchar) End + '/' + Cast(datepart(yyyy,@FrmDate) as NVarchar)  
  When '$MMM' then Cast(REPLACE(RIGHT(CONVERT(VARCHAR(11), @FrmDate, 106), 8), ' ', '-') as nVarchar(8)) 
  When '$MLD' then  
  Case When Parameter_Type=7 then cast(@FrmDate as sql_variant)         
  When Parameter_Type=10 then Cast(dateadd(s,59,dateadd(n,59,dateadd(hh,23,@ToDate))) as sql_variant)      
  Else cast(@FrmDate as sql_variant)   
  End        
  When '$Dat' then   
  Case When Parameter_Type=7 then cast(@FrmDate as sql_variant)         
  When Parameter_Type=10 then Cast(dateadd(s,59,dateadd(n,59,dateadd(hh,23,@ToDate))) as sql_variant)      
  Else cast(@FrmDate as sql_variant)   
  End        
  When '' then cast('%' as  sql_variant)      
  Else   
 Case When Parameter_name = 'To Week' then   
  Case When Datepart(d,@ToDate) = 7 then '1'  
   When Datepart(d,@ToDate) = 14 then '2'  
   When Datepart(d,@ToDate) = 21 then '3'  
   Else '4'  
  End  

	When Parameter_name = 'Upto Week' then   
	Case When Datepart(d,@ToDate) = 7 then 'Week 1'  
    When Datepart(d,@ToDate) = 14 then 'Week 2'  
    When Datepart(d,@ToDate) = 21 then 'Week 3'  
    Else 'Week 4'  
  End

 Else  
	cast(Parameter_Value  as  sql_variant)
 End End ,        
  Case Parameter_Type When 10 then 7 else Parameter_type end ,      
  Parameter_Name,Replace(Parameter_Value,'$','')       
  from ReportParameters_Upload      
  Where ReportParameters_Upload.ParameterID=(Select Distinct(Reports_To_Upload.ParameterID)      
  From Reports_To_Upload Where Reports_To_Upload.ReportDataID=@repid)       
End      
Else If(@FullParam=0 And @ReportType=2)      
Begin      
 Set Dateformat dmy        
 Select Case Substring(Parameter_Value,1,4)        
  When '$All' then cast('%'  as sql_variant)      
  When '$MMD' then Case When Len(Cast(datepart(mm,@FrmDate) as Nvarchar)) = 1 then '0'+ Cast(datepart(mm,@FrmDate) as Nvarchar) Else Cast(datepart(mm,@FrmDate) as Nvarchar) End + '/' + Cast(datepart(yyyy,@FrmDate) as NVarchar)  
  When '$MMM' then Cast(REPLACE(RIGHT(CONVERT(VARCHAR(11), @FrmDate, 106), 8), ' ', '-') as nVarchar(8)) 
  When '$MLD' then  
  Case When Parameter_Type=7 then cast(@FrmDate as sql_variant)         
  When Parameter_Type=10 then Cast(dateadd(s,59,dateadd(n,59,dateadd(hh,23,@ToDate))) as sql_variant)      
  Else cast(@FrmDate as sql_variant)   
  End        
  When '$Dat' then   
  Case When Parameter_Type=7 then cast(@FrmDate as sql_variant)         
  When Parameter_Type=10 then Cast(dateadd(s,59,dateadd(n,59,dateadd(hh,23,@ToDate))) as sql_variant)      
  Else cast(@FrmDate as sql_variant)   
  End        
  When '' then cast('%' as  sql_variant)      
  Else   
 Case When Parameter_name = 'To Week' then   
  Case When Datepart(d,@ToDate) = 7 then '1'  
   When Datepart(d,@ToDate) = 14 then '2'  
   When Datepart(d,@ToDate) = 21 then '3'  
   Else '4'  
  End 

	When Parameter_name = 'Upto Week' then   
	Case When Datepart(d,@ToDate) = 7 then 'Week 1'  
    When Datepart(d,@ToDate) = 14 then 'Week 2'  
    When Datepart(d,@ToDate) = 21 then 'Week 3'  
    Else 'Week 4'  
  End 
 
 Else  
cast(Parameter_Value  as  sql_variant)   
 End End ,        
  Case Parameter_Type When 10 then 7 else Parameter_type end ,      
  Parameter_Name,Replace(Parameter_Value,'$','')       
  from ReportParameters_Upload      
  Where ReportParameters_Upload.ParameterID=(Select Distinct(tbl_mERP_OtherReportsUpload.ParameterID)      
  From tbl_mERP_OtherReportsUpload Where tbl_mERP_OtherReportsUpload.ReportDataID=@repid)       
End     
Else If(@FullParam=1 And @ReportType=1)      
Begin      
 Set Dateformat dmy
--Select @ToDate        
 Select Case Substring(Parameter_Value,1,4)        
  When '$All' then cast('%' as sql_variant)     
  When '$MMD' then Case When Len(Cast(datepart(mm,@FrmDate) as Nvarchar)) = 1 then '0'+ Cast(datepart(mm,@FrmDate) as Nvarchar) Else Cast(datepart(mm,@FrmDate) as Nvarchar) End + '/' + Cast(datepart(yyyy,@FrmDate) as NVarchar)   
  When '$MMM' then Cast(REPLACE(RIGHT(CONVERT(VARCHAR(11), @FrmDate, 106), 8), ' ', '-') as nVarchar(8)) 
  --When '$MLD' then Case When Parameter_Type=10 then cast(@FrmDate as sql_variant)      end  
  When '$MLD' then Case When Parameter_Type=10 then cast(@ToDate as sql_variant)      end  
  When '$Dat' then Case When Parameter_Type=7 then cast(@FrmDate as sql_variant)        
  When Parameter_Type=10 then Cast(dateadd(s,59,dateadd(n,59,dateadd(hh,23,@ToDate))) as sql_variant)      
  Else cast(@FrmDate as sql_variant)End
        
  When '' then cast('%'   as  sql_variant) 
     
  Else   
	Case When Parameter_name = 'To Week' then   
	Case When Datepart(d,@ToDate) = 7 then '1'  
    When Datepart(d,@ToDate) = 14 then '2'  
    When Datepart(d,@ToDate) = 21 then '3'  
    Else '4'  
  End 
 
	When Parameter_name = 'Upto Week' then   
	Case When Datepart(d,@ToDate) = 7 then 'Week 1'  
    When Datepart(d,@ToDate) = 14 then 'Week 2'  
    When Datepart(d,@ToDate) = 21 then 'Week 3'  
    Else 'Week 4'  
  End 

 
Else
	cast(Parameter_Value  as  sql_variant)   
End End ,
  Case Parameter_Type When 10 then 7 else Parameter_type end ,      
  Parameter_Name, Replace(Parameter_Value,'$','')       
  from ReportParameters_Upload      
  Where ReportParameters_Upload.ParameterID=(Select Distinct(Reports_To_Upload.ParameterID)      
  From Reports_To_Upload Where Reports_To_Upload.ReportDataID=@repid)  And Skip=0       
End  
Else If(@FullParam=1 And @ReportType=2)      
Begin      
 Set Dateformat dmy
--Select @ToDate        
 Select Case Substring(Parameter_Value,1,4)        
  When '$All' then cast('%' as sql_variant)     
  When '$MMD' then Case When Len(Cast(datepart(mm,@FrmDate) as Nvarchar)) = 1 then '0'+ Cast(datepart(mm,@FrmDate) as Nvarchar) Else Cast(datepart(mm,@FrmDate) as Nvarchar) End + '/' + Cast(datepart(yyyy,@FrmDate) as NVarchar)   
  When '$MMM' then Cast(REPLACE(RIGHT(CONVERT(VARCHAR(11), @FrmDate, 106), 8), ' ', '-') as nVarchar(8)) 
  --When '$MLD' then Case When Parameter_Type=10 then cast(@FrmDate as sql_variant)      end  
  When '$MLD' then Case When Parameter_Type=10 then cast(@ToDate as sql_variant)      end  
  When '$Dat' then Case When Parameter_Type=7 then cast(@FrmDate as sql_variant)        
  When Parameter_Type=10 then Cast(dateadd(s,59,dateadd(n,59,dateadd(hh,23,@ToDate))) as sql_variant)      
  Else cast(@FrmDate as sql_variant)End        
  When '' then cast('%'   as  sql_variant)      
  Else   
 Case When Parameter_name = 'To Week' then   
  Case When Datepart(d,@ToDate) = 7 then '1'  
   When Datepart(d,@ToDate) = 14 then '2'  
   When Datepart(d,@ToDate) = 21 then '3'  
   Else '4'  
  End  
	When Parameter_name = 'Upto Week' then   
	Case When Datepart(d,@ToDate) = 7 then 'Week 1'  
    When Datepart(d,@ToDate) = 14 then 'Week 2'  
    When Datepart(d,@ToDate) = 21 then 'Week 3'  
    Else 'Week 4'  
  End
 Else  
cast(Parameter_Value  as  sql_variant)   
 End End ,        
  Case Parameter_Type When 10 then 7 else Parameter_type end ,      
  Parameter_Name, Replace(Parameter_Value,'$','')       
  from ReportParameters_Upload      
  Where ReportParameters_Upload.ParameterID=(Select Distinct(tbl_mERP_OtherReportsUpload.ParameterID)      
  From tbl_mERP_OtherReportsUpload Where tbl_mERP_OtherReportsUpload.ReportDataID=@repid)  And Skip=0       
End  
