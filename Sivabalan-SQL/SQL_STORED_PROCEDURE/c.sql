
Create Procedure c(@Manufacturer nVarchar(100),@AsOnDate As DateTime)          
As        
Begin        
 Set DateFormat DMY          
     
 Declare  @BefDate as DateTime         
 Declare @InvoiceId as nVarchar(255)       
 Declare @GRNDOCID as nvarchar(255)   
 declare @GrnID as nvarchar(255)  
 Declare @Cnt as Int        
 Declare @Delimeter Char(1)    
 Set @Delimeter = Char(15)    
    
      
 Set @BefDate  = @AsonDate -7         
 Create Table #TempManufacturer(Mname nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
 If @Manufacturer = N'%'    
 Insert into #TempManufacturer Select Manufacturer_Name From Manufacturer    
 else    
 Insert into #TempManufacturer Select * From Dbo.sp_SplitIn2Rows(@Manufacturer, @Delimeter)    
        
 Create Table #tmpInvId(InvId Int, InvoiceId nVarchar(4000), ReportId Int, ReportDate DateTime)         
 Insert Into #tmpInvId  Values(Null,'',619,@AsOnDate)     
     
 Declare  RetInvoice Cursor For        
 Select Distinct         
 (Case When IsNull(Inv.DocumentId,'') = '' Then Inv.Reference Else cast(Inv.DocumentId As nVarChar) End)  
 From GrnAbstract Grn,InvoiceAbstractReceived Inv,InvoiceDetailReceived InvDet,Items It  
 Where Grn.RecdInvoiceId = Inv.InvoiceId and    
 Inv.InvoiceId = InvDet.InvoiceId And    
 It.Product_Code = InvDet.Product_code And    
 (IsNull(Grn.RecdInvoiceId,0) <> 0  Or IsNull(Grn.DocRef,'') <> '') and    
 (IsNull(Inv.DocumentId,'') <> ''  Or IsNull(Inv.Reference,'') <> '')        
 And dbo.StripDateFromTime(Grn.GrnDate) BetWeen  dbo.StripDateFromTime(@BefDate)  And dbo.StripDateFromTime(@AsOnDate) And    
 It.ManufacturerID In (Select ManufacturerID From Manufacturer Where Manufacturer_Name In (Select * From #TempManufacturer))     
   set @GrnID =''  
   Set @Cnt = 1        
   Open RetInvoice        
   Fetch Next From RetInvoice Into @InvoiceId  
   While @@Fetch_Status = 0        
   Begin     
   
         If @Cnt = 1       
  Begin      
        Update #tmpInvId Set InVoiceId = InVoiceId +  @InVoiceID   
      --set @GrnID =@GrnID + @GRNDOCID   
         End  
         Else   
  begin  
        Update #tmpInvId Set InVoiceId = InVoiceId + ',' +  @InVoiceID  
     --if @GRNDOCID<>''   
     --set @GrnID =@GrnID +','+@GRNDOCID   
  End  
         Set @Cnt = @Cnt +1        
    Fetch Next From RetInvoice Into @InvoiceId      
   End                 
  Close RetInvoice        
  Deallocate RetInvoice   
  
 Declare  RetGRN Cursor For  
 Select Distinct grn.docref         
 From GrnAbstract Grn  
 Where (IsNull(Grn.RecdInvoiceId,0) = 0  and IsNull(Grn.DocRef,'') <> '')   
 and  dbo.StripDateFromTime(Grn.GrnDate) BetWeen  dbo.StripDateFromTime(@BefDate)  And dbo.StripDateFromTime(@AsOnDate)   
   Set @Cnt = 1      
 Open RetGRN   
       
   Fetch Next From RetGRN Into @GRNDOCID         
   While @@Fetch_Status = 0   
   Begin  
  If @Cnt = 1       
  Begin              
      set @GrnID = @GRNDOCID   
         End  
         Else   
  begin          
     if @GRNDOCID<>''   
     set @GrnID =@GrnID +','+@GRNDOCID   
  End  
         Set @Cnt = @Cnt +1      
 Fetch Next From RetGRN Into @GRNDOCID   
   End     
Close RetGRN        
  Deallocate RetGRN   
 if  @GrnID<>''  
  Update #tmpInvId Set InVoiceId = InVoiceId + ',' +  @GrnID   
  
 Select INVID,"CPLDate"=reportdate,"ProcessedInvoices"=invoiceid From #tmpInvId                 
 Drop table #tmpInvId          
 Drop table #TempManufacturer    
 End        
  
 
