
Create Function dbo.GetBeatForVanLoadingSummary_ITC(@VanNum nvarchar(50),@Beat nvarchar(510),@FromDate datetime,@ToDate datetime)
Returns nvarchar(4000)
Begin
Declare @Beats as nvarchar(4000)
Declare @Delimeter as Char(1)          
Declare @BeatNam as nvarchar(50)

Set @Delimeter = ','
  
DECLARE Beat_Cursor CURSOR STATIC FOR        
Select Distinct bt.Description From Beat bt,InvoiceAbstract ia 
Where ia.InvoiceDate Between @FromDate And @ToDate 
And IsNull(ia.Status,0) & 128 = 0 
And ia.vannumber=@VanNum 
And ia.BeatID in (Select * From dbo.sp_SplitIn2Rows(@Beat,',')) 
And ia.beatid=bt.beatid

Open Beat_Cursor      
Fetch From Beat_Cursor Into @BeatNam      
While @@FETCH_STATUS = 0      
BEGIN      
 Set @Beats = IsNull(@Beats, '') + ',' + @BeatNam      
 Fetch Next From Beat_Cursor Into @BeatNam      
END      
Close Beat_Cursor      
Deallocate Beat_Cursor      
Return Substring(@Beats,2,4000)
End

