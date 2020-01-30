
CREATE Procedure mERP_sp_Get_RFAClaimInfo(@Type as Int, @FromMonth nvarchar(100), @ToMonth nvarchar(100))     
As    
BEGIN
 SET DATEFORMAT DMY  
 Declare @Prefix nVarchar(50)    
   
-- Create Table #Temp (DocID nVarchar(255), DocType nVarchar(255), RFADate nVarchar(255), SchemeType  Int, ClaimID Int)    
 Create Table #Temp (DocID nVarchar(255), DocType nVarchar(500),SchemeFrom nVarchar(255),SchemeTo nVarchar(255), RFADate nVarchar(255), SchemeType  Int, ClaimID Int)    
 Select @Prefix = Prefix  From VoucherPrefix Where TranID = 'CLAIMS NOTE'    
    
 If @Type = 1 /*Damages And Expiry*/ 
 Begin   
Insert Into #Temp (DocID, DocType,SchemeFrom,SchemeTo, RFADate, SchemeType, ClaimID) 
  Select @Prefix + Cast(cn.DocumentId as nVarchar) + '/' + 
	SUBSTRING(CONVERT(nVarchar(30), dda.ClaimDate, 103), 1, 2) +  
	SUBSTRING(CONVERT(nVarchar(30), dda.ClaimDate, 103), 4, 2) + 
	SUBSTRING(CONVERT(nVarchar(30), dda.ClaimDate, 103), 7, 4) as ActivityCode,     
   'Damages' + ' - ' + dda.RemarksDescription  as Description, 
   case OptSelection when 1 then CONVERT(nVarchar(30), dda.DayCloseDate, 103) else CONVERT(nVarchar(30), dda.FromDate, 103) End  As SchemeFrom,
   case OptSelection when 1 then CONVERT(nVarchar(30), dda.DayCloseDate, 103) else CONVERT(nVarchar(30), dda.ToDate, 103) End  As SchemeTo,	
   CONVERT(nVarchar(30), dda.DestroyedDate, 103) As RFADate,	
   Case cn.ClaimType     
           When 1 Then 7    
           Else 6     
           End as SchemeType,     
   cn.ClaimID       
  From ClaimsNote cn, DandDAbstract dda    
  Where cn.ClaimID = dda.ClaimID 
	And IsNull(dda.ClaimStatus, 0) = 3 
	And dbo.stripdatefromtime(cn.claimdate) between  
	isnull(dbo.mERP_fn_getFromDate(@FromMonth) ,getdate()) And  
	isnull(dbo.mERP_fn_getToDate(@ToMonth) ,getdate())  
	And IsNull(cn.Status, 0) <= 1     
	And cn.ClaimType In (2)    
	And IsNull(cn.ClaimRFA, 0) = 0 
	And ISNULL(DDA.Flag,0) = 0

  Union 

  Select @Prefix + Cast(DocumentId as nVarchar) as ActivityCode,     
   --'Damages' as Description, '', 
  'Damages' as Description, '', '','', 	
   Case ClaimType     
           When 1 Then 7    
           Else 6     
           End as SchemeType,     
   ClaimID       
  From ClaimsNote    
  Where   
  dbo.stripdatefromtime(claimdate) between  
  isnull(dbo.mERP_fn_getFromDate(@FromMonth) ,getdate()) And  
  isnull(dbo.mERP_fn_getToDate(@ToMonth) ,getdate())  
  And IsNull(Status, 0) <= 1     
  And ClaimType In (1)    
  And IsNull(ClaimRFA, 0) = 0

	Select DocID as ActivityCode, DocType as Description,SchemeFrom,SchemeTo, RFADate, SchemeType, ClaimID from #temp
 End    
 Else /*Sampling*/  
 Begin  
  Insert Into #Temp (DocID, DocType, SchemeType, ClaimID) 
   Select @Prefix + Cast(DocumentId as nVarchar) as ActivityCode,     
   'Sampling' as Description, 8, ClaimID       
  From ClaimsNote    
  Where   
  dbo.stripdatefromtime(claimdate) between  
  isnull(dbo.mERP_fn_getFromDate(@FromMonth) ,getdate()) And  
  isnull(dbo.mERP_fn_getToDate(@ToMonth) ,getdate())  
  And IsNull(Status, 0) <= 1     
  And ClaimType In (3)    
  And IsNull(ClaimRFA, 0) = 0    
    
	Select DocID as ActivityCode, DocType as Description, SchemeType, ClaimID from #temp    
 End 
 Drop Table #Temp    
END  
