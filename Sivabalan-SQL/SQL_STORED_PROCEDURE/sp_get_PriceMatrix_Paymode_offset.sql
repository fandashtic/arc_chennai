CREATE Procedure sp_get_PriceMatrix_Paymode_offset(@ITEMCODE as nVarchar(30))    
As    
Create Table #TmpPaymodeCount(ID int Identity, SlabStart Decimal(18,6), SlabEnd Decimal(18,6), SegmentID Int,  
SegmentSerial Int, ModeCredit int Default 0, ModeCash int  Default 0, ModeCheque int  Default 0, ModeDD int  Default 0)   
Declare @Cnt Int  
DEclare @i Int  
Declare @PAYMODE INT, @SEGMENTSERIAL INT  
Set @i = 1   
Insert into #TmpPaymodeCount (SlabStart, SlabEnd, SegmentID, SegmentSerial)  
Select Distinct PA.SlabStart, PA.SlabEnd, PSD.SegmentID, PSD.SegmentSerial   
From PricingSegmentDetail PSD, PricingAbstract PA  
Where PSD.PricingSerial = PA.PricingSerial   
And PA.ItemCode = @ITEMCODE  
Order by PSD.SegmentSerial  
  
Select @Cnt = Count(*) From #TmpPaymodeCount   
  
While @i <= @CNT  
    Begin  
    Declare Cur_PayMode Cursor For  
    Select PPD.PaymentMode, PPD.SegmentSerial  From pricingPaymentDetail PPD, #TmpPaymodeCount Tmp  
    Where Tmp.SegmentSerial = PPD.segmentSerial   
    And Tmp.ID = @i  
    OPEN Cur_PayMode  
    FETCH NEXT FROM Cur_PayMode INTO @PAYMODE, @SEGMENTSERIAL  
        WHILE @@FETCH_STATUS = 0  
        BEGIN  
            IF @PAYMODE = 0  
            BEGIN  
                UPDATE #TmpPaymodeCount Set ModeCredit= 1 WHERE SegmentSerial = @SEGMENTSERIAL  
            END   
            ELSE IF @PAYMODE = 1  
            BEGIN  
                UPDATE #TmpPaymodeCount Set ModeCash= 1 WHERE SegmentSerial = @SEGMENTSERIAL  
            END   
            ELSE IF @PAYMODE = 2  
            BEGIN  
                UPDATE #TmpPaymodeCount Set ModeCheque= 1 WHERE SegmentSerial = @SEGMENTSERIAL  
            END   
            ELSE IF @PAYMODE = 3  
            BEGIN  
                UPDATE #TmpPaymodeCount Set ModeDD= 1 WHERE SegmentSerial = @SEGMENTSERIAL  
            END   
            FETCH NEXT FROM Cur_PayMode INTO @PAYMODE, @SEGMENTSERIAL  
        END  
        CLOSE Cur_PayMode     
        DEALLOCATE Cur_PayMode    
        SET @i= @i + 1     
  End   
  
Select Distinct A.SlabStart, A.SlabEnd from #TmpPaymodeCount A, #TmpPaymodeCount B   
where ((A.ModeCredit <> B.ModeCredit)   
or (A.ModeCash <> B.ModeCash)  
or (A.ModeCheque <> B.ModeCheque)  
or (A.ModeDD <> B.ModeDD)) And a.ID <> b.ID  
Union
Select A.SlabStart, A.SlabEnd From 
(Select SlabStart, SlabEnd, Count(SegmentID) as Cnt From  #TmpPaymodeCount Group By SlabStart, SlabEnd) A,
(Select Count(Distinct SegmentId) Cnt From #TmpPaymodeCount) B
Where A.Cnt <> B.Cnt 
  
Select A.SegmentID,A.SegmentName From(  
  Select CS.SegmentID, CS.SegmentName, Count(CS.SegmentID) as SCount   
  From #TmpPaymodeCount tmp, CustomerSegment CS   
  Where tmp.SegmentID = CS.SegmentID  
  Group By CS.SegmentID, CS.SegmentName) A  
WHERE A.SCount < (Select Max(A.SCount) From   
 (Select SegmentID, Count(SegmentID) as SCount From  #TmpPaymodeCount Group By SegmentID)A)  
Group By A.SegmentId, A.SegmentName  
  
Drop table #TmpPaymodeCount  


