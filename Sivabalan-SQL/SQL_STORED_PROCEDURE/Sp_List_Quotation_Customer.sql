
CREATE Procedure Sp_List_Quotation_Customer(        
@CustomerCategory nVarchar(50), @CustomerType nVarchar(50), @BeatID nVarchar(255),                  
@ChannelType nVarchar(255),                  
@SegmentID NVARCHAR(255),                  
@FromDate DateTime, @ToDate DateTime)                    
As                    
Begin    
Declare @Delimeter char(1)          
Declare @Segment Int                    
Declare @Cur_Seg Cursor          
Set @Delimeter=','                  
Create Table #tmpBeat(BeatID int)                  
Create Table #tmpChannel(ChannelType int)            
Create Table #tmpSegment(SegmentId int)            
Create Table #tmpSegmentID(SegmentID Int,SegmentName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)            
          
          
If @BeatID  <> N'%'       
	Insert Into #tmpBeat(BeatID)  Select * from dbo.Sp_SplitIn2Rows(@BeatID ,@Delimeter)                  
                
If @ChannelType <> N'%'                
	Insert Into #tmpChannel(ChannelType) Select * from dbo.Sp_SplitIn2Rows(@ChannelType,@Delimeter)                  
                
If @SegmentID=N'%'                
	Insert Into #tmpSegment(SegmentID) Select SegmentID From CustomerSegment Where Active=1                
Else                
	Insert Into #tmpSegment(SegmentID) Select * From dbo.Sp_SplitIn2Rows(@SegmentID,@Delimeter)          
          
          
Set @Cur_Seg = Cursor For Select SegmentID From #tmpSegment            
Open @Cur_Seg              
Fetch Next From @Cur_Seg Into @Segment          
While @@Fetch_status=0              
Begin              
	Insert Into #tmpSegmentID Select * From dbo.Fn_GetLeafLevelSegment(@Segment)              
	Fetch Next From @Cur_Seg Into @Segment          
End              
close @Cur_Seg            
        
--customers filtered based on segment alone
If @BeatID='%' And  @ChannelType='%'    
Begin               
	  SELECT @FromDate = dbo.StripDateFromTime(@FromDate), @ToDate = dbo.StripDateFromTime(@ToDate)                    
	  SELECT Customer.CustomerId, Company_Name, CASE QuotationAbstract.Active                     
	  WHEN 1 THEN                     
	  QuotationName                    
	  ELSE                     
	  N''                     
	  END                     
	  FROM QuotationAbstract LEFT JOIN QuotationCustomers ON QuotationCustomers.QuotationID = QuotationAbstract.QuotationID                     
	  And QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or                    
	  (@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate))                    
	  RIGHT JOIN Customer ON QuotationCustomers.CustomerID =Customer.CustomerID                   
	  WHERE     
	  Customer.SegmentID In (Select SegmentID From #tmpSegmentID)                  
	  And Cast(CustomerCategory As nVarchar) Like @CustomerCategory                    
	  And Cast(Locality As nVarchar) Like @CustomerType                    
	  And Customer.Active = 1                      
	  order by company_name asc              
End    
--Customers filtered based on channel and segment
Else if @BeatID='%' AND @ChannelType <> '%'    
Begin    
	  SELECT @FromDate = dbo.StripDateFromTime(@FromDate), @ToDate = dbo.StripDateFromTime(@ToDate)                    
	  SELECT Customer.CustomerId, Company_Name, CASE QuotationAbstract.Active                     
	  WHEN 1 THEN                     
	  QuotationName                    
	  ELSE                     
	  N''                     
	  END                     
	  FROM QuotationAbstract LEFT JOIN QuotationCustomers ON QuotationCustomers.QuotationID = QuotationAbstract.QuotationID                     
	  And QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or                    
	  (@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate))                    
	  RIGHT JOIN Customer ON QuotationCustomers.CustomerID =Customer.CustomerID                   
	  WHERE     
	  Customer.ChannelType  In (Select ChannelType From #tmpChannel)                   
	  And Customer.SegmentID In (Select SegmentID From #tmpSegmentID)                  
	  And Cast(CustomerCategory As nVarchar) Like @CustomerCategory                    
	  And Cast(Locality As nVarchar) Like @CustomerType                    
	  And Customer.Active = 1                      
	  order by company_name asc              
End    
---Customers filters based on beat and segment 
Else if @BeatID <> '%' And @ChannelType='%'    
Begin    
	  SELECT @FromDate = dbo.StripDateFromTime(@FromDate), @ToDate = dbo.StripDateFromTime(@ToDate)                    
	  SELECT Customer.CustomerId, Company_Name, CASE QuotationAbstract.Active                     
	  WHEN 1 THEN                     
	  QuotationName                    
	  ELSE                     
	  N''                     
	  END                     
	  FROM QuotationAbstract LEFT JOIN QuotationCustomers ON QuotationCustomers.QuotationID = QuotationAbstract.QuotationID                     
	  And QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or                    
	  (@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate))                    
	  RIGHT JOIN Customer ON QuotationCustomers.CustomerID =Customer.CustomerID                   
	  INNER JOIN Beat_SalesMan ON Beat_SalesMan.CustomerID = Customer.CustomerID                    
	  WHERE     
	  Beat_SalesMan.BeatID  In (Select BeatId From #tmpBeat)                  
	  And Customer.SegmentID In (Select SegmentID From #tmpSegmentID)                  
	  And Cast(CustomerCategory As nVarchar) Like @CustomerCategory                    
	  And Cast(Locality As nVarchar) Like @CustomerType                    
	  And Customer.Active = 1                      
	  order by company_name asc        
End    
--customers filtered based on channel,beat and segment      
Else    
Begin    
	  SELECT @FromDate = dbo.StripDateFromTime(@FromDate), @ToDate = dbo.StripDateFromTime(@ToDate)                    
	  SELECT Customer.CustomerId, Company_Name, CASE QuotationAbstract.Active                     
	  WHEN 1 THEN                     
	  QuotationName                    
	  ELSE                     
	  N''                     
	  END                     
	  FROM QuotationAbstract LEFT JOIN QuotationCustomers ON QuotationCustomers.QuotationID = QuotationAbstract.QuotationID                     
	  And QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or                    
	  (@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate))                    
	  RIGHT JOIN Customer ON QuotationCustomers.CustomerID =Customer.CustomerID                   
	  INNER JOIN Beat_SalesMan ON Beat_SalesMan.CustomerID = Customer.CustomerID                    
	  WHERE     
	  Beat_SalesMan.BeatID  In (Select BeatId From #tmpBeat)                  
	  And Customer.ChannelType  In (Select ChannelType From #tmpChannel)                   
	  And Customer.SegmentID In (Select SegmentID From #tmpSegmentID)                  
	  And Cast(CustomerCategory As nVarchar) Like @CustomerCategory                    
	  And Cast(Locality As nVarchar) Like @CustomerType                    
	  And Customer.Active = 1                      
	  order by company_name asc              
End    
    
          
Drop Table #tmpBeat                    
Drop Table #tmpChannel          
Drop Table #tmpSegment                    
Drop Table #tmpSegmentID          
Deallocate @Cur_Seg          
    
End   
  
