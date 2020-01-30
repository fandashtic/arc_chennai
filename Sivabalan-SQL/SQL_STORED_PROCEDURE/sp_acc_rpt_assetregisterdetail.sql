CREATE Procedure sp_acc_rpt_assetregisterdetail(@FromDate DateTime,@Todate DateTime,@AccountID Int)      
As      
Declare @CheckDate as datetime,@StrDate as nvarchar(255),@StartDate datetime,@EndDate datetime      
Declare @ToDatePair as datetime    
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))      
    
Set @StrDate = dbo.sp_acc_GetFiscalYearStart()      
Set @CheckDate =Cast(@StrDate As DateTime)      
set @CheckDate = DateAdd(m, 6, @CheckDate)      
set @CheckDate = DateAdd(s, 0-1, @CheckDate)      
      
Set @StartDate=Cast(@StrDate As DateTime)      
Set @EndDate=Cast(@StrDate As DateTime)      
set @EndDate = DateAdd(m, 12, @EndDate)      
set @EndDate = DateAdd(d, 0-1, @EndDate)      
      
Select 'Serial Number'=BatchNumber,Rate,"OPWDV"=IsNull(OPWDV,0),      
'Rate of Dep.'=(Case when IsNull(BillDate,0)<= @CheckDate then AdditionalField1 else (AdditionalField1/2) End),      
'CurrentValue'=Case When Saleable=1 then (IsNull(OPWDV,0)-((Case when IsNull(BillDate,0)<= @CheckDate then (IsNull(OPWDV,0) * (AdditionalField1/100)) else (IsNull(OPWDV,0)*((AdditionalField1/2)/100)) End))) Else (Case When Saleable=0 Then 0 Else 0 End) End,      
'Status'=Case When Saleable=1 Then dbo.LookupDictionaryItem('In Use',Default) Else (Case When Saleable = 0 Then dbo.LookupDictionaryItem('Sold',Default) When Saleable = 3 Then dbo.LookupDictionaryItem('Amended',Default) Else dbo.LookupDictionaryItem('Cancel',Default) End) End,      
'Reg No.'=RegNo,'Date of Capitalization'= BillDate, 'Mfr Date'=MfrDate,'Location'=Location,'Supplier'=dbo.getaccountname(SupplierID),
'Bill No.'=BillNo,'Bill Date'=OldBillDate,'Bill Amount'=BillAmount,'Assets Mfr No.'=AssetsMfrNo,'Inspection Date'=InspectionDate,
'Warranty Period'=WarrantyPeriod,'Insurance From Date'=InsuranceFromDate,'Insurance To Date'=InsuranceToDate,      
'AMC From Date'=AMCFromDate,'AMC To Date'=AMCToDate,'Person Responsible'=PersonResponsible,5 From AccountsMaster,Batch_Assets Where       
Batch_Assets.AccountID=@AccountID and Batch_Assets.AccountID=AccountsMaster.AccountID and      
((APVDate <= @ToDatePair) or Batch_Assets.APVDate Is Null)      
Union All      
Select 'Serial Number'='Total:',Null,Null,Null,Sum(Case When Saleable=1 then (IsNull(OPWDV,0)-((Case when IsNull(BillDate,0)<= @CheckDate then (IsNull(OPWDV,0) * (AdditionalField1/100)) else (IsNull(OPWDV,0)*((AdditionalField1/2)/100    
)) End))) Else (Case When Saleable=0 Then 0 Else 0 End) End),      
Null,Null,null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,1 
From AccountsMaster,Batch_Assets Where Batch_Assets.AccountID=@AccountID and Batch_Assets.AccountID=AccountsMaster.AccountID and      
((APVDate <= @ToDatePair) or Batch_Assets.APVDate Is Null) 
