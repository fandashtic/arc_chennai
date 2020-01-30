CREATE Procedure Spr_Get_CampaignName(@Customerid nvarchar(30),@DefaultDrives Int,@Result nVarchar(4000) OutPut)         
As        
Begin        
 Declare @PrintDet nvarchar(500)        
 Declare @Detail nvarchar(500)        
        
 Create Table #TmpCamp (CampaignId nVarchar(100), CampaignName nVarchar(250))       
 set @PrintDet='' -- initialize the variable        
      
Insert Into #TmpCamp(CampaignId, CampaignName)      
(
	Select  
		CampaignMaster.CampaignId,CampaignMaster.CampaignName  
	From 
		CampaignMaster,CampaignCustomers
	Where 
		CampaignMaster.CampaignId = CampaignCustomers.CampaignId                       
	 And CampaignCustomers.CustomerID = @Customerid   
	 And CampaignMaster.Customerid = 1 
		And CampaignMaster.Todate > = GetDate() 
	 And CampaignMaster.Active = 1 
		And IsNull(DefaultDrive,0)= @DefaultDrives 
Union
	Select  
		CampaignMaster.CampaignId,CampaignMaster.CampaignName  
	From 
		CampaignMaster 
 Where 
		CampaignMaster.Customerid = 0  
		And CampaignMaster.Active = 1
		And CampaignMaster.Todate > = GetDate()  
		And IsNull(DefaultDrive,0)= @DefaultDrives
 )      

If not Exists (Select * From  #TmpCamp having Count(CampaignId ) >=1 )    
 set @PrintDet= 0    
Else    
Begin    
 Declare DetailCursor Cursor For Select CampaignName From #TmpCamp      
 Open  detailCursor        
 Fetch next from DetailCursor into @Detail        
  while @@Fetch_Status=0        
   Begin        
    set @PrintDet=@PRintDet + @Detail +' : '
    Fetch next from DetailCursor into @Detail        
   End        
  close DetailCursor        
  Deallocate DetailCursor        
 set @PrintDet=Left(@PrintDet,(Charindex(':',@printdet,Len(@PrintDet))-1))        
End    
    
    
SELECT @RESULT = IsNull(@PRINTDET,'0') -- Return the Campaign name        
End        

drop table #TmpCamp
