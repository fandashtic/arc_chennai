
Create Procedure spr_VanLoading_OrderBooking_ITC( @VanNo nVarchar(4000),  
@Beat nVarchar(510), @Product_Hierarchy nVarchar(256),               
@Category nVarchar(2550), @FromDate DateTime, @ToDate DateTime)  
As  
Begin  
  
Declare @Delimeter as Char(1)          
  
Set @Delimeter=Char(15)            
  
Create Table #tempCategory(CategoryID int, Status int)              
Exec dbo.GetLeafCategories @Product_Hierarchy, @Category        
      
Create Table #tmpVan(VanNumber nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #tmpBeat(BeatID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
  
If @VanNo='%'           
  Insert into #tmpVan Select Van From Van        
Else          
 Insert into #tmpVan      
 Select Van From Van where Van_Number in (Select * From dbo.sp_SplitIn2Rows(@VanNo,@Delimeter))                      
  
If @Beat = '%'  
 Insert into #tmpBeat Select BeatId From Beat  
Else  
 Insert into #tmpBeat   
 Select BeatId from Beat Where Description In ( Select * From dbo.sp_SplitIn2Rows(@Beat,@Delimeter))   
  
  
Create table #tmpCat(Category varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
If @Category = '%' And @Product_Hierarchy = '%'    
Begin    
    
   Insert into #tmpCat select Category_Name from ItemCategories Where [level] = 1    
    
End    
Else If @Category = '%' And @Product_Hierarchy != '%'    
Begin    
 Insert InTo #tmpCat select Category_Name From itemcategories itc, itemhierarchy ith    
 where itc.[level] = ith.hierarchyid and ith.hierarchyname = @Product_Hierarchy    
End    
Else          
Begin    
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)          
End    

-- To get comma seperated beatid in a string
Declare @BeatStr as nvarchar(4000)
Declare @BeatCursor as nvarchar(255)
DECLARE Cur_Beat CURSOR STATIC FOR 
Select BeatID From #tmpBeat       
Open Cur_Beat      
Fetch From Cur_Beat Into @BeatCursor      
While @@FETCH_STATUS = 0      
BEGIN      
 Set @BeatStr = IsNull(@BeatStr, '') + ',' + @BeatCursor      
 Fetch Next From Cur_Beat Into @BeatCursor      
END      
Close Cur_Beat      
Deallocate Cur_Beat  
Set @BeatStr=Substring(@BeatStr,2,4000)    
--

Select  Ia.VanNumber,    
 "Van Name" = IA.VanNumber, "Beat" = dbo.GetBeatForVanLoadingSummary_ITC(Ia.VanNumber,@BeatStr,@FromDate,@ToDate),
 "Total Weight(KG)" = Sum(isnull(conversionfactor,0) *  IsNull(Quantity,0) )          
 From InvoiceAbstract Ia, InvoiceDetail Idt ,Items I,Van, ItemCategories IC  
 Where           
 Idt.InvoiceId = Ia.InvoiceId           
 And idt.Product_Code = I.Product_Code      
 And I.CategoryId = Ic.CategoryId  
 And IC.CategoryId In (Select CategoryId From #tempCategory)  
 And VanNumber Is Not Null And           
 Ia.VanNumber = Van.Van And      
 Ia.VanNumber IN (Select VanNumber COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpVan) And          
 Ia.BeatId IN (Select BeatId From #tmpBeat) And          
 Ia.InvoiceDate Between @FromDate And @ToDate  And         
 Ia.Status & 128 = 0        
 Group by Ia.VanNumber ,Van.Van_Number         
   
 Drop Table #tempCategory  
 Drop Table #tmpCat  
 Drop Table #tmpVan        
 Drop Table #tmpBeat  
End  
  
 
