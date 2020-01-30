Create Procedure sp_DropSchemesByFSU
AS
Begin

IF Not Exists(Select FycpStatus From Setup Where isnull(FycpStatus,0)=0)
	Goto Last

If Not Exists(Select 'x' From sysobjects Where Name Like 'DropSchemesByFSU' And xType = 'U')
	Goto Last

If (select Flag from tbl_mERP_ConfigAbstract Where ScreenCode = 'DropSchemesByFSU' and ScreenName ='DropSchemesByFSU') = 0
	Goto Last

Declare @DropID Int
Declare @ActCode  nVarchar(255)    
Declare @DrSchemeID int    
Declare @DrActivityCode  nVarchar(1000)   
Declare @DrActiveFrom Datetime  
Declare @DrActiveTo Datetime
Declare @DropPayoutPeriodto Datetime  
Declare @PayoutID int  
Declare @LatestPayoutID int   
Declare @MaxSchemeID int  
Declare @TranDate datetime    
--Select @TranDate  = dbo.StripTimeFromDate(TransactionDate)  from setup    
Set @TranDate = GETDATE()

--Select * from tbl_mERP_SchemeAbstract Where ActivityCode in 
--(Select  ActSchCode From DropSchemesByFSU where Status = 0)
--Select * from tbl_mERP_SchemePayoutPeriod where SchemeID in 
--(Select SchemeID From tbl_mERP_SchemeAbstract Where ActivityCode in 
--(Select  ActSchCode From DropSchemesByFSU where Status = 0))

Declare DropSchList Cursor for Select DropID, ActSchCode From DropSchemesByFSU where Status = 0
Open DropSchList
Fetch From DropSchList Into @DropID, @ActCode
While @@Fetch_Status = 0    
Begin
  Set @MaxSchemeID = 0
  Select @MaxSchemeID = Max(SchemeID) from tbl_mERP_SchemeAbstract Where ActivityCode = @ActCode
  If (Select Count(*) from tbl_mERP_SchemeAbstract where ActivityCode = @ActCode and @TranDate >= ActiveFrom) >= 1
  Begin
    Declare Mycur Cursor for Select SchemeID, ActivityCode, ActiveFrom, ActiveTo from tbl_merp_SchemeAbstract  
    Where ActivityCode = @ActCode  
    Order By SchemeID   
    Open Mycur  
    Fetch From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo  
    While @@Fetch_Status = 0    
    Begin  
      Set @DrActiveFrom = dbo.StriptimeFromDate(@DrActiveFrom)  
      Set @DrActiveTo =  dbo.StriptimeFromDate(@DrActiveTo)  
      Set @TranDate =  dbo.StriptimeFromDate(@TranDate)  
     
      If exists (Select SchemeID from tbl_merp_SchemeAbstract where SchemeID = @DrSchemeID and  
      @TranDate between  @DrActiveFrom and @DrActiveTo)  
      Begin  
        Update tbl_mERP_SchemeAbstract Set  ActiveTo = @TranDate   
             , ExpiryDate = GETDATE()
             , SchemeStatus = 2  
        where ActivityCode = @ActCode and SchemeID = @DrSchemeID and   
        @TranDate between  @DrActiveFrom and @DrActiveTo  
        
        Select @PayoutID = ID, @DropPayoutPeriodto =  PayoutPeriodTo   
        from tbl_mERP_SchemePayoutPeriod SPP , tbl_merp_SchemeAbstract SA  
        where SA.ActivityCode = @ActCode and SA.SchemeID = @DrSchemeID   
        And @TranDate between  @DrActiveFrom and @DrActiveTo   
        And  SA.SchemeID = Spp.SChemeID  
        And  @TranDate between Spp.PayoutPeriodFrom and SPP.PayoutPeriodTo  
  
        Update tbl_mERP_SchemePayoutPeriod Set PayoutPeriodTo = @TranDate   
        Where ID = @PayoutID  
  
        Update tbl_mERP_SchemePayoutPeriod Set Active = 0  where   
        PayoutPeriodFrom > dbo.StriptimeFromDate(@DropPayoutPeriodto)  
        and SchemeID = @DrSchemeID  
        and IsNull(Status,0) <> 128  
        and IsNull(ClaimRFA,0) <> 1   
      End  
      Else  
      Begin     
        Update tbl_mERP_SchemeAbstract Set SchemeStatus = 2, Active = 0    
        where ActivityCode = @ActCode and SchemeID = @DrSchemeID and @TranDate <= ActiveFrom  
        --Added on 06.01.2011  
        Update SPP Set Active = 0  From   
        tbl_mERP_SchemePayoutPeriod SPP Inner join tbl_mERP_SchemeAbstract SA   
        On SA.SchemeID = SPP.SchemeID Where SPP.SchemeID = @DrSchemeID  
        and @TranDate <= SA.ActiveFrom  
        and IsNull(SPP.Status,0) <> 128  
        and IsNull(SPP.ClaimRFA,0) <> 1  
        --Added on 06.01.2011  
     End  
      Fetch Next From Mycur Into @DrSchemeID, @DrActivityCode, @DrActiveFrom, @DrActiveTo  
    End -- FetchStatus End  
    Close Mycur  
    Deallocate Mycur   
    Update DropSchemesByFSU Set Status = 1  Where DropID  = @DropID
    Goto Skip
  End    
  Else  
  Begin  
    Update tbl_mERP_SchemeAbstract Set Active = 0, SchemeStatus = 2 where ActivityCode = @ActCode    
    and SchemeID = @MaxSchemeID   
  
    Update tbl_mERP_SchemePayoutPeriod Set Status = Status|192, Active = 0 where IsNull(SchemeID,0) = @MaxSchemeID   
    and IsNull(Status,0) <> 128  
    and IsNull(ClaimRFA,0) <> 1  
  
    Update DropSchemesByFSU Set Status = 2  Where DropID  = @DropID
    Goto Skip   
  End
Skip:
	Fetch Next From DropSchList Into @DropID, @ActCode
End
Close DropSchList
Deallocate DropSchList
Last:
 Update tbl_mERP_ConfigAbstract Set Flag = 0 Where ScreenCode = 'DropSchemesByFSU' and ScreenName ='DropSchemesByFSU'
End
